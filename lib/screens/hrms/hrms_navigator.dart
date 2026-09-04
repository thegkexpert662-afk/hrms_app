import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import 'module_screens.dart'
    hide DashboardScreen, EmployeeScreen, LifecycleScreen, AttendanceScreen, AssetsScreen, NotificationsScreen, CommunicationScreen, ReportsScreen, AdminScreen, SettingsScreen, AdvancedAttendanceScreen;
import 'dashboard_home_screen.dart';
import 'employee_management_screen.dart';
import 'lifecycle_management_screen.dart';
import 'attendance_management_screen.dart';
import 'asset_management_screen.dart';
import 'notification_management_screen.dart';
import 'communication_management_screen.dart';
import 'report_management_screen.dart';

class HrmsNavigator extends StatefulWidget {
  final HrmsService service;
  const HrmsNavigator({super.key, required this.service});

  @override
  State<HrmsNavigator> createState() => _HrmsNavigatorState();
}

class _HrmsNavigatorState extends State<HrmsNavigator> {
  int selected = 0;

  static const titles = <String>[
    'Dashboard', 'Employee Management', 'Employee Lifecycle', 'Attendance',
    'Leave Management', 'Payroll', 'Department & Organization', 'Shift & Roster',
    'Performance Management', 'Document Management', 'Recruitment', 'Employee Self Service',
    'Expense Management', 'Asset Management', 'Notifications', 'Company Communication',
    'Reports & Analytics',
  ];

  static const icons = <IconData>[
    Icons.dashboard_rounded, Icons.people_alt_rounded, Icons.timeline_rounded,
    Icons.access_time_rounded, Icons.event_available_rounded, Icons.payments_rounded,
    Icons.account_tree_rounded, Icons.schedule_rounded, Icons.insights_rounded,
    Icons.folder_rounded, Icons.work_outline_rounded, Icons.person_outline_rounded,
    Icons.receipt_long_rounded, Icons.devices_rounded, Icons.notifications_rounded,
    Icons.campaign_rounded, Icons.analytics_rounded,
  ];

  Widget page() {
    final service = widget.service;
    switch (selected) {
      case 0: return DashboardHomeScreen(service: service);
      case 1: return EmployeeManagementScreen(service: service);
      case 2: return LifecycleManagementScreen(service: service);
      case 3: return AttendanceManagementScreen(service: service);
      case 4: return LeaveScreen(service: service);
      case 5: return PayrollScreen(service: service);
      case 6: return DepartmentScreen(service: service);
      case 7: return ShiftScreen(service: service);
      case 8: return PerformanceScreen(service: service);
      case 9: return DocumentsScreen(service: service);
      case 10: return RecruitmentScreen(service: service);
      case 11: return EssScreen(service: service);
      case 12: return ExpenseScreen(service: service);
      case 13: return AssetsScreen(service: service);
      case 14: return NotificationsScreen(service: service);
      case 15: return CommunicationScreen(service: service);
      case 16: return ReportsScreen(service: service);
      default: return DashboardHomeScreen(service: service);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selected], style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: () => setState(() {}), icon: const Icon(Icons.refresh_rounded)),
          const Padding(padding: EdgeInsets.only(right: 16), child: CircleAvatar(child: Icon(Icons.person_rounded))),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const UserAccountsDrawerHeader(
                decoration: BoxDecoration(),
                currentAccountPicture: CircleAvatar(child: Icon(Icons.water_drop_rounded)),
                accountName: Text('HRMS MANAGEMENT'),
                accountEmail: Text('Human Resource Management'),
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
