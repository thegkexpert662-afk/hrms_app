import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class EssManagementScreen extends StatefulWidget {
  final HrmsService service;
  const EssManagementScreen({super.key, required this.service});
  @override State<EssManagementScreen> createState() => _EssManagementScreenState();
}

class _EssManagementScreenState extends State<EssManagementScreen> {
  int selected = 0;
  final pages = const ['My Profile','My Attendance','My Punch','My Leave','My Payslip','My Documents','My Requests','My Performance / Assets'];
  final icons = const [Icons.person,Icons.calendar_month,Icons.fingerprint,Icons.event_note,Icons.receipt_long,Icons.folder,Icons.request_page,Icons.insights];

  @override Widget build(BuildContext context) => Column(children: [
    SizedBox(height: 104, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(12), itemCount: pages.length, itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(pages[i]), avatar: Icon(icons[i], size: 18), selected: selected == i, onSelected: (_) => setState(() => selected = i))))),
    const Divider(height: 1),
    Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: _page(selected)))
  ]);

  Widget _page(int i) {
    final employee = widget.service.employees.isNotEmpty ? widget.service.employees.first : null;
    switch (i) {
      case 0: return _profile(employee);
      case 1: return _attendance(employee);
      case 2: return _punch(employee);
      case 3: return _leave(employee);
      case 4: return _payslip(employee);
      case 5: return _documents(employee);
      case 6: return _requests();
      default: return _performanceAssets(employee);
    }
  }

  Widget _header(String title, String subtitle, IconData icon) => Card(child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle)));
  Widget _profile(Employee? e) => ListView(padding: const EdgeInsets.all(16), children: [
    _header('My Profile', e?.name ?? 'Employee profile', Icons.person),
    if (e == null) const Card(child: ListTile(title: Text('No employee profile available.'))),
    if (e != null) ...[_field('Employee ID', e.id),_field('Name',e.name),_field('Department',e.department),_field('Designation',e.designation),_field('Manager',e.manager),_field('Phone',e.phone),_field('Email',e.email),_field('Joining Date',e.joiningDate.toString().split(' ').first),_field('Employment Type',e.employmentType),_field('Status',e.status)]
  ]);
  Widget _field(String a, String b) => Card(child: ListTile(title: Text(a), subtitle: Text(b.isEmpty ? 'Not available' : b)));

  Widget _attendance(Employee? e) {
    final rows = e == null ? [] : widget.service.attendance.where((a) => a.employeeId == e.id).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [_header('My Attendance','Attendance history and working hours',Icons.calendar_month), if(rows.isEmpty) const Card(child: ListTile(title: Text('No attendance records yet.'))) else ...rows.map((a)=>Card(child:ListTile(title:Text(a.date.toString().split(' ').first),subtitle:Text('Status: ${a.status} • Hours: ${a.workingHours.toStringAsFixed(1)}'))))]);
  }

  Widget _punch(Employee? e) => ListView(padding: const EdgeInsets.all(16), children: [
    _header('My Punch','Punch in / punch out from your employee account',Icons.fingerprint),
    Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const Icon(Icons.access_time, size: 54), const SizedBox(height: 12), Text(e?.name ?? 'No employee selected', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 18), Row(mainAxisAlignment: MainAxisAlignment.center, children: [FilledButton.icon(onPressed: e == null ? null : () { widget.service.punchIn(e.id); setState(() {}); }, icon: const Icon(Icons.login), label: const Text('Punch In')), const SizedBox(width: 12), OutlinedButton.icon(onPressed: e == null ? null : () { widget.service.punchOut(e.id); setState(() {}); }, icon: const Icon(Icons.logout), label: const Text('Punch Out'))])]))),
  ]);

  Widget _leave(Employee? e) { final list = e == null ? [] : widget.service.leaves.where((x)=>x.employeeId==e.id).toList(); return ListView(padding: const EdgeInsets.all(16), children: [_header('My Leave','Apply and view your leave history',Icons.event_note), Card(child: ListTile(title: const Text('Leave Balance'), subtitle: Text(e == null ? 'No employee selected' : '${widget.service.leaveBalances[e.id] ?? 0} day(s) available'))), if(list.isEmpty) const Card(child: ListTile(title: Text('No leave requests yet.'))) else ...list.map((l)=>Card(child:ListTile(title:Text(l.type),subtitle:Text('${l.from.toString().split(' ').first} → ${l.to.toString().split(' ').first} • ${l.status}'))))]); }

  Widget _payslip(Employee? e) => ListView(padding: const EdgeInsets.all(16), children: [_header('My Payslip','Salary and payslip history',Icons.receipt_long), Card(child: ListTile(title: Text(e?.name ?? 'No employee'), subtitle: const Text('Payslip details will appear here after payroll processing.'), trailing: const Icon(Icons.chevron_right))) ]);
  Widget _documents(Employee? e) => ListView(padding: const EdgeInsets.all(16), children: [_header('My Documents','Your employee documents',Icons.folder), const Card(child: ListTile(leading: Icon(Icons.description), title: Text('Documents'), subtitle: Text('No personal documents available in ESS yet.')))]);
  Widget _requests() => ListView(padding: const EdgeInsets.all(16), children: [_header('My Requests','Track requests submitted by you',Icons.request_page), const Card(child: ListTile(title: Text('No requests yet.'), subtitle: Text('Attendance corrections, HR requests and other requests will appear here.')))]);
  Widget _performanceAssets(Employee? e) => ListView(padding: const EdgeInsets.all(16), children: [_header('My Performance / Assets','Performance records and assigned assets',Icons.insights), const Card(child: ListTile(title: Text('My Performance'), subtitle: Text('Goals, KPI, appraisal and review details will appear here.'))), const Card(child: ListTile(title: Text('My Assets'), subtitle: Text('Assigned laptop, mobile, ID, SIM and accessories will appear here.')))]);
}
