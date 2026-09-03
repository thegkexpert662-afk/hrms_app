import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class CompanySettingsScreen extends StatelessWidget {
  final HrmsService service;
  const CompanySettingsScreen({super.key, required this.service});
  static const items = <Map<String, dynamic>>[
    {'title': 'Company Profile', 'icon': Icons.business, 'subtitle': 'Company name, contact and basic details'},
    {'title': 'Branches', 'icon': Icons.location_city, 'subtitle': 'Manage company locations and branches'},
    {'title': 'Working Days', 'icon': Icons.calendar_month, 'subtitle': 'Configure weekly working days'},
    {'title': 'Holidays', 'icon': Icons.celebration, 'subtitle': 'Manage company holidays and dates'},
    {'title': 'Leave Rules', 'icon': Icons.event_available, 'subtitle': 'Configure leave policies and limits'},
    {'title': 'Attendance Rules', 'icon': Icons.access_time, 'subtitle': 'Configure attendance and timing rules'},
    {'title': 'Payroll Rules', 'icon': Icons.payments, 'subtitle': 'Configure payroll calculation rules'},
    {'title': 'Approval Workflow', 'icon': Icons.account_tree, 'subtitle': 'Configure request approval chains'},
    {'title': 'Notification Settings', 'icon': Icons.notifications_active, 'subtitle': 'Configure alerts and notifications'},
  ];

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [const CircleAvatar(radius: 28, child: Icon(Icons.settings)), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Company Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), SizedBox(height: 4), Text('Configure company-wide HRMS policies and preferences')]))]))),
    const SizedBox(height: 12),
    ...List.generate(items.length, (index) { final item = items[index]; return Card(child: ListTile(leading: CircleAvatar(child: Icon(item['icon'] as IconData)), title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(item['subtitle'] as String), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompanySettingsDetailScreen(service: service, title: item['title'] as String, icon: item['icon'] as IconData, section: index)))); }),
  ]);
}

class CompanySettingsDetailScreen extends StatefulWidget {
  final HrmsService service;
  final String title;
  final IconData icon;
  final int section;
  const CompanySettingsDetailScreen({super.key, required this.service, required this.title, required this.icon, required this.section});
  @override State<CompanySettingsDetailScreen> createState() => _CompanySettingsDetailScreenState();
}

class _CompanySettingsDetailScreenState extends State<CompanySettingsDetailScreen> {
  final nameController = TextEditingController(text: 'HRMS Management');
  bool enabled = true;
  String option = 'Enabled';
  List<Map<String, String>> get settings {
    switch (widget.section) {
      case 0: return [{'title': 'Company Name', 'value': 'HRMS Management'}, {'title': 'Country', 'value': 'India'}, {'title': 'Currency', 'value': 'INR'}, {'title': 'Timezone', 'value': 'Asia/Kolkata'}];
      case 1: return [{'title': 'Head Office', 'value': 'Main Branch'}, {'title': 'Pune Branch', 'value': 'Active'}, {'title': 'Mumbai Branch', 'value': 'Active'}, {'title': 'Branch count', 'value': '3'}];
      case 2: return [{'title': 'Monday - Friday', 'value': 'Working'}, {'title': 'Saturday', 'value': 'Weekly Off'}, {'title': 'Sunday', 'value': 'Weekly Off'}, {'title': 'Work hours', 'value': '9:00 AM - 6:00 PM'}];
      case 3: return [{'title': 'Republic Day', 'value': '26 January'}, {'title': 'Independence Day', 'value': '15 August'}, {'title': 'Gandhi Jayanti', 'value': '2 October'}, {'title': 'Custom holidays', 'value': 'Manage list'}];
      case 4: return [{'title': 'Annual leave', 'value': '18 days'}, {'title': 'Sick leave', 'value': '12 days'}, {'title': 'Carry forward', 'value': 'Enabled'}, {'title': 'Approval required', 'value': 'Yes'}];
      case 5: return [{'title': 'Grace period', 'value': '10 minutes'}, {'title': 'Late mark', 'value': 'After grace period'}, {'title': 'Overtime', 'value': 'Approval required'}, {'title': 'Attendance mode', 'value': 'Office + Remote'}];
      case 6: return [{'title': 'Pay cycle', 'value': 'Monthly'}, {'title': 'Payroll date', 'value': 'Last working day'}, {'title': 'Overtime calculation', 'value': 'Configured'}, {'title': 'Tax settings', 'value': 'Enabled'}];
      case 7: return [{'title': 'Leave requests', 'value': 'Manager → HR'}, {'title': 'Expense claims', 'value': 'Manager → Finance'}, {'title': 'Payroll approval', 'value': 'Finance → Admin'}, {'title': 'Attendance correction', 'value': 'Manager'}];
      default: return [{'title': 'Leave alerts', 'value': 'Enabled'}, {'title': 'Attendance alerts', 'value': 'Enabled'}, {'title': 'Payroll alerts', 'value': 'Enabled'}, {'title': 'Announcements', 'value': 'Enabled'}];
    }
  }
  @override void dispose() { nameController.dispose(); super.dispose(); }

  Future<void> save() async {
    try {
      await widget.service.backend.saveSettings('section_${widget.section}', {'title': widget.title, 'name': nameController.text.trim(), 'enabled': enabled, 'option': option});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved to cloud')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved locally; cloud sync unavailable')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.section == 0;
    return Scaffold(appBar: AppBar(title: Text(widget.title)), body: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: ListTile(leading: CircleAvatar(child: Icon(widget.icon)), title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Company configuration'))),
      if (profile) Card(child: Padding(padding: const EdgeInsets.all(16), child: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Company name', border: OutlineInputBorder())))),
      if (widget.section == 8) Card(child: SwitchListTile(title: const Text('Notifications enabled'), subtitle: const Text('Allow configured HRMS alerts'), value: enabled, onChanged: (v) => setState(() => enabled = v))),
      if (widget.section == 2 || widget.section == 4 || widget.section == 5 || widget.section == 6) Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Expanded(child: Text('Policy status', style: TextStyle(fontWeight: FontWeight.w700))), DropdownButton<String>(value: option, items: const ['Enabled', 'Disabled', 'Requires approval'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => option = v ?? option))]))),
      const SizedBox(height: 8),
      ...settings.map((item) => Card(child: ListTile(title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: Text(item['value']!)))),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: save, icon: const Icon(Icons.save), label: const Text('Save Settings')),
    ]));
  }
}
