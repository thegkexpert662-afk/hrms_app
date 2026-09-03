import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class DashboardScreen extends StatelessWidget {
  final HrmsService service;
  const DashboardScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final absent = service.employees.length - service.present - service.onLeave;
    final pendingRequests = service.pendingLeaves;
    final upcoming = service.employees
        .where((e) => e.joiningDate.month == now.month)
        .toList();
    final newJoiners = [...service.employees]
      ..sort((a, b) => b.joiningDate.compareTo(a.joiningDate));
    final birthdays = service.employees
        .where((e) => e.joiningDate.month == now.month)
        .toList();

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) => RefreshIndicator(
        onRefresh: () async => service.notifyListeners(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _header(context, now),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: [
                _metric('Total Employees', '${service.employees.length}', Icons.people_alt_rounded),
                _metric('Present', '${service.present}', Icons.check_circle_rounded),
                _metric('Absent', '$absent', Icons.person_off_rounded),
                _metric('On Leave', '${service.onLeave}', Icons.event_busy_rounded),
                _metric('Late', '${service.late}', Icons.schedule_rounded),
                _metric('Early Exit', '${service.earlyExit}', Icons.logout_rounded),
                _metric('WFH', '${service.wfh}', Icons.home_work_rounded),
                _metric('Pending Requests', '$pendingRequests', Icons.pending_actions_rounded),
              ],
            ),
            const SizedBox(height: 18),
            _section(
              context,
              'Upcoming Holidays',
              Icons.beach_access_rounded,
              upcoming.isEmpty
                  ? const Text('No upcoming holidays added.')
                  : Column(children: upcoming.take(5).map((e) => _personTile(e, 'Company holiday / event')).toList()),
            ),
            const SizedBox(height: 14),
            _section(
              context,
              'Birthdays / Anniversaries',
              Icons.celebration_rounded,
              birthdays.isEmpty
                  ? const Text('No birthdays or anniversaries this month.')
                  : Column(children: birthdays.take(5).map((e) => _personTile(e, 'This month')).toList()),
            ),
            const SizedBox(height: 14),
            _section(
              context,
              'New Joiners',
              Icons.person_add_rounded,
              newJoiners.isEmpty
                  ? const Text('No employees found.')
                  : Column(
                      children: newJoiners.take(5).map((e) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text(e.name.isEmpty ? '?' : e.name[0].toUpperCase())),
                          title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${e.designation} • ${e.department}'),
                          trailing: Text(_date(e.joiningDate)),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 14),
            _section(
              context,
              'Attendance Summary',
              Icons.bar_chart_rounded,
              Column(
                children: [
                  _progress('Present', service.present, service.employees.length),
                  _progress('Absent', absent, service.employees.length),
                  _progress('Late', service.late, service.employees.length),
                  _progress('On Leave', service.onLeave, service.employees.length),
                  _progress('WFH', service.wfh, service.employees.length),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, DateTime now) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(radius: 28, child: Icon(Icons.dashboard_rounded, size: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good day 👋', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  const Text('HRMS Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  Text(_date(now), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String title, String value, IconData icon) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 25),
            Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, IconData icon, Widget child) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, size: 21), const SizedBox(width: 9), Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]),
            const Divider(height: 22),
            child,
          ],
        ),
      ),
    );
  }

  Widget _personTile(Employee e, String label) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Text(e.name.isEmpty ? '?' : e.name[0].toUpperCase())),
        title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('$label • ${e.department}'),
      );

  Widget _progress(String label, int value, int total) {
    final ratio = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(children: [Expanded(child: Text(label)), Text('$value / $total', style: const TextStyle(fontWeight: FontWeight.w700))]),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: ratio, minHeight: 8, borderRadius: BorderRadius.circular(8)),
        ],
      ),
    );
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
