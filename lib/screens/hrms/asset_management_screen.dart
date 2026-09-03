import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class AssetsScreen extends StatelessWidget {
  final HrmsService service;
  const AssetsScreen({super.key, required this.service});

  static const _items = <Map<String, dynamic>>[
    {'title': 'Asset List', 'icon': Icons.inventory_2_outlined, 'color': Colors.blue},
    {'title': 'Add Asset', 'icon': Icons.add_box_outlined, 'color': Colors.green},
    {'title': 'Assign Asset', 'icon': Icons.assignment_ind_outlined, 'color': Colors.orange},
    {'title': 'Return Asset', 'icon': Icons.assignment_return_outlined, 'color': Colors.purple},
    {'title': 'Asset History', 'icon': Icons.history, 'color': Colors.teal},
  ];

  void _open(BuildContext context, String title) {
    Widget screen;
    switch (title) {
      case 'Asset List': screen = AssetListScreen(service: service); break;
      case 'Add Asset': screen = AddAssetScreen(service: service); break;
      case 'Assign Asset': screen = AssignAssetScreen(service: service); break;
      case 'Return Asset': screen = ReturnAssetScreen(service: service); break;
      default: screen = AssetHistoryScreen(service: service);
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
        const CircleAvatar(radius: 28, child: Icon(Icons.devices)),
        const SizedBox(width: 14),
        Expanded(child: Text('Asset Management', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
      ]))),
      const SizedBox(height: 14),
      ..._items.map((item) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(child: Icon(item['icon'] as IconData)),
          title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(_subtitle(item['title'] as String)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _open(context, item['title'] as String),
        ),
      )),
    ],
  );

  String _subtitle(String title) {
    switch (title) {
      case 'Asset List': return 'View and manage all company assets';
      case 'Add Asset': return 'Register a new laptop, mobile, ID card or accessory';
      case 'Assign Asset': return 'Assign an available asset to an employee';
      case 'Return Asset': return 'Record returned assets and their condition';
      default: return 'View assignment, return and status history';
    }
  }
}

class _AssetScreen extends StatefulWidget {
  final HrmsService service;
  final String title;
  final Widget child;
  const _AssetScreen({required this.service, required this.title, required this.child});
  @override State<_AssetScreen> createState() => _AssetScreenState();
}
class _AssetScreenState extends State<_AssetScreen> {
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.title)), body: widget.child);
}

class AssetListScreen extends StatelessWidget {
  final HrmsService service;
  const AssetListScreen({super.key, required this.service});
  @override Widget build(BuildContext context) => _AssetScreen(service: service, title: 'Asset List', child: ListView(padding: const EdgeInsets.all(16), children: const [
    _AssetCard(name: 'Company Laptop', type: 'Laptop', status: 'Available', employee: 'Unassigned'),
    _AssetCard(name: 'Office Mobile', type: 'Mobile', status: 'Assigned', employee: 'Employee'),
    _AssetCard(name: 'ID Card', type: 'ID Card', status: 'Assigned', employee: 'Employee'),
  ]);
}

class _AssetCard extends StatelessWidget {
  final String name, type, status, employee;
  const _AssetCard({required this.name, required this.type, required this.status, required this.employee});
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
    leading: const CircleAvatar(child: Icon(Icons.devices_other)), title: Text(name), subtitle: Text('$type • $employee'), trailing: Chip(label: Text(status)),
  ));
}

class AddAssetScreen extends StatefulWidget {
  final HrmsService service;
  const AddAssetScreen({super.key, required this.service});
  @override State<AddAssetScreen> createState() => _AddAssetScreenState();
}
class _AddAssetScreenState extends State<AddAssetScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final serial = TextEditingController();
  final value = TextEditingController();
  String type = 'Laptop';
  @override void dispose() { name.dispose(); serial.dispose(); value.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => _AssetScreen(service: widget.service, title: 'Add Asset', child: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
    DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'Asset Type', border: OutlineInputBorder()), items: const ['Laptop','Desktop','Mobile','ID Card','SIM','Accessories'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => type = v ?? type)),
    const SizedBox(height: 14),
    TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Asset Name', border: OutlineInputBorder()), validator: (v) => v == null || v.trim().isEmpty ? 'Enter asset name' : null),
    const SizedBox(height: 14),
    TextFormField(controller: serial, decoration: const InputDecoration(labelText: 'Serial / Asset ID', border: OutlineInputBorder())),
    const SizedBox(height: 14),
    TextFormField(controller: value, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Purchase Value', prefixText: '₹ ', border: OutlineInputBorder())),
    const SizedBox(height: 20),
    FilledButton.icon(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(context); }, icon: const Icon(Icons.save), label: const Text('Save Asset')),
  ]));
}

