import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';

class AllModulesHome extends StatefulWidget {
  final HrmsService service;
  const AllModulesHome({super.key, required this.service});
  @override State<AllModulesHome> createState() => _AllModulesHomeState();
}

class _AllModulesHomeState extends State<AllModulesHome> {
  int index = 0;
  final FirestoreService cloud = FirestoreService();
  final LocationService location = LocationService();
  final Map<String, List<Map<String, String>>> records = {};
  HrmsService get s => widget.service;

  static const modules = <String>[
    'Dashboard','Employee Management','Employee Lifecycle','Attendance','Leave Management','Payroll',
    'Department & Organization','Shift & Roster','Performance Management','Document Management','Recruitment',
    'Employee Self Service','Expense Management','Asset Management','Notifications','Company Communication',
    'Reports & Analytics','Admin & Security','Company Settings','Advanced Attendance',
  ];

  final details = <String, List<String>>{
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
    'Reports & Analytics':['Employee Report','Attendance Report','Leave Report','Payroll Report','Overtime Report','Performance Report','Recruitment Report','Expense Report','Asset Report','Department Report','Monthly HR Report','Export PDF','Export Excel'],
    'Admin & Security':['Super Admin','HR Admin','Manager','Employee','Roles','Permissions','Access Control','Login','OTP','Password','Session Management','Audit Logs','Activity Logs','Data Backup'],
    'Company Settings':['Company Profile','Branches','Departments','Designations','Working Days','Holidays','Leave Rules','Attendance Rules','Shift Rules','Payroll Rules','Notification Settings','Approval Workflow'],
    'Advanced Attendance':['GPS Attendance','Geofencing','Office Location','Multiple Office Locations','IP Restriction','Device Restriction','Selfie/Face Verification','QR Attendance','Biometric Integration','Remote/WFH','On-Duty','Attendance Approval'],
  };

