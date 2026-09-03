import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/hrms_app.dart';
import '../../services/attendance_security_service.dart';
import 'qr_attendance_screen.dart';

class AdvancedAttendanceScreen extends StatelessWidget {
  final HrmsService service;
  const AdvancedAttendanceScreen({super.key, required this.service});
  static const items = <_AdvancedItem>[
    _AdvancedItem('GPS Attendance', Icons.location_on, 'Mark attendance after checking live GPS position.'),
    _AdvancedItem('Office Locations', Icons.business, 'Save approved office coordinates and radius.'),
    _AdvancedItem('Geofencing', Icons.radar, 'Validate attendance against approved boundaries.'),
    _AdvancedItem('IP Restriction', Icons.public, 'Configure approved Wi-Fi/network IP addresses.'),
    _AdvancedItem('Device Restriction', Icons.phonelink_lock, 'Register the employee device used for attendance.'),
    _AdvancedItem('QR Attendance', Icons.qr_code_scanner, 'Scan a short-lived company attendance QR.'),
    _AdvancedItem('WFH / On-Duty', Icons.home_work, 'Record attendance with WFH or on-duty mode.'),
  ];

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [const CircleAvatar(radius: 28, child: Icon(Icons.gps_fixed, size: 30)), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Advanced Attendance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), SizedBox(height: 6), Text('Live GPS, geofence, network, device, QR and remote-work controls.')]))]))),
    const SizedBox(height: 16),
    GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 420, mainAxisExtent: 150, crossAxisSpacing: 12, mainAxisSpacing: 12), itemBuilder: (context, index) { final item = items[index]; return Card(child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdvancedAttendanceDetailScreen(service: service, title: item.title, icon: item.icon, description: item.description))), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [CircleAvatar(child: Icon(item.icon)), const SizedBox(width: 14), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 6), Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis)])), const Icon(Icons.chevron_right)]))); }),
  ]);
}

class AdvancedAttendanceDetailScreen extends StatefulWidget {
  final HrmsService service;
  final String title;
  final IconData icon;
  final String description;
  const AdvancedAttendanceDetailScreen({super.key, required this.service, required this.title, required this.icon, required this.description});
  @override State<AdvancedAttendanceDetailScreen> createState() => _AdvancedAttendanceDetailScreenState();
}

class _AdvancedAttendanceDetailScreenState extends State<AdvancedAttendanceDetailScreen> {
  final nameController = TextEditingController();
  final valueController = TextEditingController();
  final security = AttendanceSecurityService();
  bool enabled = true;
  String message = '';
  Position? position;

  @override void dispose() { nameController.dispose(); valueController.dispose(); super.dispose(); }

  Future<void> runAction() async {
    try {
      await widget.service.backend.loadCompanyId();
      final companyId = widget.service.backend.companyId;
      if (companyId == null) throw StateError('Sign in and complete company setup first.');
      final employee = widget.service.employees.isEmpty ? null : widget.service.employees.first;
      switch (widget.title) {
        case 'GPS Attendance':
          if (employee == null) throw StateError('No employee profile available.');
          final result = await security.validate(companyId: companyId, employeeId: employee.id, requireGeofence: true);
          if (!result.allowed) throw StateError(result.message);
          position = result.position;
          widget.service.punchIn(employee.id);
          message = 'GPS attendance marked at ${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}.';
          break;
        case 'Office Locations':
          position = await security.currentPosition();
          await widget.service.backend.saveOfficeLocation(id: DateTime.now().millisecondsSinceEpoch.toString(), name: nameController.text.trim().isEmpty ? 'Office' : nameController.text.trim(), latitude: position!.latitude, longitude: position!.longitude, radiusMeters: double.tryParse(valueController.text.trim()) ?? 150);
          message = 'Current location saved as an approved office.';
          break;
        case 'Geofencing':
          if (employee == null) throw StateError('No employee profile available.');
          final result = await security.validate(companyId: companyId, employeeId: employee.id, requireGeofence: true);
          message = result.message;
          position = result.position;
          break;
        case 'IP Restriction':
          final ip = await security.localIp();
          if (ip == null) throw StateError('Wi-Fi IP could not be detected.');
          await widget.service.backend.saveSettings('attendance', {'allowedIps': [valueController.text.trim().isEmpty ? ip : valueController.text.trim()], 'ipRestrictionEnabled': enabled});
          message = 'IP restriction saved. Current Wi-Fi IP: $ip';
          break;
        case 'Device Restriction':
          if (employee == null) throw StateError('No employee profile available.');
          final id = await security.deviceId();
          await widget.service.backend.saveEmployee(employee..phone = employee.phone);
          await widget.service.backend.db.collection('companies').doc(companyId).collection('employees').doc(employee.id).set({'allowedDeviceId': id}, SetOptions(merge: true));
          message = 'This device is now registered for ${employee.name}.';
          break;
        case 'QR Attendance':
          if (!mounted) return;
          await Navigator.push(context, MaterialPageRoute(builder: (_) => QrAttendanceScreen(service: widget.service)));
          return;
        default:
          if (employee == null) throw StateError('No employee profile available.');
          widget.service.punchIn(employee.id, wfh: true);
          message = 'WFH / On-Duty attendance marked.';
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => message = e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  String get hint {
    switch (widget.title) {
      case 'Office Locations': return 'Radius in meters, e.g. 150';
      case 'IP Restriction': return 'Approved IP, e.g. 192.168.1.10 or CIDR';
      case 'Device Restriction': return 'Tap Register Device';
      case 'Geofencing': return 'Uses saved office locations';
      default: return 'Optional configuration';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.title)), body: ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: ListTile(leading: CircleAvatar(child: Icon(widget.icon)), title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(widget.description), trailing: Switch(value: enabled, onChanged: (v) => setState(() => enabled = v)))),
    const SizedBox(height: 16),
    if (widget.title == 'Office Locations' || widget.title == 'IP Restriction') ...[TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name / Label', border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: valueController, keyboardType: widget.title == 'Office Locations' ? TextInputType.number : TextInputType.text, decoration: InputDecoration(labelText: 'Configuration', hintText: hint, border: const OutlineInputBorder()))],
    const SizedBox(height: 20),
    FilledButton.icon(onPressed: runAction, icon: Icon(widget.title == 'QR Attendance' ? Icons.qr_code_scanner : Icons.play_arrow), label: Text(widget.title == 'Device Restriction' ? 'Register Device' : widget.title == 'GPS Attendance' ? 'Mark GPS Attendance' : widget.title == 'QR Attendance' ? 'Open QR Scanner' : 'Apply / Save')),
    if (message.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 16), child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(message)))),
    if (position != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text('Latitude: ${position!.latitude}\nLongitude: ${position!.longitude}\nAccuracy: ${position!.accuracy.toStringAsFixed(1)} m')),
  ]));
}

class _AdvancedItem {
  final String title;
  final IconData icon;
  final String description;
  const _AdvancedItem(this.title, this.icon, this.description);
}
