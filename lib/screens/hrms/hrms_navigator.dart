import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import 'employee_home_screen.dart';

/// Employee-only application shell.
/// Admin, management and company-configuration screens are not exposed here.
class HrmsNavigator extends StatefulWidget {
  final HrmsService service;

  const HrmsNavigator({super.key, required this.service});

  @override
  State<HrmsNavigator> createState() => _HrmsNavigatorState();
}

class _HrmsNavigatorState extends State<HrmsNavigator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employee Home',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              child: Icon(Icons.person_rounded),
            ),
          ),
        ],
      ),
      body: EmployeeHomeScreen(service: widget.service),
    );
  }
}
