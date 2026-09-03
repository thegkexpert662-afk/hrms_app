import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class LifecycleManagementScreen extends StatefulWidget {
  final HrmsService service;
  const LifecycleManagementScreen({super.key, required this.service});
  @override State<LifecycleManagementScreen> createState() => _LifecycleManagementScreenState();
}

class _LifecycleManagementScreenState extends State<LifecycleManagementScreen> {
  final Map<String, List<Map<String, String>>> data = {};
  final sections = const ['Recruitment','Candidate','Interview','Offer','Joining / Onboarding','Probation / Confirmation','Transfer / Promotion / Increment','Resignation / Exit / Full & Final'];

  @override void initState() { super.initState(); for (final s in sections) { data[s] = []; } }

  Future<void> add(String section) async {
    final name = TextEditingController();
    final detail = TextEditingController();
    final status = TextEditingController(text: 'Pending');
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add $section'),
        content: SingleChildScrollView(child: Column(children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Candidate / Employee / Title', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: detail, maxLines: 3, decoration: const InputDecoration(labelText: 'Details / Notes', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: status, decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder())),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, name.text.trim().isNotEmpty), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => data[section]!.add({'name': name.text.trim(), 'detail': detail.text.trim(), 'status': status.text.trim(), 'date': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'}));
    }
    name.dispose(); detail.dispose(); status.dispose();
  }

  @override Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [Expanded(child: Text('Employee Lifecycle', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))), const Icon(Icons.timeline, size: 32)]),
        const SizedBox(height: 8),
        const Text('Manage the complete employee journey from recruitment to exit.'),
        const SizedBox(height: 16),
        ...sections.map(_sectionCard),
      ],
    );
  }

  Widget _sectionCard(String s) {
    final records = data[s]!;
    final children = <Widget>[];
    if (records.isEmpty) {
      children.add(const Padding(padding: EdgeInsets.all(16), child: Align(alignment: Alignment.centerLeft, child: Text('No records yet.'))));
    } else {
      for (var i = 0; i < records.length; i++) {
        final r = records[i];
        children.add(ListTile(
          title: Text(r['name'] ?? ''),
          subtitle: Text('${r['detail'] ?? ''}\n${r['status'] ?? ''} • ${r['date'] ?? ''}'),
          isThreeLine: true,
          trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() { records.removeAt(i); })),
        ));
      }
    }
    children.add(Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), child: Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: () => add(s), icon: const Icon(Icons.add), label: const Text('Add Record')))));
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Icon(_icon(s)),
        title: Text(s, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${records.length} record${records.length == 1 ? '' : 's'}'),
        children: children,
      ),
    );
  }

  IconData _icon(String s) {
    if (s == 'Recruitment') return Icons.person_search;
    if (s == 'Candidate') return Icons.badge;
    if (s == 'Interview') return Icons.forum;
    if (s == 'Offer') return Icons.description;
    if (s.contains('Joining')) return Icons.how_to_reg;
    if (s.contains('Probation')) return Icons.verified;
    if (s.contains('Transfer')) return Icons.swap_horiz;
    return Icons.exit_to_app;
  }
}
