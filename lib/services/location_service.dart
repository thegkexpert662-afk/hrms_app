import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class AttendanceLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  const AttendanceLocation(this.latitude, this.longitude, this.accuracy);
}

class LocationService {
  Future<AttendanceLocation> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location service is disabled');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }
    final p = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
    return AttendanceLocation(p.latitude, p.longitude, p.accuracy);
  }

  bool insideGeofence({required double latitude, required double longitude, required double officeLatitude, required double officeLongitude, double radiusMeters = 150}) {
    const earth = 6371000.0;
    final dLat = _rad(latitude - officeLatitude);
    final dLon = _rad(longitude - officeLongitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(_rad(officeLatitude)) * math.cos(_rad(latitude)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final distance = earth * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return distance <= radiusMeters;
  }

  double _rad(double value) => value * math.pi / 180;
}
