import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class AttendanceManagementScreen extends StatefulWidget {
  final HrmsService service;
  const AttendanceManagementScreen({super.key, required this.service});
  @override State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  final Map<String, String> corrections = {};
  final Map<String, String> approvals = {};

  String _fmt(DateTime? d) => d == null ? '--' : '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _duration(Duration d) => '${d.inHours}h ${(d.inMinutes % 60).toString().padLeft(2, '0')}m';
  List<AttendanceRecord> get records => widget.service.attendance.reversed.toList();

  Future<void> _correct(AttendanceRecord r) async {
    final inC = TextEditingController(text: _fmt(r.punchIn));
    final outC = TextEditingController(text: _fmt(r.punchOut));
    final reasonC = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Missing / Wrong Punch Correction'),
      content: SingleChildScrollView(child: Column(children: [
        Text('Date: ${_date(r.date)}'), const SizedBox(height: 12),
        TextField(controller: inC, decoration: const InputDecoration(labelText: 'Punch In (HH:MM)', border: OutlineInputBorder())),
        const SizedBox(height: 10), TextField(controller: outC, decoration: const InputDecoration(labelText: 'Punch Out (HH:MM)', border: OutlineInputBorder())),
        const SizedBox(height: 10), TextField(controller: reasonC, maxLines: 2, decoration: const InputDecoration(labelText: 'Correction reason', border: OutlineInputBorder())),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Submit'))],
    ));
    if (ok == true && mounted) {
      setState(() => corrections['${r.employeeId}_${r.date}'] = '${inC.text} → ${outC.text} • ${reasonC.text}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correction submitted for approval')));
    }
  }

  Future<void> _report() async {
    final all = widget.service.attendance;
    final working = all.fold<Duration>(Duration.zero, (v, r) => v + r.workingTime);
    await showDialog<void>(context: context, builder: (c) => AlertDialog(
      title: const Text('Attendance Report'),
      content: Text('Total punches: ${all.length}\nPresent records: ${all.where((r) => r.status == 'Present').length}\nLate: ${all.where((r) => r.status == 'Late').length}\nEarly Exit: ${all.where((r) => r.status == 'Early Exit').length}\nWFH: ${all.where((r) => r.wfh).length}\nTotal working time: ${_duration(working)}'),
      actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
    ));
  }

  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.service,
    builder: (_, __) => ListView(padding: const EdgeInsets.all(16), children: [
      _punchCard(), const SizedBox(height: 12), _calendar(), const SizedBox(height: 12),
      _history(), const SizedBox(height: 12), _approval(), const SizedBox(height: 12), _reportCard(),
    ]),
  );

  Widget _punchCard() {
    final now = DateTime.now();
    final items = widget.service.employees.map((e) => MapEntry(e, widget.service.todayFor(e.id))).toList();
    return Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.access_time, size: 28), const SizedBox(width: 10), Expanded(child: Text('Punch In / Out', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))), Text(_date(now))]),
      const SizedBox(height: 8),
      const Text('Record today’s attendance for employees'),
      const SizedBox(height: 10),
      ...items.map((x) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Text(x.key.name.substring(0, 1))),
        title: Text(x.key.name),
        subtitle: Text(x.value == null ? 'Not punched in' : '${x.value!.status} • In ${_fmt(x.value!.punchIn)} • Out ${_fmt(x.value!.punchOut)}'),
        trailing: Wrap(children: [
          if (x.value?.punchIn == null) IconButton(tooltip: 'Punch In', onPressed: () => widget.service.punchIn(x.key.id), icon: const Icon(Icons.login)),
          if (x.value?.punchIn != null && x.value?.punchOut == null) IconButton(tooltip: 'Punch Out', onPressed: () => widget.service.punchOut(x.key.id), icon: const Icon(Icons.logout)),
        ]),
      )),
    ])));
  }

  Widget _calendar() => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Icon(Icons.calendar_month), const SizedBox(width: 8), const Text('Monthly Calendar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), const Spacer(), IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month - 1)), icon: const Icon(Icons.chevron_left)), Text('${month.month}/${month.year}'), IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month + 1)), icon: const Icon(Icons.chevron_right))]),
    const SizedBox(height: 8),
    Wrap(spacing: 6, runSpacing: 6, children: List.generate(DateTime(month.year, month.month + 1, 0).day, (i) {
      final d = DateTime(month.year, month.month, i + 1);
      final count = widget.service.attendance.where((r) => r.date.year == d.year && r.date.month == d.month && r.date.day == d.day).length;
      return Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), borderRadius: BorderRadius.circular(8)), child: Text('${d.day}\n$count', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: count > 0 ? FontWeight.w700 : FontWeight.normal)));
    }))
  ])));

  Widget _history() => Card(child: ExpansionTile(leading: const Icon(Icons.history), title: const Text('Attendance History', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${records.length} attendance record(s)'), children: [
    if (records.isEmpty) const ListTile(title: Text('No attendance history yet.')),
    ...records.map((r) {
      final matches = widget.service.employees.where((x) => x.id == r.employeeId);
      final e = matches.isEmpty ? null : matches.first;
      return ListTile(title: Text(e?.name ?? r.employeeId), subtitle: Text('${_date(r.date)} • ${r.status}\nIn ${_fmt(r.punchIn)} • Out ${_fmt(r.punchOut)} • ${_duration(r.workingTime)}'), isThreeLine: true, trailing: IconButton(tooltip: 'Correct punch', onPressed: () => _correct(r), icon: const Icon(Icons.edit_calendar)));
    })
  ]));

  Widget _approval() => Card(child: ExpansionTile(leading: const Icon(Icons.fact_check), title: const Text('Attendance Approval', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Review submitted corrections'), children: [
    if (corrections.isEmpty) const ListTile(title: Text('No correction requests.')),
    ...corrections.entries.map((x) {
      final approved = approvals[x.key];
      return ListTile(title: Text(x.key), subtitle: Text(x.value), trailing: approved == null ? Wrap(children: [
        IconButton(tooltip: 'Approve', onPressed: () => setState(() => approvals[x.key] = 'Approved'), icon: const Icon(Icons.check)),
        IconButton(tooltip: 'Reject', onPressed: () => setState(() => approvals[x.key] = 'Rejected'), icon: const Icon(Icons.close)),
      ]) : Chip(label: Text(approved)));
    })
  ]));

  Widget _reportCard() => Card(child: ListTile(leading: const Icon(Icons.assessment), title: const Text('Attendance Reports', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('View attendance summary and working-hour totals'), trailing: FilledButton.icon(onPressed: _report, icon: const Icon(Icons.bar_chart), label: const Text('View')));
}
