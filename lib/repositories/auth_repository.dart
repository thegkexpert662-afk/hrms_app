import '../services/firebase_service.dart';

class AuthRepository {
  final FirebaseService _firebaseService;

  AuthRepository({
    FirebaseService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseService.instance;

  FirebaseService get firebaseService => _firebaseService;
}