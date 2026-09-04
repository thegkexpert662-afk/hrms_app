import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import 'employee_home_screen.dart';

/// Employee-only application shell.
/// Admin and management screens are not exposed in the current release.
class HrmsNavigator extends StatelessWidget {
  final HrmsService service;
  const HrmsNavigator({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmployeeHomeScreen(service: service),
    );
  }
}
