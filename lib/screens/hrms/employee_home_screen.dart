import 'package:flutter/material.dart';

import '../../app/hrms_app.dart';
import 'employee_module_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final HrmsService service;
  const EmployeeHomeScreen({super.key, required this.service});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  DateTime month = DateTime.now();

  static const Color water = Color(0xFF0788A8);
  static const Color waterDark = Color(0xFF05617D);
  static const Color waterLight = Color(0xFFE7F8FC);

  @override
  Widget build(BuildContext context) {
    final employee = widget.service.employees.isNotEmpty ? widget.service.employees.first : null;
    final today = DateTime.now();
    final record = employee == null ? null : widget.service.todayFor(employee.id);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4FCFE), Colors.white],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(right: -45, top: 40, child: _WatermarkDrop(size: 150)),
          const Positioned(left: -55, bottom: 120, child: _WatermarkDrop(size: 180)),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _hero(employee),
              const SizedBox(height: 14),
              _applications(context, employee, record),
              const SizedBox(height: 14),
              _viewSection(context),
              const SizedBox(height: 14),
              _infoCard(
                icon: Icons.campaign_rounded,
                title: 'Corporate Guidelines',
                child: Row(
                  children: [
                    const Expanded(child: Text('Company policies, notices and important updates.')),
                    FilledButton(onPressed: () => _openModule('Corporate Guidelines', Icons.campaign_rounded), child: const Text('View')),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _birthdaySection(employee),
              const SizedBox(height: 14),
              _anniversarySection(employee),
              const SizedBox(height: 14),
              _calendar(today),
              const SizedBox(height: 14),
              _quote(),
              const SizedBox(height: 14),
              _simpleSection('For New Joinee', 'Details will appear here when available.'),
              const SizedBox(height: 14),
              _simpleSection('Today’s Menu (Meal)', 'Meal details will appear here when available.'),
              const SizedBox(height: 14),
              _simpleSection('Poll of the Day', 'No poll available today.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hero(Employee? employee) {
    final name = employee?.name.isNotEmpty == true ? employee!.name : 'Employee';
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [waterDark, water]),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, color: waterDark, size: 34),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HRMS EMPLOYEE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('Welcome, $name', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(employee?.designation ?? 'Employee', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            IconButton(onPressed: () => setState(() {}), icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _applications(BuildContext context, Employee? employee, AttendanceRecord? record) {
    final apps = [
      _App('Survey', Icons.poll_rounded, const Color(0xFF4FB9C9)),
      _App('Leave', Icons.beach_access_rounded, const Color(0xFF4D9BAA)),
      _App('Leave Cancellation', Icons.event_busy_rounded, const Color(0xFF3C8D9D)),
      _App('OD', Icons.directions_walk_rounded, const Color(0xFF35B982)),
      _App('CO+', Icons.account_tree_rounded, const Color(0xFF9B4BB4)),
      _App('Swipe', Icons.touch_app_rounded, const Color(0xFFF1B84B)),
      _App('Short Time Off', Icons.timer_rounded, const Color(0xFFB5B42A)),
      _App('Shift Change', Icons.swap_horiz_rounded, const Color(0xFF58788F)),
      _App('Expense', Icons.account_balance_wallet_rounded, const Color(0xFFD0A35C)),
      _App('Travel', Icons.flight_takeoff_rounded, const Color(0xFF5BAA9D)),
    ];
    return _panel(
      title: 'Applications',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 560 ? 3 : 5;
          return GridView.builder(
            itemCount: apps.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .88,
            ),
            itemBuilder: (_, i) => _applicationTile(apps[i], () => _openModule(apps[i].label, apps[i].icon, accent: apps[i].color)),
          );
        },
      ),
    );
  }

  Widget _viewSection(BuildContext context) {
    final items = [
      ['Self Service', Icons.directions_walk_rounded],
      ['My Team', Icons.account_tree_rounded],
      ['My Attendance', Icons.event_available_rounded],
      ['Quick Info', Icons.badge_rounded],
    ];
    return _panel(
      title: 'View',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 560 ? 3 : 4;
          return GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.15),
            itemBuilder: (_, i) => _viewTile(items[i][0] as String, items[i][1] as IconData, () => _openModule(items[i][0] as String, items[i][1] as IconData)),
          );
        },
      ),
    );
  }

  Widget _birthdaySection(Employee? employee) {
    return _panel(
      title: 'Birthday',
      trailing: TextButton(onPressed: () => _openModule('Birthdays', Icons.cake_rounded), child: const Text('View All')),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(radius: 28, child: Icon(Icons.cake_rounded)),
        title: Text(employee?.name ?? 'No birthday data'),
        subtitle: Text(employee == null ? 'Details not available.' : 'Birthday information will appear here.'),
      ),
    );
  }

  Widget _anniversarySection(Employee? employee) {
    return _panel(
      title: 'Work Anniversary',
      child: employee == null
          ? const Text('Details not available.')
          : ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.workspace_premium_rounded)),
              title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Joined ${_date(employee.joiningDate)}'),
            ),
    );
  }

  Widget _calendar(DateTime today) {
    final first = DateTime(month.year, month.month, 1);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final offset = first.weekday % 7;
    final cells = <Widget>[];
    for (var i = 0; i < offset; i++) cells.add(const SizedBox());
    for (var day = 1; day <= days; day++) {
      final selected = day == today.day && month.year == today.year && month.month == today.month;
      cells.add(Container(
        decoration: BoxDecoration(color: selected ? water : Colors.white, border: Border.all(color: const Color(0xFFD9E9ED))),
        alignment: Alignment.center,
        child: Text('$day', style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w500, color: selected ? Colors.white : const Color(0xFF334155))),
      ));
    }
    return _panel(
      title: 'My Calendar',
      child: Column(
        children: [
          Row(children: [IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month - 1)), icon: const Icon(Icons.chevron_left_rounded)), Expanded(child: Center(child: Text('${_monthName(month.month)} ${month.year}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)))), IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month + 1)), icon: const Icon(Icons.chevron_right_rounded))]),
          Row(children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.w700, color: water)))))).toList()),
          GridView.count(crossAxisCount: 7, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.35, children: cells),
          const SizedBox(height: 12),
          const Align(alignment: Alignment.centerLeft, child: Text('Attendance is updated from your daily punch records.', style: TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }

  Widget _quote() => _panel(
    child: Row(children: [const Icon(Icons.format_quote_rounded, size: 38, color: water), const SizedBox(width: 12), const Expanded(child: Text('Great teams build great organizations.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))]),
  );

  Widget _simpleSection(String title, String text) => _panel(title: title, child: Text(text));

  Widget _infoCard({required IconData icon, required String title, required Widget child}) => _panel(title: title, icon: icon, child: child);

  Widget _panel({String? title, IconData? icon, Widget? trailing, required Widget child}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFFDCEEF2))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title != null) ...[
            Row(children: [if (icon != null) ...[Icon(icon, color: water), const SizedBox(width: 8)], Expanded(child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800))), if (trailing != null) trailing]),
            const Divider(height: 22),
          ],
          child,
        ]),
      ),
    );
  }

  Widget _applicationTile(_App app, VoidCallback onTap) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(color: app.color, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x16000000))]),
      padding: const EdgeInsets.all(10),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(app.icon, color: Colors.white, size: 34), Text(app.label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
    ),
  );

  Widget _viewTile(String label, IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      decoration: BoxDecoration(color: waterLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFC7EAF0))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: water, size: 32), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, color: waterDark))]),
    ),
  );

  void _openModule(String title, IconData icon, {Color accent = water}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmployeeModuleScreen(title: title, icon: icon, accent: accent),
      ),
    );
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  String _monthName(int m) => const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m - 1];
}

class _App {
  final String label;
  final IconData icon;
  final Color color;
  const _App(this.label, this.icon, this.color);
}

class _WatermarkDrop extends StatelessWidget {
  final double size;
  const _WatermarkDrop({required this.size});

  @override
  Widget build(BuildContext context) => Opacity(opacity: .08, child: Icon(Icons.water_drop_rounded, size: size, color: const Color(0xFF0788A8)));
}
