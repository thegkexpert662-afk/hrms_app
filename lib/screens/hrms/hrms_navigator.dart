import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import 'employee_home_screen.dart';
import 'attendance_management_screen.dart';
import 'module_screens.dart' hide DashboardScreen, EmployeeScreen, LifecycleScreen, AttendanceScreen, AssetsScreen, NotificationsScreen, CommunicationScreen, ReportsScreen, AdminScreen, SettingsScreen, AdvancedAttendanceScreen;
import 'payroll_management_screen.dart';
import 'document_management_screen.dart';
import 'ess_management_screen.dart';
import 'notification_management_screen.dart';

/// Employee navigation only. Admin, management and configuration modules are
/// deliberately hidden from the normal user interface.
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
    'My Attendance',
    'Leave',
    'Payroll',
    'My Documents',
    'Employee Self Service',
    'Notifications',
  ];

  static const icons = <IconData>[
    Icons.dashboard_rounded,
    Icons.access_time_rounded,
    Icons.event_available_rounded,
    Icons.payments_rounded,
    Icons.folder_rounded,
    Icons.person_rounded,
    Icons.notifications_rounded,
  ];

  Widget page() {
    final service = widget.service;
    switch (selected) {
      case 0:
        return EmployeeHomeScreen(service: service);
      case 1:
        return AttendanceManagementScreen(service: service);
      case 2:
        return LeaveScreen(service: service);
      case 3:
        return PayrollManagementScreen(service: service);
      case 4:
        return DocumentsScreen(service: service);
      case 5:
        return EssScreen(service: service);
      case 6:
        return NotificationsScreen(service: service);
      default:
        return EmployeeHomeScreen(service: service);
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
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Icon(Icons.person_rounded)),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Icon(Icons.water_drop_rounded, size: 28),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'HRMS',
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                    ),
                    Text('Employee Portal'),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  itemCount: titles.length,
                  itemBuilder: (context, index) => ListTile(
                    dense: true,
                    selected: index == selected,
                    leading: Icon(icons[index]),
                    title: Text(titles[index]),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
