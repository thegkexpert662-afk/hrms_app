import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class PayrollManagementScreen extends StatefulWidget {
  final HrmsService service;
  const PayrollManagementScreen({super.key, required this.service});
  @override State<PayrollManagementScreen> createState() => _PayrollManagementScreenState();
}

class _PayrollManagementScreenState extends State<PayrollManagementScreen> {
  final Map<String, PayrollRecord> payroll = {};
  final Map<String, List<String>> history = {};
  bool processed = false;

  PayrollRecord _record(String id) => payroll[id] ??= PayrollRecord(employeeId: id, basic: 30000, allowances: 8000, bonus: 2000, overtime: 0, deductions: 3000);
  String _money(double v) => '₹${v.toStringAsFixed(0)}';

  Future<void> _editSalary(Employee e) async {
    final r = _record(e.id);
    final basic = TextEditingController(text: r.basic.toStringAsFixed(0));
    final allowances = TextEditingController(text: r.allowances.toStringAsFixed(0));
    final bonus = TextEditingController(text: r.bonus.toStringAsFixed(0));
    final overtime = TextEditingController(text: r.overtime.toStringAsFixed(0));
    final deductions = TextEditingController(text: r.deductions.toStringAsFixed(0));
    double n(TextEditingController c) => double.tryParse(c.text) ?? 0;
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: Text('Salary • ${e.name}'),
      content: SingleChildScrollView(child: Column(children: [
        _field(basic, 'Basic Salary'), const SizedBox(height: 8), _field(allowances, 'Allowances'), const SizedBox(height: 8), _field(bonus, 'Bonus / Incentive'), const SizedBox(height: 8), _field(overtime, 'Overtime'), const SizedBox(height: 8), _field(deductions, 'PF / ESI / PT / TDS & Other Deductions'),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save'))],
    ));
    if (ok == true && mounted) setState(() {
      payroll[e.id] = PayrollRecord(employeeId: e.id, basic: n(basic), allowances: n(allowances), bonus: n(bonus), overtime: n(overtime), deductions: n(deductions));
    });
  }

  Widget _field(TextEditingController c, String label) => TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));

  void _process() {
    for (final e in widget.service.employees) {
      final r = _record(e.id);
      history.putIfAbsent(e.id, () => []).add('${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')} • ${_money(r.net)}');
    }
    setState(() => processed = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payroll processed successfully')));
  }

  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.service,
    builder: (_, __) => ListView(padding: const EdgeInsets.all(16), children: [
      _dashboard(), const SizedBox(height: 12), _structure(), const SizedBox(height: 12), _employees(), const SizedBox(height: 12), _processing(), const SizedBox(height: 12), _history(),
    ]),
  );

  Widget _dashboard() {
    final total = widget.service.employees.fold<double>(0, (v, e) => v + _record(e.id).net);
    return Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.payments, size: 28), const SizedBox(width: 10), Text('Payroll Dashboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))]),
      const SizedBox(height: 16), Wrap(spacing: 10, runSpacing: 10, children: [_stat('Employees', '${widget.service.employees.length}', Icons.people), _stat('Gross', _money(widget.service.employees.fold(0, (v, e) => v + _record(e.id).gross)), Icons.account_balance_wallet), _stat('Deductions', _money(widget.service.employees.fold(0, (v, e) => v + _record(e.id).deductions)), Icons.remove_circle_outline), _stat('Net Pay', _money(total), Icons.payments)]),
    ])));
  }

  Widget _stat(String label, String value, IconData icon) => SizedBox(width: 145, child: Card(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [Icon(icon), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), Text(label)])]))));

  Widget _structure() => Card(child: ExpansionTile(leading: const Icon(Icons.account_tree_outlined), title: const Text('Salary Structure', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Basic + allowances + bonus + overtime - deductions'), children: const [ListTile(title: Text('Standard structure'), subtitle: Text('Basic Salary • Allowances • Bonus/Incentive • Overtime • PF • ESI • PT • TDS'))]));

  Widget _employees() => Card(child: ExpansionTile(leading: const Icon(Icons.badge_outlined), title: const Text('Employee Salary', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${widget.service.employees.length} employee salary records'), children: widget.service.employees.map((e) { final r = _record(e.id); return ListTile(title: Text(e.name), subtitle: Text('${e.designation}\nBasic ${_money(r.basic)} • Allowances ${_money(r.allowances)} • Bonus ${_money(r.bonus)} • OT ${_money(r.overtime)}\nPF / ESI / PT / TDS & deductions: ${_money(r.deductions)}'), isThreeLine: true, trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_money(r.net), style: const TextStyle(fontWeight: FontWeight.w800)), IconButton(tooltip: 'Edit salary', onPressed: () => _editSalary(e), icon: const Icon(Icons.edit))])); }).toList());

  Widget _processing() => Card(child: ListTile(leading: Icon(processed ? Icons.check_circle : Icons.calculate), title: const Text('Payroll Processing', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(processed ? 'Current payroll has been processed' : 'Calculate and process current payroll'), trailing: FilledButton.icon(onPressed: _process, icon: const Icon(Icons.play_arrow), label: const Text('Process'))));

  Widget _history() => Card(child: ExpansionTile(leading: const Icon(Icons.receipt_long), title: const Text('Payslip / Salary History', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Processed salary records'), children: [
    if (history.isEmpty) const ListTile(title: Text('No processed salary history yet.')),
    ...history.entries.expand((x) { final e = widget.service.employees.where((v) => v.id == x.key); return x.value.reversed.map((h) => ListTile(title: Text(e.isEmpty ? x.key : e.first.name), subtitle: Text(h), leading: const Icon(Icons.description_outlined), trailing: OutlinedButton(onPressed: () => _showPayslip(e.isEmpty ? null : e.first, _record(x.key), h), child: const Text('Payslip')))); })
  ]));

  Future<void> _showPayslip(Employee? e, PayrollRecord r, String period) async => showDialog<void>(context: context, builder: (c) => AlertDialog(title: const Text('Payslip'), content: Text('${e?.name ?? r.employeeId}\n$period\n\nBasic: ${_money(r.basic)}\nAllowances: ${_money(r.allowances)}\nBonus/Incentive: ${_money(r.bonus)}\nOvertime: ${_money(r.overtime)}\nDeductions: ${_money(r.deductions)}\n\nNet Salary: ${_money(r.net)}'), actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))]));
}
