import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore db;
  FirestoreService({FirebaseFirestore? firestore}) : db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String name) => db.collection(name);

  Future<void> set(String collectionName, String id, Map<String, dynamic> data) async {
    await collection(collectionName).doc(id).set({...data, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> add(String collectionName, Map<String, dynamic> data) async {
    await collection(collectionName).add({...data, 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> remove(String collectionName, String id) => collection(collectionName).doc(id).delete();

  Stream<QuerySnapshot<Map<String, dynamic>>> watch(String collectionName) => collection(collectionName).orderBy('updatedAt', descending: true).snapshots();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> list(String collectionName) async => (await collection(collectionName).get()).docs;

  Future<void> writeAttendance({required String employeeId, required DateTime time, required String action, double? latitude, double? longitude, bool wfh = false}) async {
    await add('attendance', {
      'employeeId': employeeId,
      'action': action,
      'timestamp': Timestamp.fromDate(time),
      'latitude': latitude,
      'longitude': longitude,
      'wfh': wfh,
    });
  }

  Future<void> writeAudit({required String actorId, required String action, required String module, Map<String, dynamic>? details}) async {
    await add('auditLogs', {'actorId': actorId, 'action': action, 'module': module, 'details': details ?? {}});
  }
}
