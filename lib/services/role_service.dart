import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> currentRole() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return 'guest';
    final snap = await db.collection('users').doc(uid).get();
    return (snap.data()?['role'] as String?) ?? 'employee';
  }

  Future<bool> can(String permission) async {
    final role = await currentRole();
    const matrix = <String, Set<String>>{
      'owner': {'*'},
      'admin': {'employees.read', 'employees.write', 'attendance.read', 'attendance.write', 'leave.read', 'leave.approve', 'payroll.read', 'payroll.write', 'settings.write', 'reports.read', 'reports.export', 'notifications.write'},
      'hr': {'employees.read', 'employees.write', 'attendance.read', 'leave.read', 'leave.approve', 'reports.read', 'reports.export', 'notifications.write'},
      'manager': {'employees.read', 'attendance.read', 'leave.read', 'leave.approve', 'reports.read'},
      'employee': {'employees.self', 'attendance.self', 'leave.self', 'payslip.self'},
    };
    final permissions = matrix[role] ?? const <String>{};
    return permissions.contains('*') || permissions.contains(permission);
  }

  Future<void> setEmployeeRole({required String uid, required String role, required String companyId}) async {
    if (!{'admin', 'hr', 'manager', 'employee'}.contains(role)) throw ArgumentError('Invalid role');
    if (!await can('settings.write')) throw StateError('Administrator permission required');
    await db.collection('users').doc(uid).set({'role': role, 'companyId': companyId, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
}
