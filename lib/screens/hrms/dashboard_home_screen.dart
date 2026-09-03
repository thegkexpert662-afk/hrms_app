import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

/// Live HRMS dashboard. Values are derived from the current HrmsService state.
class DashboardHomeScreen extends StatelessWidget {
  final HrmsService service;
  const DashboardHomeScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        final now = DateTime.now();
        final total = service.employees.length;
        final present = service.present;
        final leave = service.onLeave;
        final absent = (total - present - leave).clamp(0, total);
        final newJoiners = [...service.employees]
          ..sort((a, b) => b.joiningDate.compareTo(a.joiningDate));

        return RefreshIndicator(
          onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 250)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            children: [
              _welcome(context, now),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  _metric('Total Employees', total, Icons.people_alt_rounded),
                  _metric('Present', present, Icons.check_circle_rounded),
                  _metric('Absent', absent, Icons.person_off_rounded),
                  _metric('On Leave', leave, Icons.event_busy_rounded),
                  _metric('Late', service.late, Icons.schedule_rounded),
                  _metric('Early Exit', service.earlyExit, Icons.logout_rounded),
                  _metric('WFH', service.wfh, Icons.home_work_rounded),
                  _metric('Pending Requests', service.pendingLeaves, Icons.pending_actions_rounded),
                ],
              ),
              const SizedBox(height: 16),
              _section(
                'Upcoming Holidays',
                Icons.beach_access_rounded,
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Icon(Icons.event_outlined)),
                  title: Text('No holidays added yet'),
                  subtitle: Text('Add holidays from Company Settings.'),
                ),
              ),
              const SizedBox(height: 12),
              _section(
                'Birthdays / Anniversaries',
                Icons.celebration_rounded,
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Icon(Icons.cake_outlined)),
                  title: Text('No birthday data available'),
                  subtitle: Text('Add employee date-of-birth and anniversary fields to enable this section.'),
                ),
              ),
              const SizedBox(height: 12),
              _section(
                'New Joiners',
                Icons.person_add_rounded,
                newJoiners.isEmpty
                    ? const ListTile(title: Text('No employees found'))
                    : Column(
                        children: newJoiners.take(5).map((e) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text(e.name.isEmpty ? '?' : e.name[0].toUpperCase())),
                          title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${e.designation} • ${e.department}'),
                          trailing: Text(_date(e.joiningDate)),
                        )).toList(),
                      ),
              ),
              const SizedBox(height: 12),
              _section(
                'Attendance Summary',
                Icons.bar_chart_rounded,
                Column(
                  children: [
                    _progress('Present', present, total),
                    _progress('Absent', absent, total),
                    _progress('Late', service.late, total),
                    _progress('Early Exit', service.earlyExit, total),
                    _progress('On Leave', leave, total),
                    _progress('WFH', service.wfh, total),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _welcome(BuildContext context, DateTime now) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        const CircleAvatar(radius: 28, child: Icon(Icons.dashboard_rounded, size: 30)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Good day 👋', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 3),
          const Text('HRMS Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text(_date(now), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ])),
      ]),
    ),
  );

  Widget _metric(String title, int value, IconData icon) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, size: 25),
        Text('$value', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _section(String title, IconData icon, Widget child) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 21), const SizedBox(width: 9), Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]),
        const Divider(height: 22),
        child,
      ]),
    ),
  );

  Widget _progress(String label, int value, int total) {
    final ratio = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(children: [
        Row(children: [Expanded(child: Text(label)), Text('$value / $total', style: const TextStyle(fontWeight: FontWeight.w700))]),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: ratio, minHeight: 8, borderRadius: BorderRadius.circular(8)),
      ]),
    );
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
