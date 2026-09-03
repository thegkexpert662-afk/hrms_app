import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import 'module_screens.dart' hide DashboardScreen, EmployeeScreen, LifecycleScreen, AttendanceScreen;
import 'dashboard_home_screen.dart';
import 'employee_management_screen.dart';
import 'lifecycle_management_screen.dart';
import 'attendance_management_screen.dart';

class HrmsNavigator extends StatefulWidget {
  final HrmsService service;
  const HrmsNavigator({super.key, required this.service});
  @override State<HrmsNavigator> createState()=>_HrmsNavigatorState();
}
class _HrmsNavigatorState extends State<HrmsNavigator>{
  int selected=0;
  final titles=const ['Dashboard','Employee Management','Employee Lifecycle','Attendance','Leave Management','Payroll','Department & Organization','Shift & Roster','Performance Management','Document Management','Recruitment','Employee Self Service','Expense Management','Asset Management','Notifications','Company Communication','Reports & Analytics','Admin & Security','Company Settings','Advanced Attendance'];
  final icons=const [Icons.dashboard,Icons.people,Icons.timeline,Icons.access_time,Icons.event_available,Icons.payments,Icons.account_tree,Icons.schedule,Icons.insights,Icons.folder,Icons.work,Icons.person,Icons.receipt_long,Icons.devices,Icons.notifications,Icons.campaign,Icons.analytics,Icons.security,Icons.settings,Icons.gps_fixed];
  Widget page(){final s=widget.service;switch(selected){case 0:return DashboardHomeScreen(service:s);case 1:return EmployeeManagementScreen(service:s);case 2:return LifecycleManagementScreen(service:s);case 3:return AttendanceManagementScreen(service:s);case 4:return LeaveScreen(service:s);case 5:return PayrollScreen(service:s);case 6:return DepartmentScreen(service:s);case 7:return ShiftScreen(service:s);case 8:return PerformanceScreen(service:s);case 9:return DocumentsScreen(service:s);case 10:return RecruitmentScreen(service:s);case 11:return EssScreen(service:s);case 12:return ExpenseScreen(service:s);case 13:return AssetsScreen(service:s);case 14:return NotificationsScreen(service:s);case 15:return CommunicationScreen(service:s);case 16:return ReportsScreen(service:s);case 17:return AdminScreen(service:s);case 18:return SettingsScreen(service:s);default:return AdvancedAttendanceScreen(service:s);}}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(titles[selected],style:const TextStyle(fontWeight:FontWeight.w800)),actions:[IconButton(onPressed:()=>setState((){}),icon:const Icon(Icons.refresh)),const Padding(padding:EdgeInsets.only(right:16),child:CircleAvatar(child:Icon(Icons.person)))]),drawer:Drawer(child:SafeArea(child:Column(children:[const UserAccountsDrawerHeader(decoration:BoxDecoration(),currentAccountPicture:CircleAvatar(child:Icon(Icons.business)),accountName:Text('HRMS MANAGEMENT'),accountEmail:Text('Complete Human Resource Management')),Expanded(child:ListView.builder(itemCount:titles.length,itemBuilder:(c,i)=>ListTile(selected:i==selected,leading:Icon(icons[i]),title:Text(titles[i]),onTap:(){setState(()=>selected=i);Navigator.pop(context);},))),])),body:page());
}
