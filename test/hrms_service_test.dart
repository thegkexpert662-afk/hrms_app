import 'package:flutter_test/flutter_test.dart';
import 'package:hrms_app/app/hrms_app.dart';

void main() {
  test('attendance calculates working time and overtime', () {
    final record = AttendanceRecord(
      employeeId: 'EMP001',
      date: DateTime(2026, 1, 1),
      punchIn: DateTime(2026, 1, 1, 9),
      punchOut: DateTime(2026, 1, 1, 18),
      breakTime: const Duration(hours: 1),
    );

    expect(record.workingTime, const Duration(hours: 8));
    expect(record.overtime, Duration.zero);
  });

  test('leave days include both start and end dates', () {
    final leave = LeaveRequest(
      id: 'L1',
      employeeId: 'EMP001',
      type: 'Annual',
      from: DateTime(2026, 1, 10),
      to: DateTime(2026, 1, 12),
      reason: 'Personal',
    );

    expect(leave.days, 3);
  });

  test('payroll calculates gross and net salary', () {
    final payroll = PayrollRecord(
      employeeId: 'EMP001',
      basic: 30000,
      allowances: 5000,
      bonus: 2000,
      overtime: 1000,
      deductions: 3000,
    );

    expect(payroll.gross, 38000);
    expect(payroll.net, 35000);
  });
}
