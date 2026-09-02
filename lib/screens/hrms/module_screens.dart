import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

/// Shared production-friendly shell for HRMS modules.
/// Domain services can be connected here without duplicating navigation code.
class ModuleScreen extends StatefulWidget {
  final HrmsService service;
  final String title;
  final IconData icon;
  final List<String> sections;

  const ModuleScreen({super.key, required this.service, required this.title, required this.icon, required this.sections});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  final Map<String, List<Map<String, String>>> records = {};

  @override
  void initState() {
    super.initState();
    for (final section in widget.sections) {
      records[section] = [];
    }
  }

  Future<void> _addRecord(String section) async {
    final name = TextEditingController();
    final details = TextEditingController();
    final status = TextEditingController(text: 'Pending');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $section'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Name / Title', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: details, maxLines: 3, decoration: const InputDecoration(labelText: 'Details / Description', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: status, decoration: const InputDecoration(labelText: 'Status / Amount / Value', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, name.text.trim().isNotEmpty), child: const Text('Save')),
        ],
      ),
    );
    if (result != true || !mounted) return;
    setState(() {
      records[section]!.add({
        'name': name.text.trim(),
        'details': details.text.trim(),
        'status': status.text.trim(),
        'date': DateTime.now().toIso8601String().split('T').first,
      });
    });
  }

  void _deleteRecord(String section, int index) {
    setState(() => records[section]!.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(radius: 28, child: Icon(widget.icon)),
                const SizedBox(width: 14),
                Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...widget.sections.map(_sectionCard),
      ],
    );
  }

  Widget _sectionCard(String section) {
    final items = records[section]!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.folder_open_outlined),
        title: Text(section, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${items.length} record${items.length == 1 ? '' : 's'}'),
        children: [
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Align(alignment: Alignment.centerLeft, child: Text('No records yet. Add the first record.')),
            ),
          ...List.generate(items.length, (index) {
            final item = items[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.description_outlined, size: 18)),
              title: Text(item['name'] ?? ''),
              subtitle: Text('${item['details'] ?? ''}\n${item['status'] ?? ''} • ${item['date'] ?? ''}'),
              isThreeLine: true,
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteRecord(section, index)),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(onPressed: () => _addRecord(section), icon: const Icon(Icons.add), label: const Text('Add Record')),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends ModuleScreen {
  DashboardScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Dashboard', icon: Icons.dashboard, sections: const [
          'Total Employees',
          'Present / Absent',
          'On Leave',
          'Late / Early Exit',
          'Work From Home',
          'Pending Leave',
          'Pending Requests',
          'Upcoming Holidays',
          'Birthdays / Anniversaries',
          'New Joiners',
          'Attendance Summary',
        ]);
}

class EmployeeScreen extends ModuleScreen {
  EmployeeScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Employee Management', icon: Icons.people, sections: const [
          'Employee List',
          'Add Employee',
          'Employee Profile',
          'Personal Details',
          'Contact Details',
          'Emergency Contact',
          'Address',
          'Department / Designation',
          'Manager / Reporting',
          'Joining / Employment',
          'Bank Details',
          'Documents',
          'Skills / Education / Experience',
        ]);
}

class LifecycleScreen extends ModuleScreen {
  LifecycleScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Employee Lifecycle', icon: Icons.timeline, sections: const [
          'Recruitment', 'Candidates', 'Interview', 'Selection', 'Offer Letter', 'Joining', 'Onboarding',
          'Probation', 'Confirmation', 'Transfer', 'Promotion', 'Increment', 'Resignation', 'Exit',
          'Full & Final Settlement', 'Relieving Letter', 'Experience Letter',
        ]);
}

class AttendanceScreen extends ModuleScreen {
  AttendanceScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Attendance Management', icon: Icons.access_time, sections: const [
          'Punch In / Punch Out', 'Daily History', 'Weekly History', 'Monthly History', 'Breaks',
          'Working Hours', 'Overtime', 'Late', 'Early Exit', 'Missing Punch', 'Punch Correction',
          'Approval', 'Attendance Reports', 'Attendance Rules',
        ]);
}

class LeaveScreen extends ModuleScreen {
  LeaveScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Leave Management', icon: Icons.event_available, sections: const [
          'Leave Types', 'Leave Balance', 'Apply Leave', 'Pending Requests', 'Approve / Reject',
          'Leave History', 'Leave Calendar', 'Holidays', 'Leave Rules',
        ]);
}

class PayrollScreen extends ModuleScreen {
  PayrollScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Payroll Management', icon: Icons.payments, sections: const [
          'Salary Structure', 'Basic Salary', 'Allowances', 'Bonus / Incentives', 'PF', 'ESI',
          'Professional Tax', 'TDS', 'Overtime', 'Payroll Calculation', 'Payroll Processing',
          'Payslip', 'Salary History', 'Bank Transfer', 'Full & Final Settlement',
        ]);
}

