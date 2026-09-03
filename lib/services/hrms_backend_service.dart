import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app/hrms_app.dart';

class HrmsBackendService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? companyId;

  User? get user => auth.currentUser;

  Future<void> saveOnboarding({required String fullName, required String email, required String companyName, required String address, required String city, required String pin}) async {
    final currentUser = user;
    if (currentUser == null) throw StateError('User is not authenticated');
    companyId ??= currentUser.uid;
    final batch = db.batch();
    final userRef = db.collection('users').doc(currentUser.uid);
    final companyRef = db.collection('companies').doc(companyId);
    batch.set(userRef, {'uid': currentUser.uid, 'phone': currentUser.phoneNumber ?? '', 'name': fullName, 'email': email, 'companyId': companyId, 'role': 'admin', 'updatedAt': FieldValue.serverTimestamp(), 'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    batch.set(companyRef, {'name': companyName, 'address': address, 'city': city, 'pin': pin, 'ownerId': currentUser.uid, 'updatedAt': FieldValue.serverTimestamp(), 'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> loadCompanyId() async {
    final currentUser = user;
    if (currentUser == null) return;
    final snap = await db.collection('users').doc(currentUser.uid).get();
    companyId = (snap.data()?['companyId'] as String?) ?? currentUser.uid;
  }

  CollectionReference<Map<String, dynamic>> _employees() => db.collection('companies').doc(companyId).collection('employees');
  CollectionReference<Map<String, dynamic>> _attendance() => db.collection('companies').doc(companyId).collection('attendance');
  CollectionReference<Map<String, dynamic>> _leaves() => db.collection('companies').doc(companyId).collection('leaves');

  Future<void> hydrate(HrmsService service) async {
    await loadCompanyId();
    if (companyId == null) return;
    final employeeSnap = await _employees().get();
    if (employeeSnap.docs.isNotEmpty) {
      service.employees
        ..clear()
        ..addAll(employeeSnap.docs.map((d) => _employeeFromMap(d.data(), d.id)));
    }
    final attendanceSnap = await _attendance().limit(500).get();
    service.attendance
      ..clear()
      ..addAll(attendanceSnap.docs.map(_attendanceFromMap));
    final leaveSnap = await _leaves().limit(500).get();
    service.leaves
      ..clear()
      ..addAll(leaveSnap.docs.map(_leaveFromMap));
  }

  Employee _employeeFromMap(Map<String, dynamic> d, String id) {
    final ts = d['joiningDate'];
    return Employee(id: d['id'] as String? ?? id, name: d['name'] as String? ?? '', department: d['department'] as String? ?? '', designation: d['designation'] as String? ?? '', manager: d['manager'] as String? ?? '', joiningDate: ts is Timestamp ? ts.toDate() : DateTime.now(), employmentType: d['employmentType'] as String? ?? 'Full Time', status: d['status'] as String? ?? 'Active', phone: d['phone'] as String? ?? '', email: d['email'] as String? ?? '', gender: d['gender'] as String? ?? '', dob: d['dob'] as String? ?? '', address: d['address'] as String? ?? '', city: d['city'] as String? ?? '', state: d['state'] as String? ?? '', pinCode: d['pinCode'] as String? ?? '', emergencyName: d['emergencyName'] as String? ?? '', emergencyRelation: d['emergencyRelation'] as String? ?? '', emergencyPhone: d['emergencyPhone'] as String? ?? '', bankName: d['bankName'] as String? ?? '', accountNumber: d['accountNumber'] as String? ?? '', ifsc: d['ifsc'] as String? ?? '', documentName: d['documentName'] as String? ?? '', documentNumber: d['documentNumber'] as String? ?? '', bloodGroup: d['bloodGroup'] as String? ?? '', skills: d['skills'] as String? ?? '', education: d['education'] as String? ?? '', experience: d['experience'] as String? ?? '');
  }

  AttendanceRecord _attendanceFromMap(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final x = d.data();
    DateTime date = DateTime.now();
    DateTime? asDate(dynamic v) => v is Timestamp ? v.toDate() : null;
    date = asDate(x['date']) ?? date;
    return AttendanceRecord(employeeId: x['employeeId'] as String? ?? '', date: date, punchIn: asDate(x['punchIn']), punchOut: asDate(x['punchOut']), breakTime: Duration(minutes: (x['breakMinutes'] as num?)?.toInt() ?? 0), status: x['status'] as String? ?? 'Present', wfh: x['wfh'] as bool? ?? false);
  }

  LeaveRequest _leaveFromMap(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final x = d.data();
    DateTime asDate(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
    return LeaveRequest(id: x['id'] as String? ?? d.id, employeeId: x['employeeId'] as String? ?? '', type: x['type'] as String? ?? 'Leave', from: asDate(x['from']), to: asDate(x['to']), reason: x['reason'] as String? ?? '', status: x['status'] as String? ?? 'Pending');
  }

  Future<void> saveEmployee(Employee employee) async {
    if (companyId == null) await loadCompanyId();
    if (companyId == null) return;
    await _employees().doc(employee.id).set({'id': employee.id, 'name': employee.name, 'department': employee.department, 'designation': employee.designation, 'manager': employee.manager, 'joiningDate': Timestamp.fromDate(employee.joiningDate), 'employmentType': employee.employmentType, 'status': employee.status, 'phone': employee.phone, 'email': employee.email, 'gender': employee.gender, 'dob': employee.dob, 'address': employee.address, 'city': employee.city, 'state': employee.state, 'pinCode': employee.pinCode, 'emergencyName': employee.emergencyName, 'emergencyRelation': employee.emergencyRelation, 'emergencyPhone': employee.emergencyPhone, 'bankName': employee.bankName, 'accountNumber': employee.accountNumber, 'ifsc': employee.ifsc, 'documentName': employee.documentName, 'documentNumber': employee.documentNumber, 'bloodGroup': employee.bloodGroup, 'skills': employee.skills, 'education': employee.education, 'experience': employee.experience, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> deleteEmployee(String id) async { if (companyId == null) await loadCompanyId(); if (companyId != null) await _employees().doc(id).delete(); }

  Future<void> saveAttendance(AttendanceRecord record) async {
    if (companyId == null) await loadCompanyId();
    if (companyId == null) return;
    final key = '${record.employeeId}_${record.date.year}_${record.date.month}_${record.date.day}';
    await _attendance().doc(key).set({'employeeId': record.employeeId, 'date': Timestamp.fromDate(record.date), 'punchIn': record.punchIn == null ? null : Timestamp.fromDate(record.punchIn!), 'punchOut': record.punchOut == null ? null : Timestamp.fromDate(record.punchOut!), 'breakMinutes': record.breakTime.inMinutes, 'status': record.status, 'wfh': record.wfh, 'workingMinutes': record.workingTime.inMinutes, 'overtimeMinutes': record.overtime.inMinutes, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> saveLeave(LeaveRequest request) async {
    if (companyId == null) await loadCompanyId();
    if (companyId == null) return;
    await _leaves().doc(request.id).set({'id': request.id, 'employeeId': request.employeeId, 'type': request.type, 'reason': request.reason, 'from': Timestamp.fromDate(request.from), 'to': Timestamp.fromDate(request.to), 'days': request.days, 'status': request.status, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> updateLeaveStatus(String id, String status) async { if (companyId == null) await loadCompanyId(); if (companyId != null) await _leaves().doc(id).set({'status': status, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true)); }

  Stream<QuerySnapshot<Map<String, dynamic>>> notificationStream() async* {
    if (companyId == null) await loadCompanyId();
    if (companyId == null) return;
    yield* db.collection('companies').doc(companyId).collection('notifications').orderBy('createdAt', descending: true).limit(50).snapshots();
  }

  Future<void> saveNotification({required String title, required String body, String type = 'general'}) async {
    if (companyId == null) await loadCompanyId();
    if (companyId == null) return;
    await db.collection('companies').doc(companyId).collection('notifications').add({'title': title, 'body': body, 'type': type, 'createdAt': FieldValue.serverTimestamp(), 'createdBy': user?.uid});
  }

  Future<void> saveSettings(String section, Map<String, dynamic> values) async {
    if (companyId == null) await loadCompanyId();
    if (companyId == null) return;
    await db.collection('companies').doc(companyId).collection('settings').doc(section).set({...values, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getSettings(String section) async {
    if (companyId == null) await loadCompanyId();
    if (companyId == null) return <String, dynamic>{};
    final snap = await db.collection('companies').doc(companyId).collection('settings').doc(section).get();
    return snap.data() ?? <String, dynamic>{};
  }

  Future<void> saveOfficeLocation({required String id, required String name, required double latitude, required double longitude, required double radiusMeters}) async {
    if (companyId == null) await loadCompanyId();
    if (companyId == null) return;
    await db.collection('companies').doc(companyId).collection('officeLocations').doc(id).set({'name': name, 'latitude': latitude, 'longitude': longitude, 'radiusMeters': radiusMeters, 'enabled': true, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
}
