import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class ModuleScreen extends StatefulWidget {
  final HrmsService service;
  final String title;
  final IconData icon;
  final List<String> sections;
  const ModuleScreen({super.key, required this.service, required this.title, required this.icon, required this.sections});
  @override State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  final Map<String, List<String>> records = {};
  void addRecord(String section) {
    final name = TextEditingController();
    final details = TextEditingController();
    showDialog(context: context, builder: (dialogContext) => AlertDialog(
      title: Text('Add $section'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Name / Title', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: details, maxLines: 3, decoration: const InputDecoration(labelText: 'Details', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          if (name.text.trim().isEmpty) return;
          records.putIfAbsent(section, () => <String>[]).add('${name.text.trim()} — ${details.text.trim()}');
          Navigator.pop(dialogContext);
          setState(() {});
        }, child: const Text('Save')),
      ],
    ));
  }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Row(children: [CircleAvatar(child: Icon(widget.icon)), const SizedBox(width: 12), Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)))]),
    const SizedBox(height: 8), Text('${widget.sections.length} features'), const SizedBox(height: 16),
    ...widget.sections.map((section) {
      final list = records[section] ?? const <String>[];
      return Card(margin: const EdgeInsets.only(bottom: 10), child: ExpansionTile(
        leading: Icon(widget.icon), title: Text(section), subtitle: Text('${list.length} record(s)'),
        children: [
          Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.all(12), child: FilledButton.icon(onPressed: () => addRecord(section), icon: const Icon(Icons.add), label: const Text('Add')))),
          ...list.asMap().entries.map((entry) => ListTile(title: Text(entry.value), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => records[section]!.removeAt(entry.key))))),
        ],
      ));
    }),
  ]);
}

class DashboardScreen extends StatelessWidget {
  final HrmsService service;
  const DashboardScreen({super.key, required this.service});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
    const SizedBox(height: 6), Text('Today • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
    const SizedBox(height: 18),
    GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
      children: [_stat('Employees', service.employees.length, Icons.people), _stat('Present', service.present, Icons.check_circle), _stat('Absent', service.employees.length - service.present - service.late - service.onLeave, Icons.person_off), _stat('Late', service.late, Icons.schedule), _stat('Early Exit', service.earlyExit, Icons.logout), _stat('WFH', service.wfh, Icons.home_work), _stat('On Leave', service.onLeave, Icons.event_busy), _stat('Pending Leave', service.pendingLeaves, Icons.pending_actions)]),
    const SizedBox(height: 18), Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Attendance Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 12), Text('Present: ${service.present}'), Text('Late: ${service.late}'), Text('WFH: ${service.wfh}'), Text('On Leave: ${service.onLeave}'), Text('Pending Leave: ${service.pendingLeaves}')]))),
  ]);
  Widget _stat(String title, int value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [Icon(icon, size: 28), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), Text(title)]))])));
}

class EmployeeScreen extends StatefulWidget {
  final HrmsService service;
  const EmployeeScreen({super.key, required this.service});
  @override State<EmployeeScreen> createState() => _EmployeeScreenState();
}
class _EmployeeScreenState extends State<EmployeeScreen> {
  void add() {
    final name = TextEditingController(); final dept = TextEditingController(); final designation = TextEditingController(); final phone = TextEditingController(); final email = TextEditingController();
    showDialog(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Add Employee'), content: SingleChildScrollView(child: Column(children: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Full Name *')), TextField(controller: dept, decoration: const InputDecoration(labelText: 'Department')), TextField(controller: designation, decoration: const InputDecoration(labelText: 'Designation')), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')), TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () {
      if (name.text.trim().isEmpty) return;
      final id = 'EMP${(widget.service.employees.length + 1).toString().padLeft(3, '0')}';
      widget.service.addEmployee(Employee(id: id, name: name.text.trim(), department: dept.text.trim(), designation: designation.text.trim().isEmpty ? 'Employee' : designation.text.trim(), manager: 'HR Admin', joiningDate: DateTime.now(), employmentType: 'Full Time', status: 'Active', phone: phone.text.trim(), email: email.text.trim()));
      Navigator.pop(dialogContext); setState(() {});
    }, child: const Text('Save'))]));
  }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Row(children: [const Expanded(child: Text('Employee Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))), FilledButton.icon(onPressed: add, icon: const Icon(Icons.add), label: const Text('Add'))]),
    const SizedBox(height: 16), ...widget.service.employees.map((employee) => Card(child: ListTile(leading: CircleAvatar(child: Text(employee.name.isEmpty ? '?' : employee.name[0].toUpperCase())), title: Text(employee.name), subtitle: Text('${employee.id} • ${employee.department}\n${employee.designation} • ${employee.phone}\n${employee.email}'), isThreeLine: true, trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () { widget.service.removeEmployee(employee.id); setState(() {}); }))))
  ]);
}

