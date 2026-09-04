import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class DashboardHomeScreen extends StatefulWidget {
  final HrmsService service;
  const DashboardHomeScreen({super.key, required this.service});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  DateTime selectedDate = DateTime.now();

  HrmsService get service => widget.service;

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

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF4FBFF), Color(0xFFE9F8FC), Color(0xFFF8FCFF)],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(right: -28, top: 55, child: _WaterMark(size: 130)),
              const Positioned(left: -35, bottom: 15, child: _WaterMark(size: 155)),
              const Positioned(right: 110, bottom: 150, child: _WaterMark(size: 54)),
              RefreshIndicator(
                onRefresh: () async => service.notifyListeners(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _welcome(context, now),
                            const SizedBox(height: 14),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 620 ? 2 : 1;
                                return GridView.count(
                                  crossAxisCount: columns,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: columns == 4 ? 2.55 : 2.25,
                                  children: [
                                    _metric('Total Employees', total, Icons.people_alt_rounded),
                                    _metric('Present', present, Icons.how_to_reg_rounded),
                                    _metric('Absent', absent, Icons.person_off_rounded),
                                    _metric('On Leave', leave, Icons.event_busy_rounded),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth >= 900) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 3, child: _calendar(context)),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          children: [
                                            _section(
                                              'Birthdays / Anniversaries',
                                              Icons.celebration_rounded,
                                              _birthdayContent(),
                                            ),
                                            const SizedBox(height: 14),
                                            _section(
                                              'New Joiners',
                                              Icons.person_add_alt_1_rounded,
                                              _joinerContent(newJoiners),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _calendar(context),
                                    const SizedBox(height: 14),
                                    _section('Birthdays / Anniversaries', Icons.celebration_rounded, _birthdayContent()),
                                    const SizedBox(height: 14),
                                    _section('New Joiners', Icons.person_add_alt_1_rounded, _joinerContent(newJoiners)),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth >= 900) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _attendanceSummary(total, present, absent, leave)),
                                      const SizedBox(width: 14),
                                      Expanded(child: _quickInfo()),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _attendanceSummary(total, present, absent, leave),
                                    const SizedBox(height: 14),
                                    _quickInfo(),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _welcome(BuildContext context, DateTime now) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF087EA4), Color(0xFF2BA9C6)],
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF168AAD).withOpacity(.15), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.18), shape: BoxShape.circle),
            child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 29),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good day 👋', style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 13)),
                const SizedBox(height: 2),
                const Text('Welcome to HRMS', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
                Text('People make progress. Let’s grow together.', style: TextStyle(color: Colors.white.withOpacity(.84), fontSize: 12)),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 650)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.waves_rounded, color: Colors.white, size: 30),
                const SizedBox(height: 4),
                Text(_date(now), style: TextStyle(color: Colors.white.withOpacity(.84), fontSize: 12)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _metric(String title, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD8EEF5)),
        boxShadow: [BoxShadow(color: const Color(0xFF168AAD).withOpacity(.05), blurRadius: 9, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: Color(0xFFE1F5FA), shape: BoxShape.circle),
            child: Icon(icon, color: Color(0xFF168AAD), size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
              Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6EDF4)),
        boxShadow: [BoxShadow(color: const Color(0xFF168AAD).withOpacity(.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(color: Color(0xFFE1F5FA), shape: BoxShape.circle),
                child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF168AAD), size: 19),
              ),
              const SizedBox(width: 9),
              const Text('Calendar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(_date(selectedDate), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF168AAD))),
            ],
          ),
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
            currentDate: DateTime.now(),
            onDateChanged: (date) => setState(() => selectedDate = date),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(color: const Color(0xFFEAF8FC), borderRadius: BorderRadius.circular(11)),
            child: Row(
              children: [
                const Icon(Icons.event_available_rounded, color: Color(0xFF168AAD), size: 18),
                const SizedBox(width: 7),
                const Text('Selected Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(_date(selectedDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF168AAD))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _birthdayContent() {
    final now = DateTime.now();
    final birthdays = service.employees.where((e) => e.joiningDate.month == now.month).take(4).toList();
    if (birthdays.isEmpty) {
      return const _EmptyTile(icon: Icons.celebration_rounded, text: 'No birthdays or anniversaries this month.');
    }
    return Column(children: birthdays.map((e) => _personTile(e, 'This month')).toList());
  }

  Widget _joinerContent(List<Employee> employees) {
    if (employees.isEmpty) return const _EmptyTile(icon: Icons.person_add_alt_1_rounded, text: 'No new joiners found.');
    return Column(children: employees.take(4).map((e) => _personTile(e, _date(e.joiningDate))).toList());
  }

  Widget _personTile(Employee e, String label) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 17,
        backgroundColor: const Color(0xFFDDF5FA),
        child: Text(e.name.isEmpty ? '?' : e.name[0].toUpperCase()),
      ),
      title: Text(e.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: Text('$label • ${e.department}', style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _attendanceSummary(int total, int present, int absent, int leave) {
    return _section(
      'Attendance Summary',
      Icons.pie_chart_rounded,
      Column(
        children: [
          _miniProgress('Present', present, total),
          _miniProgress('Absent', absent, total),
          _miniProgress('Leave', leave, total),
          _miniProgress('Working Days', total == 0 ? 0 : 1, 1),
        ],
      ),
    );
  }

  Widget _miniProgress(String label, int value, int total) {
    final ratio = total == 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(width: 88, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 7,
                backgroundColor: const Color(0xFFE3F3F7),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2AA8C5)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text('$value', textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _quickInfo() {
    return _section(
      'Quick Info',
      Icons.info_outline_rounded,
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF168AAD), size: 26),
            SizedBox(width: 10),
            Expanded(child: Text('Keep your employee data updated and your team informed.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon, Widget child) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFD6EDF4)),
        boxShadow: [BoxShadow(color: const Color(0xFF168AAD).withOpacity(.04), blurRadius: 9, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: Color(0xFFE1F5FA), shape: BoxShape.circle),
                child: Icon(icon, color: Color(0xFF168AAD), size: 17),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
          const Divider(height: 18),
          child,
        ],
      ),
    );
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _EmptyTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
      decoration: BoxDecoration(color: const Color(0xFFF1F9FC), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF168AAD), size: 26),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _WaterMark extends StatelessWidget {
  final double size;
  const _WaterMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: .10,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.water_drop_rounded, size: size, color: const Color(0xFF168AAD)),
            Positioned(right: size * .13, top: size * .18, child: Icon(Icons.water_drop_rounded, size: size * .22, color: const Color(0xFF2AA8C5))),
          ],
        ),
      ),
    );
  }
}
