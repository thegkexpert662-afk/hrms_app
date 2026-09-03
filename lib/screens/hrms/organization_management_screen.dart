import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class OrganizationManagementScreen extends StatefulWidget {
  final HrmsService service;
  const OrganizationManagementScreen({super.key, required this.service});
  @override State<OrganizationManagementScreen> createState() => _OrganizationManagementScreenState();
}

class _OrganizationManagementScreenState extends State<OrganizationManagementScreen> {
  final Map<String, List<Map<String, String>>> data = {
    'Departments': [], 'Designations': [], 'Teams': [], 'Branches / Locations': [],
  };
  final Map<String, String> reporting = {};

  Future<void> _add(String section) async {
    final name = TextEditingController();
    final details = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: Text('Add $section'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
        const SizedBox(height: 10), TextField(controller: details, maxLines: 2, decoration: const InputDecoration(labelText: 'Details / Description', border: OutlineInputBorder())),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, name.text.trim().isNotEmpty), child: const Text('Save'))],
    ));
    if (ok == true && mounted) setState(() => data[section]!.add({'name': name.text.trim(), 'details': details.text.trim()}));
  }

  Future<void> _reporting() async {
    if (widget.service.employees.isEmpty) return;
    String employee = widget.service.employees.first.id;
    String manager = widget.service.employees.length > 1 ? widget.service.employees[1].id : employee;
    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (c, sd) => AlertDialog(
      title: const Text('Managers / Reporting'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(value: employee, decoration: const InputDecoration(labelText: 'Employee', border: OutlineInputBorder()), items: widget.service.employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), onChanged: (v) => sd(() => employee = v!)),
        const SizedBox(height: 10), DropdownButtonFormField<String>(value: manager, decoration: const InputDecoration(labelText: 'Reporting Manager', border: OutlineInputBorder()), items: widget.service.employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), onChanged: (v) => sd(() => manager = v!)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save'))],
    )));
    if (ok == true && mounted) setState(() => reporting[employee] = manager);
  }

  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [const Icon(Icons.account_tree, size: 30), const SizedBox(width: 10), Text('Organization Management', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))]))),
    const SizedBox(height: 12),
    ...data.keys.map((s) => _section(s)),
    Card(child: ExpansionTile(leading: const Icon(Icons.supervisor_account), title: const Text('Managers / Reporting', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${reporting.length} reporting relationship(s)'), children: [
      ...reporting.entries.map((x) { final e = widget.service.employees.where((v) => v.id == x.key); final m = widget.service.employees.where((v) => v.id == x.value); return ListTile(title: Text(e.isEmpty ? x.key : e.first.name), subtitle: Text('Reports to: ${m.isEmpty ? x.value : m.first.name}')); }),
      Padding(padding: const EdgeInsets.all(12), child: Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: _reporting, icon: const Icon(Icons.add), label: const Text('Set Reporting')))),
    ])),
    const SizedBox(height: 12),
    Card(child: ExpansionTile(leading: const Icon(Icons.account_tree_outlined), title: const Text('Organization Chart', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Visual reporting hierarchy'), children: [
      if (widget.service.employees.isEmpty) const ListTile(title: Text('No employees available.')),
      ...widget.service.employees.map((e) => ListTile(leading: const Icon(Icons.person), title: Text(e.name), subtitle: Text('${e.designation} • ${e.department}\nReports to: ${_managerName(e.id)}'), isThreeLine: true)),
    ])),
  ]);

  String _managerName(String id) {
    final managerId = reporting[id];
    if (managerId == null) return 'Not assigned';
    final m = widget.service.employees.where((e) => e.id == managerId);
    return m.isEmpty ? managerId : m.first.name;
  }

  Widget _section(String section) => Card(margin: const EdgeInsets.only(bottom: 12), child: ExpansionTile(leading: const Icon(Icons.folder_open), title: Text(section, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${data[section]!.length} record(s)'), children: [
    if (data[section]!.isEmpty) const ListTile(title: Text('No records yet.')),
    ...List.generate(data[section]!.length, (i) { final x = data[section]![i]; return ListTile(title: Text(x['name']!), subtitle: Text(x['details']!), trailing: IconButton(onPressed: () => setState(() => data[section]!.removeAt(i)), icon: const Icon(Icons.delete_outline))); }),
    Padding(padding: const EdgeInsets.all(12), child: Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: () => _add(section), icon: const Icon(Icons.add), label: const Text('Add')))),
  ]));
}