  @override void initState(){super.initState();s.addListener(_refresh);}
  @override void dispose(){s.removeListener(_refresh);super.dispose();}
  void _refresh(){if(mounted)setState((){});}

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(modules[index],style:const TextStyle(fontWeight:FontWeight.w800)),actions:[IconButton(onPressed:()=>setState((){}),icon:const Icon(Icons.refresh)),const Padding(padding:EdgeInsets.only(right:16),child:CircleAvatar(child:Icon(Icons.person)))]),
      drawer: Drawer(child:SafeArea(child:Column(children:[const ListTile(leading:CircleAvatar(child:Icon(Icons.business)),title:Text('HRMS MANAGEMENT',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('Complete HR & Attendance')),const Divider(),Expanded(child:ListView.builder(itemCount:modules.length,itemBuilder:(c,i)=>ListTile(selected:i==index,leading:Icon(_icon(i)),title:Text(modules[i]),onTap:(){setState(()=>index=i);Navigator.pop(context);}))) ]))),
      body:_screen(modules[index]),
    );
  }

  IconData _icon(int i){const a=[Icons.dashboard,Icons.people,Icons.timeline,Icons.access_time,Icons.event_available,Icons.payments,Icons.account_tree,Icons.schedule,Icons.insights,Icons.folder,Icons.work,Icons.person,Icons.receipt_long,Icons.devices,Icons.notifications,Icons.campaign,Icons.analytics,Icons.security,Icons.settings,Icons.gps_fixed];return a[i];}

  Widget _screen(String name){
    switch(name){
      case 'Dashboard': return _dashboard();
      case 'Employee Management': return _employees();
      case 'Attendance': return _attendance();
      case 'Advanced Attendance': return _advancedAttendance();
      case 'Leave Management': return _leave();
      case 'Payroll': return _payroll();
      default: return _workspace(name);
    }
  }

  Widget _dashboard()=>ListView(padding:const EdgeInsets.all(16),children:[Text('HRMS Dashboard',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:16),Wrap(spacing:12,runSpacing:12,children:[_stat('Employees',s.employees.length,Icons.people),_stat('Present',s.present,Icons.check_circle),_stat('Late',s.late,Icons.schedule),_stat('Early Exit',s.earlyExit,Icons.logout),_stat('WFH',s.wfh,Icons.home_work),_stat('On Leave',s.onLeave,Icons.event_busy),_stat('Pending Leave',s.pendingLeaves,Icons.pending_actions)]),const SizedBox(height:20),_panel('System Modules',Wrap(spacing:8,runSpacing:8,children:modules.map((x)=>ActionChip(label:Text(x),onPressed:(){setState(()=>index=modules.indexOf(x));})).toList()))]);
  Widget _stat(String t,int n,IconData i)=>SizedBox(width:165,child:Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(i,size:28),const SizedBox(height:8),Text('$n',style:const TextStyle(fontSize:26,fontWeight:FontWeight.w800)),Text(t)]))));
  Widget _panel(String title,Widget child)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800)),const SizedBox(height:12),child])));

  Widget _employees()=>ListView(padding:const EdgeInsets.all(16),children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Employees (${s.employees.length})',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800)),FilledButton.icon(onPressed:_employeeDialog,icon:const Icon(Icons.add),label:const Text('Add'))]),const SizedBox(height:12),...s.employees.map((e)=>Card(child:ListTile(leading:CircleAvatar(child:Text(e.name[0])),title:Text(e.name),subtitle:Text('${e.id} • ${e.designation}\n${e.department} • ${e.phone} • ${e.email}'),isThreeLine:true,trailing:PopupMenuButton<String>(onSelected:(v){if(v=='delete')s.removeEmployee(e.id);else _employeeDialog(e);},itemBuilder:(_)=>const[PopupMenuItem(value:'edit',child:Text('Edit')),PopupMenuItem(value:'delete',child:Text('Delete'))]))))]);

  Future<void> _employeeDialog([Employee? old])async{final c=List.generate(7,(i)=>TextEditingController(text:old==null?'':[old.name,old.department,old.designation,old.manager,old.employmentType,old.phone,old.email][i]));final data=await showDialog<List<String>>(context:context,builder:(_)=>AlertDialog(title:Text(old==null?'Add Employee':'Edit Employee'),content:SizedBox(width:430,child:SingleChildScrollView(child:Column(children:[for(int i=0;i<7;i++)Padding(padding:const EdgeInsets.only(bottom:9),child:TextField(controller:c[i],decoration:InputDecoration(labelText:['Name','Department','Designation','Manager','Employment Type','Phone','Email'][i],border:const OutlineInputBorder())))]))),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(context,c.map((x)=>x.text.trim()).toList()),child:const Text('Save'))]));if(data==null)return;if(old==null){final e=Employee(id:'EMP${(s.employees.length+1).toString().padLeft(3,'0')}',name:data[0],department:data[1],designation:data[2],manager:data[3],joiningDate:DateTime.now(),employmentType:data[4],status:'Active',phone:data[5],email:data[6]);s.addEmployee(e);await cloud.set('employees',e.id,{'id':e.id,'name':e.name,'department':e.department,'designation':e.designation,'manager':e.manager,'employmentType':e.employmentType,'status':e.status,'phone':e.phone,'email':e.email,'joiningDate':Timestamp.fromDate(e.joiningDate)});}else{old.name=data[0];old.department=data[1];old.designation=data[2];old.manager=data[3];old.employmentType=data[4];old.phone=data[5];old.email=data[6];s.updateEmployee(old);await cloud.set('employees',old.id,{'id':old.id,'name':old.name,'department':old.department,'designation':old.designation,'manager':old.manager,'employmentType':old.employmentType,'status':old.status,'phone':old.phone,'email':old.email});}}

  Widget _attendance()=>ListView(padding:const EdgeInsets.all(16),children:[_panel('Punch In / Punch Out',Column(children:s.employees.map((e){final r=s.todayFor(e.id);return ListTile(leading:CircleAvatar(child:Text(e.name[0])),title:Text(e.name),subtitle:Text(r?.punchIn==null?'Not punched in':'In ${r!.punchIn!.hour.toString().padLeft(2,'0')}:${r.punchIn!.minute.toString().padLeft(2,'0')} • ${_duration(r.workingTime)} • OT ${_duration(r.overtime)}'),trailing:r?.punchIn==null?FilledButton(onPressed:()=>_punch(e.id,false),child:const Text('Punch In')):r?.punchOut==null?OutlinedButton(onPressed:()=>_punch(e.id,true),child:const Text('Punch Out')):Chip(label:Text(r!.status)));}).toList())),const SizedBox(height:16),_panel('Attendance Rules',const Wrap(spacing:12,runSpacing:12,children:[Chip(label:Text('Shift 09:30–18:30')),Chip(label:Text('Grace 15 min')),Chip(label:Text('Late after 10:00')),Chip(label:Text('Minimum 8 hours')),Chip(label:Text('Overtime after 8h')),Chip(label:Text('Break rules')),Chip(label:Text('Half Day')),Chip(label:Text('Weekend/Holiday'))])),const SizedBox(height:16),_panel('History & Correction',const Column(children:[ListTile(leading:Icon(Icons.history),title:Text('Daily / Weekly / Monthly Attendance')),ListTile(leading:Icon(Icons.edit_note),title:Text('Missing / Wrong / Forgot Punch Correction')),ListTile(leading:Icon(Icons.approval),title:Text('Employee → Manager → HR Approval'))]))]);

  Future<void> _punch(String id,bool out)async{try{final p=await location.current();if(!out)s.punchIn(id);else s.punchOut(id);await cloud.writeAttendance(employeeId:id,time:DateTime.now(),action:out?'punchOut':'punchIn',latitude:p.latitude,longitude:p.longitude);if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${out?'Punch Out':'Punch In'} saved with GPS')));}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('GPS required: $e')));}}
  String _duration(Duration d)=>'${d.inHours}h ${(d.inMinutes%60).toString().padLeft(2,'0')}m';

  Widget _advancedAttendance()=>ListView(padding:const EdgeInsets.all(16),children:[_panel('Advanced Attendance',Column(children:[for(final x in details['Advanced Attendance']!)ListTile(leading:const Icon(Icons.verified_user_outlined),title:Text(x),subtitle:Text(x=='GPS Attendance'||x=='Geofencing'?'Implemented service layer + permission check':'Integration module ready for its provider'),trailing:const Icon(Icons.chevron_right))])),const SizedBox(height:16),_panel('Office Geofence',const Text('Office latitude/longitude and radius should be configured in Company Settings. Attendance can be rejected when the device is outside the configured radius.'))]);

  Widget _leave()=>ListView(padding:const EdgeInsets.all(16),children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Leave Management',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),FilledButton.icon(onPressed:_applyLeave,icon:const Icon(Icons.add),label:const Text('Apply'))]),const SizedBox(height:12),_panel('Leave Balances',Wrap(spacing:8,runSpacing:8,children:s.employees.map((e)=>Chip(label:Text('${e.name}: ${s.leaveBalances[e.id]??0} days'))).toList())),const SizedBox(height:12),...s.leaves.map((l)=>Card(child:ListTile(title:Text('${l.type} • ${l.days} day(s)'),subtitle:Text('${l.employeeId} • ${l.reason}'),trailing:l.status=='Pending'?Wrap(children:[IconButton(onPressed:()=>s.decideLeave(l.id,true),icon:const Icon(Icons.check)),IconButton(onPressed:()=>s.decideLeave(l.id,false),icon:const Icon(Icons.close))]):Chip(label:Text(l.status))))) ]);
  void _applyLeave(){if(s.employees.isEmpty)return;s.applyLeave(LeaveRequest(id:DateTime.now().millisecondsSinceEpoch.toString(),employeeId:s.employees.first.id,type:'Casual Leave',from:DateTime.now().add(const Duration(days:1)),to:DateTime.now().add(const Duration(days:2)),reason:'Personal work'));}

  Widget _payroll()=>ListView(padding:const EdgeInsets.all(16),children:[_panel('Payroll Processing',Column(children:s.employees.map((e){final p=PayrollRecord(employeeId:e.id,basic:30000,allowances:12000,bonus:2000,overtime:1500,deductions:4500);return ListTile(title:Text(e.name),subtitle:Text('Basic ₹${p.basic} • Allowance ₹${p.allowances} • Bonus ₹${p.bonus} • OT ₹${p.overtime} • Deductions ₹${p.deductions}'),trailing:Text('₹${p.net.toStringAsFixed(0)}',style:const TextStyle(fontWeight:FontWeight.w800)));}).toList())),const SizedBox(height:16),_panel('Payroll Rules',Wrap(spacing:10,runSpacing:10,children:['Salary Structure','PF','ESI','Professional Tax','TDS','Overtime','Payslip','Salary History','Bank Transfer','Full & Final'].map((x)=>Chip(label:Text(x))).toList()))]);

  Widget _workspace(String name){final list=details[name]??['Create','View','Edit','Approve','Reject','History','Reports'];final rows=records.putIfAbsent(name,()=>[]);return ListView(padding:const EdgeInsets.all(16),children:[Row(children:[Expanded(child:Text(name,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800))),FilledButton.icon(onPressed:()=>_recordDialog(name),icon:const Icon(Icons.add),label:const Text('Add Record'))]),const SizedBox(height:14),_panel('Features',Wrap(spacing:8,runSpacing:8,children:list.map((x)=>Chip(avatar:const Icon(Icons.check,size:16),label:Text(x))).toList())),const SizedBox(height:14),_panel('Records (${rows.length})',rows.isEmpty?const Padding(padding:EdgeInsets.all(12),child:Text('अभी कोई रिकॉर्ड नहीं है। Add Record से नया रिकॉर्ड बनाइए।')):Column(children:[for(int i=0;i<rows.length;i++)Card(child:ListTile(title:Text(rows[i]['title']??'Record'),subtitle:Text(rows[i]['details']??''),trailing:PopupMenuButton<String>(onSelected:(v){if(v=='delete')setState(()=>rows.removeAt(i));else _recordDialog(name,index:i);},itemBuilder:(_)=>const[PopupMenuItem(value:'edit',child:Text('Edit')),PopupMenuItem(value:'delete',child:Text('Delete'))])))])),const SizedBox(height:14),_panel('Approval Workflow',const Text('Create → Review → Approve/Reject → History. Role access: Super Admin, HR Admin, Manager, Employee.'))]);}

  Future<void> _recordDialog(String module,{int? index})async{final old=index==null?null:records[module]![index];final title=TextEditingController(text:old?['title']??'');final detailsC=TextEditingController(text:old?['details']??'');final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(title:Text(index==null?'Add $module Record':'Edit $module Record'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:title,decoration:const InputDecoration(labelText:'Title',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:detailsC,maxLines:3,decoration:const InputDecoration(labelText:'Details / Notes',border:OutlineInputBorder()))]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Save'))]));if(ok!=true)return;final row={'title':title.text.trim().isEmpty?'Untitled':title.text.trim(),'details':detailsC.text.trim(),'createdAt':DateTime.now().toIso8601String()};setState((){if(index==null)records[module]!.add(row);else records[module]![index]=row;});try{await cloud.add(module.toLowerCase().replaceAll(' ','_'),row);}catch(_){}}
}