class AttendanceScreen extends StatefulWidget {
  final HrmsService service;
  const AttendanceScreen({super.key, required this.service});
  @override State<AttendanceScreen> createState() => _AttendanceScreenState();
}
class _AttendanceScreenState extends State<AttendanceScreen> {
  String? employee;
  @override Widget build(BuildContext context) {
    if (widget.service.employees.isEmpty) return const Center(child: Text('Add an employee first'));
    employee ??= widget.service.employees.first.id;
    if (!widget.service.employees.any((e) => e.id == employee)) employee = widget.service.employees.first.id;
    final id = employee!; final record = widget.service.todayFor(id);
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Attendance', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)), const SizedBox(height: 16),
      DropdownButtonFormField<String>(initialValue: id, decoration: const InputDecoration(labelText: 'Employee', border: OutlineInputBorder()), items: widget.service.employees.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.name} (${e.id})'))).toList(), onChanged: (v) => setState(() => employee = v)),
      const SizedBox(height: 16), Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
        Text(record?.punchIn == null ? 'Not punched in' : 'Punched in: ${_time(record!.punchIn!)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        if (record?.punchOut != null) Text('Punched out: ${_time(record!.punchOut!)}'), const SizedBox(height: 16),
        Row(children: [Expanded(child: FilledButton.icon(onPressed: record?.punchIn == null ? () { widget.service.punchIn(id); setState(() {}); } : null, icon: const Icon(Icons.login), label: const Text('Punch In'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: record?.punchIn != null && record?.punchOut == null ? () { widget.service.punchOut(id); setState(() {}); } : null, icon: const Icon(Icons.logout), label: const Text('Punch Out')))]),
        if (record != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text('Status: ${record.status} • Working ${record.workingTime.inHours}h ${record.workingTime.inMinutes % 60}m • OT ${record.overtime.inHours}h ${record.overtime.inMinutes % 60}m')),
      ]))),
      const SizedBox(height: 12), Card(child: ListTile(title: const Text('Attendance History'), subtitle: Text('${widget.service.attendance.length} record(s)'))),
    ]);
  }
  String _time(DateTime value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class LeaveScreen extends StatefulWidget {
  final HrmsService service;
  const LeaveScreen({super.key, required this.service});
  @override State<LeaveScreen> createState() => _LeaveScreenState();
}
class _LeaveScreenState extends State<LeaveScreen> {
  void apply() {
    if (widget.service.employees.isEmpty) return;
    String emp = widget.service.employees.first.id; String type = 'Casual Leave'; DateTime from = DateTime.now(); DateTime to = DateTime.now(); final reason = TextEditingController();
    showDialog(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialog) => AlertDialog(title: const Text('Apply Leave'), content: SingleChildScrollView(child: Column(children: [
      DropdownButtonFormField<String>(initialValue: emp, decoration: const InputDecoration(labelText: 'Employee'), items: widget.service.employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), onChanged: (v) { if (v != null) setDialog(() => emp = v); }),
      DropdownButtonFormField<String>(initialValue: type, decoration: const InputDecoration(labelText: 'Leave Type'), items: const ['Casual Leave', 'Sick Leave', 'Earned Leave', 'Unpaid Leave'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) { if (v != null) setDialog(() => type = v); }),
      ListTile(title: Text('From ${from.day}/${from.month}/${from.year}'), onTap: () async { final value = await showDatePicker(context: dialogContext, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: from); if (value != null) setDialog(() => from = value); }),
      ListTile(title: Text('To ${to.day}/${to.month}/${to.year}'), onTap: () async { final value = await showDatePicker(context: dialogContext, firstDate: from, lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: to.isBefore(from) ? from : to); if (value != null) setDialog(() => to = value); }),
      TextField(controller: reason, maxLines: 2, decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder())),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () { if (reason.text.trim().isEmpty || to.isBefore(from)) return; widget.service.applyLeave(LeaveRequest(id: 'L${widget.service.leaves.length + 1}', employeeId: emp, type: type, from: from, to: to, reason: reason.text.trim())); Navigator.pop(dialogContext); setState(() {}); }, child: const Text('Submit'))]));
  }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Row(children: [const Expanded(child: Text('Leave Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))), FilledButton.icon(onPressed: apply, icon: const Icon(Icons.add), label: const Text('Apply'))]), const SizedBox(height: 16),
    ...widget.service.employees.map((e) => Card(child: ListTile(title: Text(e.name), subtitle: Text('Balance: ${widget.service.leaveBalances[e.id] ?? 0} days • Requests: ${widget.service.leaves.where((l) => l.employeeId == e.id).length}')))),
    ...widget.service.leaves.map((leave) => Card(child: ListTile(title: Text('${leave.type} • ${leave.days} day(s)'), subtitle: Text('${leave.employeeId} • ${leave.reason}'), trailing: Chip(label: Text(leave.status)), onTap: leave.status == 'Pending' ? () => _decision(leave) : null)))
  ]);
  void _decision(LeaveRequest leave) { showDialog(context: context, builder: (dialogContext) => AlertDialog(title: Text(leave.type), content: Text('${leave.from.day}/${leave.from.month}/${leave.from.year} → ${leave.to.day}/${leave.to.month}/${leave.to.year}\n${leave.reason}'), actions: [TextButton(onPressed: () { widget.service.decideLeave(leave.id, false); Navigator.pop(dialogContext); setState(() {}); }, child: const Text('Reject')), FilledButton(onPressed: () { widget.service.decideLeave(leave.id, true); Navigator.pop(dialogContext); setState(() {}); }, child: const Text('Approve'))])); }
}

class LifecycleScreen extends ModuleScreen { LifecycleScreen({super.key, required HrmsService service}) : super(service: service, title: 'Employee Lifecycle', icon: Icons.timeline, sections: const ['Recruitment','Candidate Management','Interview','Selection','Offer Letter','Joining','Onboarding','Probation','Confirmation','Transfer','Promotion','Increment','Resignation','Exit','Full & Final Settlement','Relieving Letter','Experience Letter']); }
class PayrollScreen extends ModuleScreen { PayrollScreen({super.key, required HrmsService service}) : super(service: service, title: 'Payroll', icon: Icons.payments, sections: const ['Salary Structure','Basic Salary','Allowances','Bonuses','Incentives','Deductions','PF','ESI','Professional Tax','TDS','Overtime','Salary Calculation','Payroll Processing','Payslip','Salary History','Bank Transfer Data','Full & Final Settlement']); }
class DepartmentScreen extends ModuleScreen { DepartmentScreen({super.key, required HrmsService service}) : super(service: service, title: 'Department & Organization', icon: Icons.account_tree, sections: const ['Departments','Designations','Teams','Reporting Structure','Managers','Organization Chart','Branches','Locations']); }
class ShiftScreen extends ModuleScreen { ShiftScreen({super.key, required HrmsService service}) : super(service: service, title: 'Shift & Roster', icon: Icons.schedule, sections: const ['Create Shift','Assign Shift','Shift Timing','Multiple Shifts','Night Shift','Rotational Shift','Weekly Roster','Employee Roster','Shift Change Request']); }
class PerformanceScreen extends ModuleScreen { PerformanceScreen({super.key, required HrmsService service}) : super(service: service, title: 'Performance Management', icon: Icons.insights, sections: const ['Goals','KPI','Performance Review','Self Assessment','Manager Assessment','Rating','Appraisal','Promotion','Increment','Performance History']); }
class DocumentsScreen extends ModuleScreen { DocumentsScreen({super.key, required HrmsService service}) : super(service: service, title: 'Document Management', icon: Icons.folder, sections: const ['Employee Documents','Company Documents','Offer Letter','Appointment Letter','Joining Letter','Salary Slip','Increment Letter','Promotion Letter','Experience Letter','Relieving Letter','Document Verification','Document Expiry Alerts']); }
class RecruitmentScreen extends ModuleScreen { RecruitmentScreen({super.key, required HrmsService service}) : super(service: service, title: 'Recruitment', icon: Icons.work, sections: const ['Job Openings','Applications','Candidate Profiles','Resume','Interview','Interview Feedback','Shortlist','Selection','Rejection','Offer Management']); }
class EssScreen extends ModuleScreen { EssScreen({super.key, required HrmsService service}) : super(service: service, title: 'Employee Self Service', icon: Icons.person, sections: const ['My Profile','My Attendance','My Punch In/Out','My Leave','My Leave Balance','My Payslip','My Documents','My Requests','My Performance','My Assets','Company Announcements']); }
class ExpenseScreen extends ModuleScreen { ExpenseScreen({super.key, required HrmsService service}) : super(service: service, title: 'Expense Management', icon: Icons.receipt_long, sections: const ['Expense Claim','Travel Expense','Food Expense','Other Expense','Bill Upload','Approval','Rejection','Reimbursement','Expense History']); }
class AssetsScreen extends ModuleScreen { AssetsScreen({super.key, required HrmsService service}) : super(service: service, title: 'Asset Management', icon: Icons.devices, sections: const ['Laptop','Desktop','Mobile','ID Card','SIM','Accessories','Asset Assignment','Asset Return','Asset History']); }
class NotificationsScreen extends ModuleScreen { NotificationsScreen({super.key, required HrmsService service}) : super(service: service, title: 'Notifications', icon: Icons.notifications, sections: const ['Push Notifications','Leave Notification','Attendance Notification','Late Notification','Punch Reminder','Missing Punch Alert','Payroll Notification','Announcement','Birthday','Work Anniversary']); }
class CommunicationScreen extends ModuleScreen { CommunicationScreen({super.key, required HrmsService service}) : super(service: service, title: 'Company Communication', icon: Icons.campaign, sections: const ['Announcements','Notices','Circulars','Company Events','Holiday Announcement','Important Updates']); }
class ReportsScreen extends ModuleScreen { ReportsScreen({super.key, required HrmsService service}) : super(service: service, title: 'Reports & Analytics', icon: Icons.analytics, sections: const ['Employee Report','Attendance Report','Leave Report','Payroll Report','Overtime Report','Performance Report','Recruitment Report','Expense Report','Asset Report','Department Report','Monthly HR Report','PDF Export','Excel Export']); }
class AdminScreen extends ModuleScreen { AdminScreen({super.key, required HrmsService service}) : super(service: service, title: 'Admin & Security', icon: Icons.security, sections: const ['Roles','Permissions','Login','OTP','Password','Sessions','Audit Log','Activity Log','Backup']); }
class SettingsScreen extends ModuleScreen { SettingsScreen({super.key, required HrmsService service}) : super(service: service, title: 'Company Settings', icon: Icons.settings, sections: const ['Company','Branches','Departments','Designations','Working Days','Holidays','Leave Rules','Attendance Rules','Shift Rules','Payroll Rules','Notifications','Approval Workflow']); }
class AdvancedAttendanceScreen extends ModuleScreen { AdvancedAttendanceScreen({super.key, required HrmsService service}) : super(service: service, title: 'Advanced Attendance', icon: Icons.gps_fixed, sections: const ['GPS','Geofence','Office Verification','IP Verification','Device Verification','Selfie','Face Verification','QR Attendance','Biometric','WFH','On Duty','Attendance Approval']); }