class DepartmentScreen extends ModuleScreen {
  DepartmentScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Department & Organization', icon: Icons.account_tree, sections: const [
          'Departments', 'Designations', 'Teams', 'Reporting Structure', 'Managers', 'Organization Chart',
          'Branches', 'Locations',
        ]);
}

class ShiftScreen extends ModuleScreen {
  ShiftScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Shift & Roster', icon: Icons.schedule, sections: const [
          'Create Shift', 'Assign Shift', 'Shift Timing', 'Multiple Shifts', 'Night Shift',
          'Rotational Shift', 'Weekly Roster', 'Employee Roster', 'Shift Change Request',
        ]);
}

class PerformanceScreen extends ModuleScreen {
  PerformanceScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Performance Management', icon: Icons.insights, sections: const [
          'Goals', 'KPI', 'Performance Review', 'Self Assessment', 'Manager Assessment', 'Rating',
          'Appraisal', 'Promotion', 'Increment', 'Performance History',
        ]);
}

class DocumentsScreen extends ModuleScreen {
  DocumentsScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Document Management', icon: Icons.folder, sections: const [
          'Employee Documents', 'Company Documents', 'Offer Letter', 'Appointment Letter', 'Joining Letter',
          'Salary Slip', 'Increment Letter', 'Promotion Letter', 'Experience Letter', 'Relieving Letter',
          'Document Verification', 'Document Expiry Alerts',
        ]);
}

class RecruitmentScreen extends ModuleScreen {
  RecruitmentScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Recruitment', icon: Icons.work, sections: const [
          'Job Openings', 'Applications', 'Candidate Profiles', 'Resume', 'Interview', 'Interview Feedback',
          'Shortlist', 'Selection', 'Rejection', 'Offer Management',
        ]);
}

class EssScreen extends ModuleScreen {
  EssScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Employee Self Service', icon: Icons.person, sections: const [
          'My Profile', 'My Attendance', 'My Punch In / Out', 'My Leave', 'My Leave Balance',
          'My Payslip', 'My Documents', 'My Requests', 'My Performance', 'My Assets', 'Announcements',
        ]);
}

class ExpenseScreen extends ModuleScreen {
  ExpenseScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Expense Management', icon: Icons.receipt_long, sections: const [
          'Expense Claim', 'Travel Expense', 'Food Expense', 'Other Expense', 'Bill Upload',
          'Approval', 'Rejection', 'Reimbursement', 'Expense History',
        ]);
}

class AssetsScreen extends ModuleScreen {
  AssetsScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Asset Management', icon: Icons.devices, sections: const [
          'Laptop', 'Desktop', 'Mobile', 'ID Card', 'SIM', 'Accessories', 'Asset Assignment',
          'Asset Return', 'Asset History',
        ]);
}

class NotificationsScreen extends ModuleScreen {
  NotificationsScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Notifications', icon: Icons.notifications, sections: const [
          'Push Notifications', 'Leave Alerts', 'Attendance Alerts', 'Late Alerts', 'Missing Punch Reminders',
          'Payroll Notifications', 'Announcements', 'Birthday / Anniversary Alerts',
        ]);
}

class CommunicationScreen extends ModuleScreen {
  CommunicationScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Company Communication', icon: Icons.campaign, sections: const [
          'Announcements', 'Notices', 'Circulars', 'Events', 'Holidays', 'Company Updates',
        ]);
}

class ReportsScreen extends ModuleScreen {
  ReportsScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Reports & Analytics', icon: Icons.analytics, sections: const [
          'Employee Reports', 'Attendance Reports', 'Leave Reports', 'Payroll Reports', 'Overtime Reports',
          'Performance Reports', 'Recruitment Reports', 'Expense Reports', 'Asset Reports',
          'Department Reports', 'Monthly HR Reports', 'PDF Export', 'Excel Export',
        ]);
}

class AdminScreen extends ModuleScreen {
  AdminScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Admin & Security', icon: Icons.security, sections: const [
          'Roles', 'Permissions', 'Login', 'OTP', 'Password', 'Sessions', 'Audit Logs', 'Activity Logs',
          'Backup',
        ]);
}

class SettingsScreen extends ModuleScreen {
  SettingsScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Company Settings', icon: Icons.settings, sections: const [
          'Company Profile', 'Branches', 'Departments', 'Designations', 'Working Days', 'Holidays',
          'Leave Rules', 'Attendance Rules', 'Shift Rules', 'Payroll Rules', 'Notification Rules',
          'Approval Workflow',
        ]);
}

class AdvancedAttendanceScreen extends ModuleScreen {
  AdvancedAttendanceScreen({super.key, required HrmsService service})
      : super(service: service, title: 'Advanced Attendance', icon: Icons.gps_fixed, sections: const [
          'GPS Attendance', 'Geofencing', 'Office Locations', 'IP Restriction', 'Device Restriction',
          'Selfie Verification', 'Face Verification', 'QR Attendance', 'Biometric Integration',
          'WFH', 'On Duty', 'Attendance Approval',
        ]);
}
