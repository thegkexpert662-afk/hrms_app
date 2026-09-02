import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class HrmsHome extends StatefulWidget {
  final HrmsService service;
  const HrmsHome({super.key, required this.service});
  @override State<HrmsHome> createState() => _HrmsHomeState();
}

class _HrmsHomeState extends State<HrmsHome> {
  int selected = 0;
  HrmsService get s => widget.service;
  @override void initState() { super.initState(); s.addListener(_refresh); }
  @override void dispose() { s.removeListener(_refresh); super.dispose(); }
  void _refresh() => setState(() {});

  @override Widget build(BuildContext context) {
    final title = s.modules[selected];
    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), actions: [
        IconButton(onPressed: _showSearch, icon: const Icon(Icons.search)),
        IconButton(onPressed: () => setState(() {}), icon: const Icon(Icons.refresh)),
        const Padding(padding: EdgeInsets.only(right: 16), child: CircleAvatar(child: Icon(Icons.person))),
      ]),
      drawer: Drawer(child: SafeArea(child: Column(children: [
        const ListTile(leading: CircleAvatar(child: Icon(Icons.business)), title: Text('HRMS MANAGEMENT', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('Human Resource Management System')),
        const Divider(), Expanded(child: ListView.builder(itemCount: s.modules.length, itemBuilder: (_, i) => ListTile(selected: selected == i, leading: Icon(_icon(i)), title: Text(s.modules[i]), onTap: () { setState(() => selected = i); Navigator.pop(context); }))),
      ]))),
      body: _body(selected),
    );
  }

  IconData _icon(int i) { const a = [Icons.dashboard, Icons.people, Icons.timeline, Icons.access_time, Icons.event_available, Icons.payments, Icons.account_tree, Icons.schedule, Icons.insights, Icons.folder, Icons.work, Icons.person, Icons.receipt_long, Icons.devices, Icons.notifications, Icons.campaign, Icons.analytics, Icons.security, Icons.settings, Icons.gps_fixed]; return a[i]; }

  Widget _body(int i) {
    switch (i) {
      case 0: return _dashboard();
      case 1: return _employees();
      case 3: case 19: return _attendance();
      case 4: return _leave();
      case 5: return _payroll();
      default: return _module(s.modules[i]);
    }
  }

  Widget _dashboard() => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Good morning, HR Admin', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
    Text('${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • Company HR Overview'), const SizedBox(height: 18),
    Wrap(spacing: 12, runSpacing: 12, children: [
      _stat('Total Employees', s.employees.length, Icons.people), _stat('Present', s.present, Icons.check_circle),
      _stat('Absent', (s.employees.length - s.present - s.late - s.earlyExit - s.onLeave).clamp(0, 999), Icons.person_off),
      _stat('On Leave', s.onLeave, Icons.event_busy), _stat('Late', s.late, Icons.schedule), _stat('Early Exit', s.earlyExit, Icons.logout),
      _stat('Work From Home', s.wfh, Icons.home_work), _stat('Pending Leave', s.pendingLeaves, Icons.pending_actions),
      _stat('Pending Requests', s.pendingLeaves, Icons.task_alt),
    ]), const SizedBox(height: 20),
    _panel('Attendance Summary', Column(children: [_bar('Present', s.present), _bar('Late', s.late), _bar('On Leave', s.onLeave), _bar('WFH', s.wfh)])),
    const SizedBox(height: 16), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _panel('Upcoming Holidays', const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('15 Aug • Independence Day'), SizedBox(height: 8), Text('2 Oct • Gandhi Jayanti'), SizedBox(height: 8), Text('25 Dec • Christmas')] ))), const SizedBox(width: 12), Expanded(child: _panel('People Events', const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('🎂 Birthdays • 2'), SizedBox(height: 8), Text('🏆 Work Anniversaries • 1'), SizedBox(height: 8), Text('👋 New Joiners • 1')])))]),
  ]);

  Widget _stat(String label, int value, IconData icon) => SizedBox(width: 170, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 28), const SizedBox(height: 10), Text('$value', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)), Text(label)]))));
  Widget _panel(String title, Widget child) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 14), child])));
  Widget _bar(String name, int value) { final total = s.employees.length; return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [SizedBox(width: 100, child: Text(name)), Expanded(child: LinearProgressIndicator(value: total == 0 ? 0 : value / total, minHeight: 9)), const SizedBox(width: 10), Text('$value')])); }

  Widget _employees() => ListView(padding: const EdgeInsets.all(16), children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Employees (${s.employees.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), FilledButton.icon(onPressed: _addEmployee, icon: const Icon(Icons.add), label: const Text('Add Employee'))]), const SizedBox(height: 12),
    ...s.employees.map((e) => Card(child: ListTile(leading: CircleAvatar(child: Text(e.name.isEmpty ? '?' : e.name[0])), title: Text(e.name), subtitle: Text('${e.id} • ${e.designation}\n${e.department} • ${e.employmentType} • ${e.status}'), isThreeLine: true, trailing: PopupMenuButton<String>(onSelected: (v) { if (v == 'delete') s.removeEmployee(e.id); else _editEmployee(e); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit Profile')), PopupMenuItem(value: 'delete', child: Text('Delete'))])))),
  ]);

  Future<void> _addEmployee() async { final data = await _employeeForm(); if (data == null) return; s.addEmployee(Employee(id: 'EMP${(s.employees.length + 1).toString().padLeft(3, '0')}', name: data[0], department: data[1], designation: data[2], manager: data[3], joiningDate: DateTime.now(), employmentType: data[4], status: 'Active', phone: data[5], email: data[6])); }
  Future<void> _editEmployee(Employee e) async { final data = await _employeeForm(e); if (data == null) return; e.name=data[0]; e.department=data[1]; e.designation=data[2]; e.manager=data[3]; e.employmentType=data[4]; e.phone=data[5]; e.email=data[6]; s.updateEmployee(e); }

  Future<List<String>?> _employeeForm([Employee? e]) async {
    final c = List.generate(7, (i) => TextEditingController(text: e == null ? '' : [e.name,e.department,e.designation,e.manager,e.employmentType,e.phone,e.email][i]));
    return showDialog<List<String>>(context: context, builder: (_) => AlertDialog(title: Text(e == null ? 'Add Employee' : 'Employee Profile'), content: SizedBox(width: 420, child: SingleChildScrollView(child: Column(children: [for (int i=0;i<c.length;i++) Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller:c[i], decoration: InputDecoration(labelText:['Full Name','Department','Designation','Reporting Manager','Employment Type','Phone','Email'][i], border: const OutlineInputBorder())))]))), actions: [TextButton(onPressed:()=>Navigator.pop(context), child:const Text('Cancel')), FilledButton(onPressed:()=>Navigator.pop(context,c.map((x)=>x.text.trim()).toList()),child:const Text('Save'))]));
  }

  Widget _attendance() => ListView(padding: const EdgeInsets.all(16), children: [
    _panel('Punch In / Punch Out', Column(children: s.employees.map((e) { final r=s.todayFor(e.id); return Card(child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [CircleAvatar(child: Text(e.name[0])), const SizedBox(width:10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${e.id} • Shift 09:30–18:30'), Text(r?.punchIn == null ? 'Not punched in' : 'In ${_time(r!.punchIn!)} • Effective ${_dur(r.workingTime)} • OT ${_dur(r.overtime)}')])) , if(r?.punchIn==null) FilledButton(onPressed:()=>s.punchIn(e.id),child:const Text('Punch In')) else if(r?.punchOut==null) OutlinedButton(onPressed:()=>s.punchOut(e.id),child:const Text('Punch Out')) else Chip(label:Text(r!.status))]))); }).toList())),
    const SizedBox(height:16), _panel('Attendance Rules', const Wrap(spacing:16,runSpacing:10,children:[Text('Shift Start 09:30'),Text('Shift End 18:30'),Text('Grace 15 min'),Text('Late Threshold 10:00'),Text('Minimum 8 hours'),Text('Overtime after 8 hours'),Text('Break rules'),Text('Half-day / Absent rules'),Text('Weekend / Holiday rules')])),
    const SizedBox(height:16), _panel('Punch History & Corrections', Column(children: const [ListTile(leading:Icon(Icons.history),title:Text('Daily / Weekly / Monthly History')),ListTile(leading:Icon(Icons.edit_note),title:Text('Missing Punch / Wrong Punch / Forgot Punch In-Out')),ListTile(leading:Icon(Icons.approval),title:Text('Employee → Manager → HR Approval')),ListTile(leading:Icon(Icons.file_download),title:Text('PDF / Excel Reports'))])),
    const SizedBox(height:16), _panel('Advanced Attendance', const Wrap(spacing:12,runSpacing:10,children:[Chip(label:Text('GPS Attendance')),Chip(label:Text('Geofencing')),Chip(label:Text('Office Locations')),Chip(label:Text('IP Restriction')),Chip(label:Text('Device Restriction')),Chip(label:Text('Selfie / Face Verification')),Chip(label:Text('QR Attendance')),Chip(label:Text('Biometric Integration')),Chip(label:Text('WFH')),Chip(label:Text('On Duty')),Chip(label:Text('Attendance Approval'))])),
  ]);

  String _time(DateTime d) => '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  String _dur(Duration d) => '${d.inHours}h ${(d.inMinutes%60).toString().padLeft(2,'0')}m';

  Widget _leave() => ListView(padding: const EdgeInsets.all(16), children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children:[Text('Leave Management',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),FilledButton.icon(onPressed:_applyLeave,icon:const Icon(Icons.add),label:const Text('Apply Leave'))]),const SizedBox(height:12),
    _panel('Leave Types & Balances', Wrap(spacing:10,runSpacing:10,children:[const Chip(label:Text('Casual Leave')),const Chip(label:Text('Sick Leave')),const Chip(label:Text('Earned Leave')),const Chip(label:Text('Paid Leave')),const Chip(label:Text('Unpaid Leave')), ...s.employees.map((e)=>Chip(label:Text('${e.name}: ${s.leaveBalances[e.id]??0} days')))])),const SizedBox(height:12),
    ...s.leaves.map((l)=>Card(child:ListTile(title:Text('${l.type} • ${l.days} day(s)'),subtitle:Text('${l.employeeId} • ${l.reason}'),trailing:l.status=='Pending'?Row(mainAxisSize:MainAxisSize.min,children:[IconButton(onPressed:()=>s.decideLeave(l.id,true),icon:const Icon(Icons.check)),IconButton(onPressed:()=>s.decideLeave(l.id,false),icon:const Icon(Icons.close))]):Chip(label:Text(l.status)))))
  ]);
  void _applyLeave(){if(s.employees.isEmpty)return;s.applyLeave(LeaveRequest(id:DateTime.now().millisecondsSinceEpoch.toString(),employeeId:s.employees.first.id,type:'Casual Leave',from:DateTime.now().add(const Duration(days:1)),to:DateTime.now().add(const Duration(days:2)),reason:'Personal work'));}

  Widget _payroll() => ListView(padding:const EdgeInsets.all(16),children:[_panel('Payroll Processing',Column(children:s.employees.map((e){final p=PayrollRecord(employeeId:e.id,basic:30000,allowances:12000,bonus:2000,overtime:1500,deductions:4500);return ListTile(leading:const Icon(Icons.receipt_long),title:Text(e.name),subtitle:Text('Basic ₹${p.basic.toStringAsFixed(0)} • Allowances ₹${p.allowances.toStringAsFixed(0)} • Bonus ₹${p.bonus.toStringAsFixed(0)} • PF/ESI/PT/TDS deductions'),trailing:Text('Net ₹${p.net.toStringAsFixed(0)}',style:const TextStyle(fontWeight:FontWeight.bold)));}).toList())),const SizedBox(height:16),_panel('Payroll Features',const Wrap(spacing:16,runSpacing:10,children:[Text('Salary Structure'),Text('Basic Salary'),Text('Allowances'),Text('Bonuses / Incentives'),Text('PF'),Text('ESI'),Text('Professional Tax'),Text('TDS'),Text('Overtime'),Text('Payslip'),Text('Salary History'),Text('Bank Transfer Data'),Text('Full & Final Settlement')]))]);

  Widget _module(String title) { final details=_details(title); return ListView(padding:const EdgeInsets.all(16),children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Expanded(child:Text(title,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800))),FilledButton.icon(onPressed:()=>_addRecord(title),icon:const Icon(Icons.add),label:const Text('Add'))]),const SizedBox(height:14),_panel('Features',Column(crossAxisAlignment:CrossAxisAlignment.start,children:details.map((x)=>ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.check_circle_outline),title:Text(x),trailing:const Icon(Icons.chevron_right))).toList())),const SizedBox(height:14),_panel('Workflow',const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Create → Review → Approve/Reject → History → Reports'),SizedBox(height:8),Text('Role based access: Super Admin • HR Admin • Manager • Employee'),SizedBox(height:8),Text('Production data layer: Firebase repositories, secure rules, storage, notifications and audit logs.')]))]); }

  void _addRecord(String title){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Add workflow opened for $title')));}

  List<String> _details(String t){const m=<String,List<String>>{
    'Employee Lifecycle':['Recruitment','Candidate Management','Interview','Selection','Offer Letter','Joining','Onboarding','Probation','Confirmation','Transfer','Promotion','Increment','Resignation','Exit','Full & Final Settlement','Relieving Letter','Experience Letter'],
    'Department & Organization':['Departments','Designations','Teams','Reporting Structure','Managers','Organization Chart','Branches','Locations'],
    'Shift & Roster':['Create Shift','Assign Shift','Shift Timing','Multiple Shifts','Night Shift','Rotational Shift','Weekly Roster','Employee Roster','Shift Change Request'],
    'Performance Management':['Goals','KPI','Performance Review','Self Assessment','Manager Assessment','Rating','Appraisal','Promotion','Increment','Performance History'],
    'Document Management':['Employee Documents','Company Documents','Offer Letter','Appointment Letter','Joining Letter','Salary Slip','Increment Letter','Promotion Letter','Experience Letter','Relieving Letter','Document Verification','Document Expiry Alerts'],
    'Recruitment':['Job Openings','Applications','Candidate Profiles','Resume','Interview','Interview Feedback','Shortlist','Selection','Rejection','Offer Management'],
    'Employee Self Service':['My Profile','My Attendance','My Punch In/Out','My Leave','My Leave Balance','My Payslip','My Documents','My Requests','My Performance','My Assets','Company Announcements'],
    'Expense Management':['Expense Claim','Travel Expense','Food Expense','Other Expense','Bill Upload','Approval','Rejection','Reimbursement','Expense History'],
    'Asset Management':['Laptop','Desktop','Mobile','ID Card','SIM','Accessories','Asset Assignment','Asset Return','Asset History'],
    'Notifications':['Push Notifications','Leave Notification','Attendance Notification','Late Notification','Punch Reminder','Missing Punch Alert','Payroll Notification','Announcement','Birthday','Work Anniversary'],
    'Company Communication':['Announcements','Notices','Circulars','Company Events','Holiday Announcement','Important Updates'],
    'Reports & Analytics':['Employee Report','Attendance Report','Leave Report','Payroll Report','Overtime Report','Performance Report','Recruitment Report','Expense Report','Asset Report','Department Report','Monthly HR Report','PDF Export','Excel Export'],
    'Admin & Security':['Super Admin','HR Admin','Manager','Employee','Roles','Permissions','Access Control','Login','OTP','Password','Session Management','Audit Logs','Activity Logs','Data Backup'],
    'Company Settings':['Company Profile','Branches','Departments','Designations','Working Days','Holidays','Leave Rules','Attendance Rules','Shift Rules','Payroll Rules','Notification Settings','Approval Workflow'],
  }; return m[t] ?? ['GPS Attendance','Geofencing','Office Location Verification','Multiple Office Locations','IP Restriction','Device Restriction','Selfie Attendance','Face Verification','QR Attendance','Biometric Integration','Remote / WFH Attendance','On-Duty Attendance','Attendance Approval'];}

  void _showSearch(){showSearch(context:context,delegate:_HrmsSearchDelegate(s.modules,(i)=>setState(()=>selected=i)));}
}

class _HrmsSearchDelegate extends SearchDelegate<String> {
  final List<String> modules; final void Function(int) onSelect;
  _HrmsSearchDelegate(this.modules,this.onSelect);
  @override List<Widget>? buildActions(BuildContext context)=>[IconButton(onPressed:()=>query='',icon:const Icon(Icons.clear))];
  @override Widget buildLeading(BuildContext context)=>IconButton(onPressed:()=>close(context,null),icon:const Icon(Icons.arrow_back));
  @override Widget buildResults(BuildContext context)=>_results(context);
  @override Widget buildSuggestions(BuildContext context)=>_results(context);
  Widget _results(BuildContext context){final q=query.toLowerCase();final hits=modules.asMap().entries.where((e)=>e.value.toLowerCase().contains(q)).toList();return ListView(children:hits.map((e)=>ListTile(leading:const Icon(Icons.apps),title:Text(e.value),onTap:(){onSelect(e.key);close(context,e.value);})).toList());}
}
