import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class DashboardScreen extends StatefulWidget {
  final HrmsService service;

  const DashboardScreen({super.key, required this.service});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime selectedDate = DateTime.now();

  HrmsService get service => widget.service;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final absent = service.employees.length - service.present - service.onLeave;
    final pendingRequests = service.pendingLeaves;
    final newJoiners = [...service.employees]
      ..sort((a, b) => b.joiningDate.compareTo(a.joiningDate));
    final birthdays = service.employees
        .where((e) => e.joiningDate.month == now.month)
        .toList();

    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF3FBFF),
                Color(0xFFE6F7FC),
                Color(0xFFF8FCFF),
              ],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () async => service.notifyListeners(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(context, now),
                        const SizedBox(height: 12),
                        _metricsGrid(context, absent, pendingRequests),
                        const SizedBox(height: 12),
                        _calendarAndHolidays(context),
                        const SizedBox(height: 12),
                        _peopleSections(context, birthdays, newJoiners),
                        const SizedBox(height: 12),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _metricsGrid(BuildContext context, int absent, int pendingRequests) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 620
                ? 3
                : 2;

        final metrics = [
          _metric('Total Employees', '${service.employees.length}', Icons.people_alt_rounded),
          _metric('Present', '${service.present}', Icons.check_circle_rounded),
          _metric('Absent', '$absent', Icons.person_off_rounded),
          _metric('On Leave', '${service.onLeave}', Icons.event_busy_rounded),
          _metric('Late', '${service.late}', Icons.schedule_rounded),
          _metric('Early Exit', '${service.earlyExit}', Icons.logout_rounded),
          _metric('WFH', '${service.wfh}', Icons.home_work_rounded),
          _metric('Pending', '$pendingRequests', Icons.pending_actions_rounded),
        ];

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: columns >= 4 ? 2.15 : 1.8,
          children: metrics,
        );
      },
    );
  }

  Widget _calendarAndHolidays(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final calendar = _calendarCard(context);
        final holidays = _section(
          context,
          'Upcoming Holidays',
          Icons.beach_access_rounded,
          const Text('No upcoming holidays added.'),
        );

        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: calendar),
              const SizedBox(width: 12),
              Expanded(child: holidays),
            ],
          );
        }

        return Column(
          children: [
            calendar,
            const SizedBox(height: 12),
            holidays,
          ],
        );
      },
    );
  }

  Widget _peopleSections(
    BuildContext context,
    List<Employee> birthdays,
    List<Employee> newJoiners,
  ) {
    final birthdaySection = _section(
      context,
      'Birthdays / Anniversaries',
      Icons.celebration_rounded,
      birthdays.isEmpty
          ? const Text('No birthdays or anniversaries this month.')
          : Column(
              children: birthdays
                  .take(4)
                  .map((employee) => _personTile(employee, 'This month'))
                  .toList(),
            ),
    );

    final joinerSection = _section(
      context,
      'New Joiners',
      Icons.person_add_rounded,
      newJoiners.isEmpty
          ? const Text('No employees found.')
          : Column(
              children: newJoiners.take(5).map((employee) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFDDF5FA),
                    child: Text(
                      employee.name.isEmpty
                          ? '?'
                          : employee.name[0].toUpperCase(),
                    ),
                  ),
                  title: Text(
                    employee.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${employee.designation} • ${employee.department}',
                  ),
                  trailing: Text(_date(employee.joiningDate)),
                );
              }).toList(),
            ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: birthdaySection),
              const SizedBox(width: 12),
              Expanded(child: joinerSection),
            ],
          );
        }

        return Column(
          children: [
            birthdaySection,
            const SizedBox(height: 12),
            joinerSection,
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context, DateTime now) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF087EA4), Color(0xFF2AA8C5)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x29168AAD),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day 👋',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'HRMS Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _date(now),
                  style: TextStyle(
                    color: Colors.white.withOpacity(.82),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.waves_rounded,
            color: Colors.white.withOpacity(.75),
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _metric(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFE8F8FC)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD2EEF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F168AAD),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE4F6FA),
            ),
            child: Icon(icon, color: Color(0xFF168AAD), size: 19),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF55717A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFEAF8FC)],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD7EEF4)),
      ),
      padding: const EdgeInsets.fromLTRB(10, 11, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F5FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  size: 17,
                  color: Color(0xFF168AAD),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Calendar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                _date(selectedDate),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF168AAD),
                ),
              ),
            ],
          ),
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
            currentDate: DateTime.now(),
            onDateChanged: (date) {
              setState(() => selectedDate = date);
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F7FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  size: 17,
                  color: Color(0xFF168AAD),
                ),
                const SizedBox(width: 7),
                Text(
                  'Selected: ${_date(selectedDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    IconData icon,
    Widget child,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD7EEF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A168AAD),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE1F5FA),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Color(0xFF168AAD), size: 17),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _personTile(Employee employee, String label) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 17,
        backgroundColor: const Color(0xFFDDF5FA),
        child: Text(
          employee.name.isEmpty ? '?' : employee.name[0].toUpperCase(),
        ),
      ),
      title: Text(
        employee.name,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      subtitle: Text(
        '$label • ${employee.department}',
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget _progress(String label, int value, int total) {
    final ratio = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 12)),
              ),
              Text(
                '$value / $total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: const Color(0xFFE2F2F6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF27A8C4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _date(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
