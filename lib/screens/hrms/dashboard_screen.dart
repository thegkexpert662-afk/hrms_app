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
    final newJoiners = [...service.employees]..sort((a, b) => b.joiningDate.compareTo(a.joiningDate));
    final birthdays = service.employees.where((e) => e.joiningDate.month == now.month).toList();

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) => RefreshIndicator(
        onRefresh: () async => service.notifyListeners(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(context, now),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 620 ? 3 : 2;
                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: columns >= 4 ? 1.9 : 1.7,
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
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 900) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _section(context, 'Upcoming Holidays', Icons.beach_access_rounded, const Text('No upcoming holidays added.'))),
                              const SizedBox(width: 14),
                              Expanded(child: _section(context, 'Birthdays / Anniversaries', Icons.celebration_rounded,
                                birthdays.isEmpty ? const Text('No birthdays or anniversaries this month.') : Column(children: birthdays.take(4).map((e) => _personTile(e, 'This month')).toList()))),
                            ],
                          );
                        }
                        return Column(children: [
                          _section(context, 'Upcoming Holidays', Icons.beach_access_rounded, const Text('No upcoming holidays added.')),
                          const SizedBox(height: 14),
                          _section(context, 'Birthdays / Anniversaries', Icons.celebration_rounded,
                            birthdays.isEmpty ? const Text('No birthdays or anniversaries this month.') : Column(children: birthdays.take(4).map((e) => _personTile(e, 'This month')).toList())),
                        ]);
                      },
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 900) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _section(context, 'New Joiners', Icons.person_add_rounded,
                                newJoiners.isEmpty ? const Text('No employees found.') : Column(children: newJoiners.take(5).map((e) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(child: Text(e.name.isEmpty ? '?' : e.name[0].toUpperCase())),
                                  title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: Text('${e.designation} • ${e.department}'),
                                  trailing: Text(_date(e.joiningDate)),
                                )).toList()))),
                              const SizedBox(width: 14),
                              Expanded(child: _section(context, 'Attendance Summary', Icons.bar_chart_rounded, Column(children: [
                                _progress('Present', service.present, service.employees.length),
                                _progress('Absent', absent, service.employees.length),
                                _progress('Late', service.late, service.employees.length),
                                _progress('On Leave', service.onLeave, service.employees.length),
                                _progress('WFH', service.wfh, service.employees.length),
                              ]))),
                            ],
                          );
                        }
                        return Column(children: [
                          _section(context, 'New Joiners', Icons.person_add_rounded,
                            newJoiners.isEmpty ? const Text('No employees found.') : Column(children: newJoiners.take(5).map((e) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(child: Text(e.name.isEmpty ? '?' : e.name[0].toUpperCase())),
                              title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${e.designation} • ${e.department}'),
                              trailing: Text(_date(e.joiningDate)),
                            )).toList())),
                          const SizedBox(height: 14),
                          _section(context, 'Attendance Summary', Icons.bar_chart_rounded, Column(children: [
                            _progress('Present', service.present, service.employees.length),
                            _progress('Absent', absent, service.employees.length),
                            _progress('Late', service.late, service.employees.length),
                            _progress('On Leave', service.onLeave, service.employees.length),
                            _progress('WFH', service.wfh, service.employees.length),
                          ])),
                        ]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, DateTime now) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer.withOpacity(.72), scheme.surfaceContainerHighest.withOpacity(.7)],
        ),
        border: Border.all(color: scheme.primary.withOpacity(.10)),
      ),
      child: Stack(
        children: [
          Positioned(right: -24, top: -34, child: _waterBubble(130, scheme.primary.withOpacity(.08))),
          Positioned(right: 72, bottom: -54, child: _waterBubble(150, scheme.primary.withOpacity(.06))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary.withOpacity(.13)),
                child: Icon(Icons.water_drop_rounded, size: 29, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Good day 👋', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                const Text('HRMS Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                Text(_date(now), style: TextStyle(color: scheme.onSurfaceVariant)),
              ])),
              if (MediaQuery.sizeOf(context).width >= 650)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  decoration: BoxDecoration(color: scheme.surface.withOpacity(.75), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [Icon(Icons.auto_awesome_rounded, size: 17, color: scheme.primary), const SizedBox(width: 7), const Text('Live Overview', style: TextStyle(fontWeight: FontWeight.w700))]),
                ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _waterBubble(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Widget _metric(String title, String value, IconData icon) {
    return Builder(builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [scheme.surface, scheme.primaryContainer.withOpacity(.34)]),
          border: Border.all(color: scheme.primary.withOpacity(.09)),
          boxShadow: [BoxShadow(color: scheme.primary.withOpacity(.035), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary.withOpacity(.10)), child: Icon(icon, size: 21, color: scheme.primary)),
          const SizedBox(width: 11),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
          ])),
        ]),
      );
    });
  }

  Widget _section(BuildContext context, String title, IconData icon, Widget child) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: scheme.primary.withOpacity(.07))),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: scheme.primary.withOpacity(.09)), child: Icon(icon, size: 18, color: scheme.primary)), const SizedBox(width: 9), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))]),
        const Divider(height: 22),
        child,
      ]),
    );
  }

  Widget _personTile(Employee e, String label) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Text(e.name.isEmpty ? '?' : e.name[0].toUpperCase())), title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('$label • ${e.department}'));

  Widget _progress(String label, int value, int total) {
    final ratio = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(children: [
      Row(children: [Expanded(child: Text(label)), Text('$value / $total', style: const TextStyle(fontWeight: FontWeight.w700))]),
      const SizedBox(height: 6),
      LinearProgressIndicator(value: ratio, minHeight: 8, borderRadius: BorderRadius.circular(8)),
    ]));
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