class AssignAssetScreen extends StatefulWidget {
  final HrmsService service;
  const AssignAssetScreen({super.key, required this.service});
  @override State<AssignAssetScreen> createState() => _AssignAssetScreenState();
}
class _AssignAssetScreenState extends State<AssignAssetScreen> {
  String asset = 'Company Laptop';
  final employee = TextEditingController();
  @override void dispose() { employee.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => _AssetScreen(service: widget.service, title: 'Assign Asset', child: ListView(padding: const EdgeInsets.all(16), children: [
    DropdownButtonFormField<String>(initialValue: asset, decoration: const InputDecoration(labelText: 'Available Asset', border: OutlineInputBorder()), items: const ['Company Laptop','Office Mobile','ID Card','SIM'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => asset = v ?? asset)),
    const SizedBox(height: 14),
    TextField(controller: employee, decoration: const InputDecoration(labelText: 'Employee Name / ID', border: OutlineInputBorder())),
    const SizedBox(height: 14),
    TextField(maxLines: 3, decoration: const InputDecoration(labelText: 'Assignment Notes', border: OutlineInputBorder())),
    const SizedBox(height: 20),
    FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.assignment_ind), label: const Text('Assign Asset')),
  ]));
}

class ReturnAssetScreen extends StatefulWidget {
  final HrmsService service;
  const ReturnAssetScreen({super.key, required this.service});
  @override State<ReturnAssetScreen> createState() => _ReturnAssetScreenState();
}
class _ReturnAssetScreenState extends State<ReturnAssetScreen> {
  String condition = 'Good';
  @override Widget build(BuildContext context) => _AssetScreen(service: widget.service, title: 'Return Asset', child: ListView(padding: const EdgeInsets.all(16), children: [
    TextField(decoration: const InputDecoration(labelText: 'Asset ID / Name', border: OutlineInputBorder())),
    const SizedBox(height: 14),
    TextField(decoration: const InputDecoration(labelText: 'Employee Name / ID', border: OutlineInputBorder())),
    const SizedBox(height: 14),
    DropdownButtonFormField<String>(initialValue: condition, decoration: const InputDecoration(labelText: 'Asset Condition', border: OutlineInputBorder()), items: const ['Good','Needs Repair','Damaged','Lost'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => condition = v ?? condition)),
    const SizedBox(height: 14),
    TextField(maxLines: 3, decoration: const InputDecoration(labelText: 'Return Notes', border: OutlineInputBorder())),
    const SizedBox(height: 20),
    FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.assignment_return), label: const Text('Record Return')),
  ]));
}

class AssetHistoryScreen extends StatelessWidget {
  final HrmsService service;
  const AssetHistoryScreen({super.key, required this.service});
  @override Widget build(BuildContext context) => _AssetScreen(service: service, title: 'Asset History', child: ListView(padding: const EdgeInsets.all(16), children: const [
    _HistoryTile(title: 'Company Laptop', action: 'Assigned to Employee', date: 'Today'),
    _HistoryTile(title: 'Office Mobile', action: 'Returned by Employee', date: 'Yesterday'),
    _HistoryTile(title: 'ID Card', action: 'Assigned to Employee', date: '01 Sep 2026'),
  ]);
}
class _HistoryTile extends StatelessWidget {
  final String title, action, date;
  const _HistoryTile({required this.title, required this.action, required this.date});
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: const CircleAvatar(child: Icon(Icons.history)), title: Text(title), subtitle: Text('$action\n$date'), isThreeLine: true));
}
