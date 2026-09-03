import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class NotificationsScreen extends StatelessWidget {
  final HrmsService service;

  const NotificationsScreen({super.key, required this.service});

  static const _items = <_NotificationModule>[
    _NotificationModule(
      title: 'Notification Center',
      subtitle: 'View, filter and manage HRMS notifications',
      icon: Icons.notifications_outlined,
      builder: _buildCenter,
    ),
    _NotificationModule(
      title: 'Leave Alerts',
      subtitle: 'Leave requests, approvals and balance alerts',
      icon: Icons.event_available_outlined,
      builder: _buildLeave,
    ),
    _NotificationModule(
      title: 'Attendance Alerts',
      subtitle: 'Late, absent and missing-punch alerts',
      icon: Icons.access_time_outlined,
      builder: _buildAttendance,
    ),
    _NotificationModule(
      title: 'Payroll / Announcement Alerts',
      subtitle: 'Payroll updates and company announcements',
      icon: Icons.campaign_outlined,
      builder: _buildPayroll,
    ),
  ];

  static Widget _buildCenter(BuildContext context, HrmsService service) =>
      NotificationCenterScreen(service: service);

  static Widget _buildLeave(BuildContext context, HrmsService service) =>
      LeaveAlertsScreen(service: service);

  static Widget _buildAttendance(BuildContext context, HrmsService service) =>
      AttendanceAlertsScreen(service: service);

  static Widget _buildPayroll(BuildContext context, HrmsService service) =>
      PayrollAnnouncementAlertsScreen(service: service);

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
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.notifications, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ..._items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(child: Icon(item.icon)),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => item.builder(context, service),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationModule {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function(BuildContext, HrmsService) builder;

  const _NotificationModule({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });
}

class _NotificationPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_NotificationItem> items;

  const _NotificationPage({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(item.icon ?? icon)),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${item.message}\n${item.time}'),
              ),
              isThreeLine: true,
              trailing: item.unread
                  ? const Icon(Icons.circle, size: 10)
                  : const Icon(Icons.check_circle_outline),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final String time;
  final bool unread;
  final IconData? icon;

  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    this.unread = true,
    this.icon,
  });
}

class NotificationCenterScreen extends StatelessWidget {
  final HrmsService service;

  const NotificationCenterScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return _NotificationPage(
      title: 'Notification Center',
      icon: Icons.notifications_outlined,
      items: const [
        _NotificationItem(
          title: 'Leave Request',
          message: 'A new leave request needs your review.',
          time: 'Today',
        ),
        _NotificationItem(
          title: 'Attendance Reminder',
          message: 'Missing punch reminder for an employee.',
          time: 'Today',
          unread: false,
        ),
        _NotificationItem(
          title: 'Payroll Update',
          message: 'Monthly payroll processing is ready for review.',
          time: 'Yesterday',
        ),
      ],
    );
  }
}

class LeaveAlertsScreen extends StatelessWidget {
  final HrmsService service;

  const LeaveAlertsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return _NotificationPage(
      title: 'Leave Alerts',
      icon: Icons.event_available_outlined,
      items: const [
        _NotificationItem(
          title: 'Pending Approval',
          message: 'Leave request is waiting for approval.',
        ),
        _NotificationItem(
          title: 'Leave Approved',
          message: 'Employee leave request was approved.',
          time: 'Yesterday',
          unread: false,
        ),
        _NotificationItem(
          title: 'Leave Balance',
          message: 'Employee leave balance is running low.',
          time: '01 Sep 2026',
        ),
      ],
    );
  }
}

class AttendanceAlertsScreen extends StatelessWidget {
  final HrmsService service;

  const AttendanceAlertsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return _NotificationPage(
      title: 'Attendance Alerts',
      icon: Icons.access_time_outlined,
      items: const [
        _NotificationItem(
          title: 'Late Arrival',
          message: 'An employee checked in after shift start time.',
        ),
        _NotificationItem(
          title: 'Missing Punch',
          message: 'An attendance punch is missing for an employee.',
        ),
        _NotificationItem(
          title: 'Absent',
          message: 'Attendance has not been recorded for today.',
          time: 'Today',
          unread: false,
        ),
      ],
    );
  }
}

class PayrollAnnouncementAlertsScreen extends StatelessWidget {
  final HrmsService service;

  const PayrollAnnouncementAlertsScreen({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return _NotificationPage(
      title: 'Payroll / Announcement Alerts',
      icon: Icons.campaign_outlined,
      items: const [
        _NotificationItem(
          title: 'Payroll Processing',
          message: 'Monthly payroll is ready for processing.',
        ),
        _NotificationItem(
          title: 'Payslip Published',
          message: 'New payslips are available for employees.',
          time: 'Yesterday',
          unread: false,
        ),
        _NotificationItem(
          title: 'Company Announcement',
          message: 'A new company announcement has been published.',
          time: '01 Sep 2026',
        ),
      ],
    );
  }
}
