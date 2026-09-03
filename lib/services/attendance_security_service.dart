import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';

class AttendanceSecurityResult {
  final bool allowed;
  final String message;
  final Position? position;
  const AttendanceSecurityResult({required this.allowed, required this.message, this.position});
}

class AttendanceSecurityService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final NetworkInfo networkInfo = NetworkInfo();

  Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) throw StateError('Location services are disabled.');
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw StateError('Location permission is required for attendance.');
    return Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
  }

  Future<AttendanceSecurityResult> checkGeofence({required String companyId, required Position position}) async {
    final snap = await db.collection('companies').doc(companyId).collection('officeLocations').where('enabled', isEqualTo: true).get();
    if (snap.docs.isEmpty) return const AttendanceSecurityResult(allowed: false, message: 'No approved office location is configured.', position: null);
    for (final doc in snap.docs) {
      final d = doc.data();
      final lat = (d['latitude'] as num?)?.toDouble();
      final lon = (d['longitude'] as num?)?.toDouble();
      final radius = (d['radiusMeters'] as num?)?.toDouble() ?? 100;
      if (lat == null || lon == null) continue;
      final distance = Geolocator.distanceBetween(position.latitude, position.longitude, lat, lon);
      if (distance <= radius) return AttendanceSecurityResult(allowed: true, message: 'Inside approved office area (${distance.round()} m).', position: position);
    }
    return AttendanceSecurityResult(allowed: false, message: 'You are outside the approved attendance area.', position: position);
  }

  Future<String> deviceId() async {
    if (Platform.isAndroid) return (await deviceInfo.androidInfo).id;
    if (Platform.isIOS) return (await deviceInfo.iosInfo).identifierForVendor ?? 'unknown-ios-device';
    return 'unsupported-device';
  }

  Future<bool> isDeviceAllowed({required String companyId, required String employeeId}) async {
    final id = await deviceId();
    final snap = await db.collection('companies').doc(companyId).collection('employees').doc(employeeId).get();
    final allowed = snap.data()?['allowedDeviceId'] as String?;
    return allowed == null || allowed.isEmpty || allowed == id;
  }

  Future<String?> localIp() => networkInfo.getWifiIP();

  Future<bool> isIpAllowed({required String companyId, required String ip}) async {
    final snap = await db.collection('companies').doc(companyId).collection('settings').doc('attendance').get();
    final list = (snap.data()?['allowedIps'] as List?)?.whereType<String>().toList() ?? <String>[];
    if (list.isEmpty) return true;
    return list.any((allowed) => _matchesIp(allowed, ip));
  }

  bool _matchesIp(String allowed, String ip) {
    if (allowed == ip) return true;
    final slash = allowed.indexOf('/');
    if (slash < 0) return false;
    final base = allowed.substring(0, slash).split('.').map(int.parse).toList();
    final mask = int.tryParse(allowed.substring(slash + 1));
    final target = ip.split('.').map(int.tryParse).toList();
    if (base.length != 4 || target.length != 4 || target.any((x) => x == null) || mask == null || mask < 0 || mask > 32) return false;
    int value(List<int> p) => (p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3];
    final m = mask == 0 ? 0 : (0xFFFFFFFF << (32 - mask)) & 0xFFFFFFFF;
    return (value(base) & m) == (value(target.cast<int>()) & m);
  }

  Future<AttendanceSecurityResult> validate({required String companyId, required String employeeId, bool requireGeofence = true, bool requireIp = false, bool requireDevice = false}) async {
    Position? position;
    if (requireGeofence) {
      position = await currentPosition();
      final geo = await checkGeofence(companyId: companyId, position: position);
      if (!geo.allowed) return geo;
    }
    if (requireDevice && !await isDeviceAllowed(companyId: companyId, employeeId: employeeId)) return AttendanceSecurityResult(allowed: false, message: 'This device is not registered for attendance.', position: position);
    if (requireIp) {
      final ip = await localIp();
      if (ip == null || !await isIpAllowed(companyId: companyId, ip: ip)) return AttendanceSecurityResult(allowed: false, message: 'This network is not approved for attendance.', position: position);
    }
    return AttendanceSecurityResult(allowed: true, message: 'Attendance security checks passed.', position: position);
  }
}
