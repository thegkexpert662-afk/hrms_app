import 'package:flutter/material.dart';
import '../screens/auth/auth_flow.dart';

class Employee {
  final String id;
  String name, department, designation, manager, employmentType, status, phone, email;
  DateTime joiningDate;
  Employee({required this.id, required this.name, required this.department, required this.designation, required this.manager, required this.joiningDate, required this.employmentType, required this.status, required this.phone, required this.email});
}

class AttendanceRecord {
  final String employeeId;
  final DateTime date;
  DateTime? punchIn, punchOut;
  Duration breakTime;
  String status;
  bool wfh;
  AttendanceRecord({required this.employeeId, required this.date, this.punchIn, this.punchOut, this.breakTime=Duration.zero, this.status='Present', this.wfh=false});
  Duration get workingTime=>punchIn==null?Duration.zero:Duration(milliseconds:((punchOut??DateTime.now()).difference(punchIn!).inMilliseconds-breakTime.inMilliseconds).clamp(0,86400000).toInt());
  Duration get overtime=>workingTime>const Duration(hours:8)?workingTime-const Duration(hours:8):Duration.zero;
}

class LeaveRequest {
  final String id,employeeId,type,reason;
  final DateTime from,to;
  String status;
  LeaveRequest({required this.id,required this.employeeId,required this.type,required this.from,required this.to,required this.reason,this.status='Pending'});
  int get days=>to.difference(from).inDays+1;
}

class PayrollRecord {
  final String employeeId;
  final double basic,allowances,bonus,overtime,deductions;
  PayrollRecord({required this.employeeId,required this.basic,required this.allowances,required this.bonus,required this.overtime,required this.deductions});
  double get gross=>basic+allowances+bonus+overtime;
  double get net=>gross-deductions;
}

class HrmsService extends ChangeNotifier {
  final List<Employee> employees=[
    Employee(id:'EMP001',name:'Aarav Sharma',department:'Engineering',designation:'Senior Developer',manager:'HR Admin',joiningDate:DateTime(2024,2,12),employmentType:'Full Time',status:'Active',phone:'9876543210',email:'aarav@company.com'),
    Employee(id:'EMP002',name:'Ananya Singh',department:'Human Resources',designation:'HR Executive',manager:'HR Admin',joiningDate:DateTime(2025,5,6),employmentType:'Full Time',status:'Active',phone:'9876543211',email:'ananya@company.com'),
    Employee(id:'EMP003',name:'Rohan Verma',department:'Sales',designation:'Sales Manager',manager:'HR Admin',joiningDate:DateTime(2023,8,20),employmentType:'Full Time',status:'Active',phone:'9876543212',email:'rohan@company.com'),
  ];
  final List<AttendanceRecord> attendance=[];
  final List<LeaveRequest> leaves=[];
  final Map<String,double> leaveBalances={'EMP001':18,'EMP002':14,'EMP003':20};
  AttendanceRecord? todayFor(String id){final n=DateTime.now();for(final r in attendance.reversed){if(r.employeeId==id&&r.date.year==n.year&&r.date.month==n.month&&r.date.day==n.day)return r;}return null;}
  AttendanceRecord punchIn(String id,{bool wfh=false}){final r=todayFor(id)??AttendanceRecord(employeeId:id,date:DateTime.now(),wfh:wfh);r.punchIn??=DateTime.now();r.wfh=wfh;r.status=DateTime.now().hour>=10?'Late':'Present';if(!attendance.contains(r))attendance.add(r);notifyListeners();return r;}
  void punchOut(String id){final r=todayFor(id);if(r?.punchIn!=null&&r?.punchOut==null){r!.punchOut=DateTime.now();r.status=r.workingTime<const Duration(hours:8)?'Early Exit':r.status;notifyListeners();}}
  void addEmployee(Employee e){employees.add(e);notifyListeners();}
  void updateEmployee(Employee e){final i=employees.indexWhere((x)=>x.id==e.id);if(i>=0)employees[i]=e;notifyListeners();}
  void removeEmployee(String id){employees.removeWhere((e)=>e.id==id);notifyListeners();}
  void applyLeave(LeaveRequest r){leaves.add(r);notifyListeners();}
  void decideLeave(String id,bool ok){final r=leaves.firstWhere((x)=>x.id==id);r.status=ok?'Approved':'Rejected';if(ok)leaveBalances[r.employeeId]=(leaveBalances[r.employeeId]??0)-r.days;notifyListeners();}
  int get present=>employees.where((e)=>todayFor(e.id)?.status=='Present').length;
  int get late=>employees.where((e)=>todayFor(e.id)?.status=='Late').length;
  int get earlyExit=>employees.where((e)=>todayFor(e.id)?.status=='Early Exit').length;
  int get wfh=>employees.where((e)=>todayFor(e.id)?.wfh==true).length;
  int get pendingLeaves=>leaves.where((l)=>l.status=='Pending').length;
  int get onLeave=>leaves.where((l)=>l.status=='Approved'&&DateTime.now().isAfter(l.from.subtract(const Duration(days:1)))&&DateTime.now().isBefore(l.to.add(const Duration(days:1)))).length;
}

class HrmsApp extends StatelessWidget {
  final HrmsService service;
  const HrmsApp({super.key,required this.service});
  @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'HRMS Management System',theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF2563EB)),scaffoldBackgroundColor:const Color(0xFFF5F7FB)),home:AuthFlow(service:service));
}
