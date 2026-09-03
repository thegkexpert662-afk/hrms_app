import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class AdvancedAttendanceScreen extends StatelessWidget {
  final HrmsService service;
  const AdvancedAttendanceScreen({super.key, required this.service});

  static const items = <_AdvancedItem>[
    _AdvancedItem('GPS Attendance', Icons.location_on, 'Mark attendance using device location.'),
    _AdvancedItem('Office Locations', Icons.business, 'Manage approved office and branch locations.'),
    _AdvancedItem('Geofencing', Icons.radar, 'Configure attendance boundaries around offices.'),
    _AdvancedItem('IP Restriction', Icons.public, 'Allow attendance only from approved networks.'),
    _AdvancedItem('Device Restriction', Icons.phonelink_lock, 'Control which registered devices can mark attendance.'),
    _AdvancedItem('QR Attendance', Icons.qr_code_scanner, 'Use a QR code for quick attendance verification.'),
    _AdvancedItem('WFH / On-Duty', Icons.home_work, 'Manage work-from-home and on-duty attendance.'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(radius: 28, child: Icon(Icons.gps_fixed, size: 30)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Advanced Attendance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      SizedBox(height: 6),
                      Text('Location, network, device and flexible attendance controls.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 420,
            mainAxisExtent: 150,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdvancedAttendanceDetailScreen(
                      service: service,
                      title: item.title,
                      icon: item.icon,
                      description: item.description,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(child: Icon(item.icon)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AdvancedAttendanceDetailScreen extends StatefulWidget {
  final HrmsService service;
  final String title;
  final IconData icon;
  final String description;

  const AdvancedAttendanceDetailScreen({
    super.key,
    required this.service,
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  State<AdvancedAttendanceDetailScreen> createState() => _AdvancedAttendanceDetailScreenState();
}

class _AdvancedAttendanceDetailScreenState extends State<AdvancedAttendanceDetailScreen> {
  bool enabled = true;
  final nameController = TextEditingController();
  final valueController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    valueController.dispose();
    super.dispose();
  }

  String get hint {
    switch (widget.title) {
      case 'GPS Attendance': return 'Location permission / GPS accuracy';
      case 'Office Locations': return 'Office name or address';
      case 'Geofencing': return 'Radius in meters';
      case 'IP Restriction': return 'Approved IP address or range';
      case 'Device Restriction': return 'Registered device name / ID';
      case 'QR Attendance': return 'QR session or code label';
      default: return 'WFH / On-Duty request details';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(widget.icon)),
              title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(widget.description),
              trailing: Switch(value: enabled, onChanged: (v) => setState(() => enabled = v)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name / Label', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: valueController,
            decoration: InputDecoration(labelText: 'Configuration', hintText: hint, border: const OutlineInputBorder()),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.title} settings saved')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Settings'),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Configuration UI is ready. Connect this screen to the HRMS backend and device/location services for live enforcement.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedItem {
  final String title;
  final IconData icon;
  final String description;
  const _AdvancedItem(this.title, this.icon, this.description);
}
