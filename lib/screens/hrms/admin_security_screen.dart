import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class AdminSecurityScreen extends StatelessWidget {
  final HrmsService service;
  const AdminSecurityScreen({super.key, required this.service});

  static const items = <Map<String, dynamic>>[
    {'title': 'Admin Dashboard', 'icon': Icons.admin_panel_settings, 'subtitle': 'System overview and controls'},
    {'title': 'Users', 'icon': Icons.people_alt, 'subtitle': 'Manage HRMS users and accounts'},
    {'title': 'Roles', 'icon': Icons.badge, 'subtitle': 'Create and manage access roles'},
    {'title': 'Permissions', 'icon': Icons.vpn_key, 'subtitle': 'Control module and action access'},
    {'title': 'Login / Session Security', 'icon': Icons.lock, 'subtitle': 'Login, sessions and security policies'},
    {'title': 'Audit Logs / Activity', 'icon': Icons.history, 'subtitle': 'Review system activity and changes'},
  ];

  void open(BuildContext context, int index) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => AdminSecurityDetailScreen(
        service: service,
        title: items[index]['title'] as String,
        icon: items[index]['icon'] as IconData,
        section: index,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              const CircleAvatar(radius: 28, child: Icon(Icons.security)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Admin & Security', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Manage users, access control and security activity'),
              ])),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(items.length, (index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(item['icon'] as IconData)),
              title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(item['subtitle'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => open(context, index),
            ),
          );
        }),
      ],
    );
  }
}

class AdminSecurityDetailScreen extends StatefulWidget {
  final HrmsService service;
  final String title;
  final IconData icon;
  final int section;
  const AdminSecurityDetailScreen({super.key, required this.service, required this.title, required this.icon, required this.section});

  @override
  State<AdminSecurityDetailScreen> createState() => _AdminSecurityDetailScreenState();
}

class _AdminSecurityDetailScreenState extends State<AdminSecurityDetailScreen> {
  bool enabled = true;
  String role = 'Administrator';

  List<Map<String, String>> get rows {
    switch (widget.section) {
      case 0: return [
        {'title': 'Active Users', 'value': '128'},
        {'title': 'Administrators', 'value': '4'},
        {'title': 'Roles', 'value': '8'},
        {'title': 'Security Events', 'value': '24'},
      ];
      case 1: return [
        {'title': 'Aarav Sharma', 'value': 'Administrator'},
        {'title': 'Priya Singh', 'value': 'HR Manager'},
        {'title': 'Rahul Verma', 'value': 'Employee'},
        {'title': 'Neha Gupta', 'value': 'Finance'},
      ];
      case 2: return [
        {'title': 'Administrator', 'value': 'Full access'},
        {'title': 'HR Manager', 'value': 'HR modules'},
        {'title': 'Finance', 'value': 'Payroll & expenses'},
        {'title': 'Employee', 'value': 'Self service'},
      ];
      case 3: return [
        {'title': 'Employee Records', 'value': 'View / Edit'},
        {'title': 'Payroll', 'value': 'View / Approve'},
        {'title': 'Reports', 'value': 'View / Export'},
        {'title': 'Settings', 'value': 'Administrator only'},
      ];
      default: return [
        {'title': 'Multi-factor authentication', 'value': 'Enabled'},
        {'title': 'Session timeout', 'value': '30 minutes'},
        {'title': 'Failed login protection', 'value': 'Enabled'},
        {'title': 'Recent activity', 'value': '24 events'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAudit = widget.section == 5;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(leading: CircleAvatar(child: Icon(widget.icon)), title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Admin controls and security management'))),
          if (widget.section == 4) Card(child: SwitchListTile(title: const Text('Security policy enabled'), subtitle: const Text('Apply login and session protection rules'), value: enabled, onChanged: (v) => setState(() => enabled = v))),
          if (widget.section == 1 || widget.section == 2) Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: Text(widget.section == 1 ? 'Default role' : 'Selected role', style: const TextStyle(fontWeight: FontWeight.w700))), DropdownButton<String>(value: role, items: const ['Administrator', 'HR Manager', 'Finance', 'Employee'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => role = v ?? role))]))),
          const SizedBox(height: 8),
          ...rows.map((row) => Card(child: ListTile(title: Text(row['title']!, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: Text(row['value']!)))),
          if (isAudit) ...[
            const SizedBox(height: 8),
            const Text('Latest Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...['User login successful', 'Role updated', 'Payroll report exported', 'Permission changed'].map((event) => const Card(child: ListTile(leading: Icon(Icons.history), title: Text('System activity recorded'), subtitle: Text('Recent administrative activity')))),
          ],
        ],
      ),
    );
  }
}
