import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import 'module_screens.dart'
    hide DashboardScreen, EmployeeScreen, LifecycleScreen, AttendanceScreen, AssetsScreen, NotificationsScreen;
import 'dashboard_home_screen.dart';
import 'employee_management_screen.dart';
import 'lifecycle_management_screen.dart';
import 'attendance_management_screen.dart';
import 'asset_management_screen.dart';
import 'notification_management_screen.dart';

class HrmsNavigator extends StatefulWidget {
  final HrmsService service;

  const HrmsNavigator({super.key, required this.service});

  @override
  State<HrmsNavigator> createState() => _HrmsNavigatorState();
}

class _HrmsNavigatorState extends State<HrmsNavigator> {
  int selected = 0;

  static const titles = <String>[
    'Dashboard',
    'Employee Management',
    'Employee Lifecycle',
    'Attendance',
    'Leave Management',
    'Payroll',
    'Department & Organization',
    'Shift & Roster',
    'Performance Management',
    'Document Management',
    'Recruitment',
    'Employee Self Service',
    'Expense Management',
    'Asset Management',
    'Notifications',
    'Company Communication',
    'Reports & Analytics',
    'Admin & Security',
    'Company Settings',
    'Advanced Attendance',
  ];

  static const icons = <IconData>[
    Icons.dashboard,
    Icons.people,
    Icons.timeline,
    Icons.access_time,
    Icons.event_available,
    Icons.payments,
    Icons.account_tree,
    Icons.schedule,
    Icons.insights,
    Icons.folder,
    Icons.work,
    Icons.person,
    Icons.receipt_long,
    Icons.devices,
    Icons.notifications,
    Icons.campaign,
    Icons.analytics,
    Icons.security,
    Icons.settings,
    Icons.gps_fixed,
  ];

  Widget page() {
    final service = widget.service;

    switch (selected) {
      case 0:
        return DashboardHomeScreen(service: service);
      case 1:
        return EmployeeManagementScreen(service: service);
      case 2:
        return LifecycleManagementScreen(service: service);
      case 3:
        return AttendanceManagementScreen(service: service);
      case 4:
        return LeaveScreen(service: service);
      case 5:
        return PayrollScreen(service: service);
      case 6:
        return DepartmentScreen(service: service);
      case 7:
        return ShiftScreen(service: service);
      case 8:
        return PerformanceScreen(service: service);
      case 9:
        return DocumentsScreen(service: service);
      case 10:
        return RecruitmentScreen(service: service);
      case 11:
        return EssScreen(service: service);
      case 12:
        return ExpenseScreen(service: service);
      case 13:
        return AssetsScreen(service: service);
      case 14:
        return NotificationsScreen(service: service);
      case 15:
        return CommunicationScreen(service: service);
      case 16:
        return ReportsScreen(service: service);
      case 17:
        return AdminScreen(service: service);
      case 18:
        return SettingsScreen(service: service);
      default:
        return AdvancedAttendanceScreen(service: service);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[selected],
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(),
                currentAccountPicture: CircleAvatar(
                  child: Icon(Icons.business),
                ),
                accountName: Text('HRMS MANAGEMENT'),
                accountEmail: Text('Complete Human Resource Management'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: titles.length,
                  itemBuilder: (context, index) => ListTile(
                    selected: index == selected,
                    leading: Icon(icons[index]),
                    title: Text(titles[index]),
                    onTap: () {
                      setState(() => selected = index);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: page(),
    );
  }
}
