import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  FirebaseApp get app => Firebase.app();
}