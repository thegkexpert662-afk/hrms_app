import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import 'employee_home_screen.dart';

class HrmsNavigator extends StatefulWidget {
  final HrmsService service;
  const HrmsNavigator({super.key, required this.service});

  @override
  State<HrmsNavigator> createState() => _HrmsNavigatorState();
}

class _HrmsNavigatorState extends State<HrmsNavigator> {
  int selected = 0;

  static const titles = <String>[
    'Home', 'My Attendance', 'Leave', 'Shift Change', 'Expense',
    'Travel', 'Short Time Off', 'Survey', 'My Team', 'Quick Info',
  ];

  static const icons = <IconData>[
    Icons.home_rounded, Icons.event_available_rounded, Icons.beach_access_rounded,
    Icons.swap_horiz_rounded, Icons.account_balance_wallet_rounded, Icons.flight_takeoff_rounded,
    Icons.timer_rounded, Icons.poll_rounded, Icons.groups_rounded, Icons.badge_rounded,
  ];

  Widget page() {
    if (selected == 0) return EmployeeHomeScreen(service: widget.service);
    return _placeholder(titles[selected], icons[selected]);
  }

  Widget _placeholder(String title, IconData icon) => Center(
    child: Card(
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 52, color: const Color(0xFF0788A8)),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Employee module'),
        ]),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(titles[selected], style: const TextStyle(fontWeight: FontWeight.w800)),
      actions: [
        IconButton(onPressed: () => setState(() {}), icon: const Icon(Icons.refresh_rounded)),
        const Padding(padding: EdgeInsets.only(right: 16), child: CircleAvatar(child: Icon(Icons.person_rounded))),
      ],
    ),
    drawer: Drawer(
      child: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF05617D), Color(0xFF0788A8)])),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(Icons.person_rounded, color: Color(0xFF05617D))),
              SizedBox(height: 10),
              Text('HRMS Employee', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              SizedBox(height: 3),
              Text('People • Process • Growth', style: TextStyle(color: Colors.white70)),
            ]),
          ),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: titles.length,
            itemBuilder: (context, index) => ListTile(
              selected: index == selected,
              selectedTileColor: const Color(0xFFE7F8FC),
              leading: Icon(icons[index], color: index == selected ? const Color(0xFF0788A8) : null),
              title: Text(titles[index]),
              onTap: () { setState(() => selected = index); Navigator.pop(context); },
            ),
          )),
        ]),
      ),
    ),
    body: page(),
    bottomNavigationBar: NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 0) setState(() => selected = 0);
        else _message(['Profile', 'Alerts', 'Settings'][index - 1]);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge_rounded), label: 'Profile'),
        NavigationDestination(icon: Icon(Icons.notifications_none_rounded), selectedIcon: Icon(Icons.notifications_rounded), label: 'Alerts'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
      ],
    ),
  );

  void _message(String title) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title module will be connected to the employee workflow.')));
}
