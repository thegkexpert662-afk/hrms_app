import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class LeaveManagementScreen extends StatefulWidget {
  final HrmsService service;
  const LeaveManagementScreen({super.key, required this.service});
  @override State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _applyLeave() async {
    if (widget.service.employees.isEmpty) return;
    String employeeId = widget.service.employees.first.id;
    String type = 'Casual Leave';
    DateTime from = DateTime.now();
    DateTime to = from;
    final reason = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (c, setDialog) => AlertDialog(
      title: const Text('Apply Leave'),
      content: SingleChildScrollView(child: Column(children: [
        DropdownButtonFormField<String>(value: employeeId, decoration: const InputDecoration(labelText: 'Employee', border: OutlineInputBorder()), items: widget.service.employees.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.name} (${e.id})'))).toList(), onChanged: (v) => setDialog(() => employeeId = v!)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Leave Type', border: OutlineInputBorder()), items: const ['Casual Leave', 'Sick Leave', 'Earned Leave', 'Unpaid Leave'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setDialog(() => type = v!)),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: OutlinedButton(onPressed: () async { final d = await showDatePicker(context: c, firstDate: DateTime(2020), lastDate: DateTime(2035), initialDate: from); if (d != null) setDialog(() { from = d; if (to.isBefore(from)) to = from; }); }, child: Text('From\n${_date(from)}'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () async { final d = await showDatePicker(context: c, firstDate: from, lastDate: DateTime(2035), initialDate: to); if (d != null) setDialog(() => to = d); }, child: Text('To\n${_date(to)}')))]),
        const SizedBox(height: 10), TextField(controller: reason, maxLines: 3, decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder())),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Submit'))],
    )));
    if (ok == true && mounted) {
      widget.service.applyLeave(LeaveRequest(id: 'LV${DateTime.now().millisecondsSinceEpoch}', employeeId: employeeId, type: type, from: from, to: to, reason: reason.text.trim()));
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave application submitted')));
    }
  }

  Future<void> _decide(LeaveRequest r, bool approved) async {
    widget.service.decideLeave(r.id, approved);
    setState(() {});
  }

  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.service,
    builder: (_, __) => ListView(padding: const EdgeInsets.all(16), children: [
      _dashboard(), const SizedBox(height: 12), _applyCard(), const SizedBox(height: 12),
      _balance(), const SizedBox(height: 12), _calendar(), const SizedBox(height: 12),
      _approval(), const SizedBox(height: 12), _history(),
    ]),
  );

  Widget _dashboard() {
    final pending = widget.service.leaves.where((l) => l.status == 'Pending').length;
    final approved = widget.service.leaves.where((l) => l.status == 'Approved').length;
    return Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.event_available, size: 28), const SizedBox(width: 10), Text('Leave Dashboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))]),
      const SizedBox(height: 16), Wrap(spacing: 10, runSpacing: 10, children: [
        _stat('Pending', '$pending', Icons.pending_actions), _stat('Approved', '$approved', Icons.check_circle_outline), _stat('Employees', '${widget.service.employees.length}', Icons.people_outline), _stat('On Leave', '${widget.service.onLeave}', Icons.beach_access),
      ])
    ])));
  }

  Widget _stat(String label, String value, IconData icon) => SizedBox(width: 145, child: Card(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [Icon(icon), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), Text(label)])]))));

  Widget _applyCard() => Card(child: ListTile(leading: const Icon(Icons.add_circle_outline), title: const Text('Apply Leave', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Submit a leave request with dates and reason'), trailing: FilledButton.icon(onPressed: _applyLeave, icon: const Icon(Icons.add), label: const Text('Apply'))));

  Widget _balance() => Card(child: ExpansionTile(leading: const Icon(Icons.account_balance_wallet_outlined), title: const Text('Leave Balance', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Available leave days by employee'), children: widget.service.employees.map((e) => ListTile(title: Text(e.name), subtitle: Text(e.department), trailing: Text('${widget.service.leaveBalances[e.id]?.toStringAsFixed(0) ?? '0'} days', style: const TextStyle(fontWeight: FontWeight.w800)))).toList()));

  Widget _calendar() => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Icon(Icons.calendar_month), const SizedBox(width: 8), const Text('Leave Calendar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), const Spacer(), IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month - 1)), icon: const Icon(Icons.chevron_left)), Text('${month.month}/${month.year}'), IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month + 1)), icon: const Icon(Icons.chevron_right))]),
    const SizedBox(height: 8),
    Wrap(spacing: 6, runSpacing: 6, children: List.generate(DateTime(month.year, month.month + 1, 0).day, (i) { final d = DateTime(month.year, month.month, i + 1); final count = widget.service.leaves.where((l) => l.status == 'Approved' && !d.isBefore(l.from) && !d.isAfter(l.to)).length; return Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), borderRadius: BorderRadius.circular(8)), child: Text('${d.day}\n$count', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: count > 0 ? FontWeight.w700 : FontWeight.normal))); }))
  ])));

  Widget _approval() => Card(child: ExpansionTile(leading: const Icon(Icons.approval), title: const Text('Leave Approval', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${widget.service.leaves.where((l) => l.status == 'Pending').length} pending request(s)'), children: [
    ...widget.service.leaves.where((l) => l.status == 'Pending').map((r) { final e = widget.service.employees.where((x) => x.id == r.employeeId); final name = e.isEmpty ? r.employeeId : e.first.name; return ListTile(title: Text(name), subtitle: Text('${r.type} • ${_date(r.from)} - ${_date(r.to)}\n${r.reason}'), isThreeLine: true, trailing: Wrap(children: [IconButton(tooltip: 'Approve', onPressed: () => _decide(r, true), icon: const Icon(Icons.check)), IconButton(tooltip: 'Reject', onPressed: () => _decide(r, false), icon: const Icon(Icons.close))])); })
  ]));

  Widget _history() => Card(child: ExpansionTile(leading: const Icon(Icons.history), title: const Text('Leave History', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${widget.service.leaves.length} request(s)'), children: [
    if (widget.service.leaves.isEmpty) const ListTile(title: Text('No leave history yet.')),
    ...widget.service.leaves.reversed.map((r) { final e = widget.service.employees.where((x) => x.id == r.employeeId); return ListTile(title: Text(e.isEmpty ? r.employeeId : e.first.name), subtitle: Text('${r.type} • ${_date(r.from)} - ${_date(r.to)} • ${r.days} day(s)'), trailing: Chip(label: Text(r.status))); })
  ]));
}
