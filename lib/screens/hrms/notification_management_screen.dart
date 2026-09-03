import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class NotificationsScreen extends StatelessWidget {
  final HrmsService service;
  const NotificationsScreen({super.key, required this.service});

  static const items = [
    ['Notification Center', 'View, filter and manage HRMS notifications', Icons.notifications_outlined],
    ['Leave Alerts', 'Leave requests, approvals and balance alerts', Icons.event_available_outlined],
    ['Attendance Alerts', 'Late, absent and missing-punch alerts', Icons.access_time_outlined],
    ['Payroll / Announcement Alerts', 'Payroll updates and company announcements', Icons.campaign_outlined],
  ];

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
        const CircleAvatar(radius: 28, child: Icon(Icons.notifications, size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Text('Notifications', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
      ]))),
      const SizedBox(height: 14),
      ...items.map((item) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(child: Icon(item[2] as IconData)),
          title: Text(item[0] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(item[1] as String),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationDetailScreen(title: item[0] as String, icon: item[2] as IconData))),
        ),
      )),
    ],
  );
}

class NotificationDetailScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const NotificationDetailScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final entries = title == 'Leave Alerts'
        ? const [['Pending Approval', 'Leave request is waiting for approval.', 'Today'], ['Leave Approved', 'Employee leave request was approved.', 'Yesterday'], ['Leave Balance', 'Employee leave balance is running low.', '01 Sep 2026']]
        : title == 'Attendance Alerts'
            ? const [['Late Arrival', 'An employee checked in after shift start time.', 'Today'], ['Missing Punch', 'An attendance punch is missing for an employee.', 'Today'], ['Absent', 'Attendance has not been recorded for today.', 'Today']]
            : title == 'Payroll / Announcement Alerts'
                ? const [['Payroll Processing', 'Monthly payroll is ready for processing.', 'Today'], ['Payslip Published', 'New payslips are available for employees.', 'Yesterday'], ['Company Announcement', 'A new company announcement has been published.', '01 Sep 2026']]
                : const [['Leave Request', 'A new leave request needs your review.', 'Today'], ['Attendance Reminder', 'Missing punch reminder for an employee.', 'Today'], ['Payroll Update', 'Monthly payroll processing is ready for review.', 'Yesterday']];
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, index) => Card(child: ListTile(
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(entries[index][0], style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${entries[index][1]}\n${entries[index][2]}'),
          isThreeLine: true,
        )),
      ),
    );
  }
}
