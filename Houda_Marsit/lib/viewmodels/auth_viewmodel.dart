import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valortrash/models/user_model.dart';
import 'package:valortrash/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- État (State) ---
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters ---
  UserModel? get user => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // ============================================================
  // 1. CONNEXION
  // ============================================================
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Appel au service d'authentification
      var userData = await _firebaseService.login(email, password);

      if (userData != null) {
        // 2. Récupérer les détails complets depuis Firestore 
        String uid = userData['id'];
        DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

        if (doc.exists) {
          _currentUser = UserModel.fromFirestore(doc);
        } else {
          _currentUser = UserModel(
            id: uid, 
            email: email, 
            role: UserModel.stringToRole(userData['role'])
          );
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Identifiants incorrects";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Erreur de connexion: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // 2. INSCRIPTION
  // ============================================================
  Future<bool> register(String email, String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    bool success = await _firebaseService.register(email, password, role);

    _isLoading = false;
    if (!success) {
      _errorMessage = "Erreur : Email peut-être déjà utilisé.";
    }
    notifyListeners();
    return success;
  }

  // ============================================================
  // 3. MISE À JOUR DU PROFIL
  // ============================================================
  Future<void> updateProfile(String name, String phone, String location) async {
    if (_currentUser == null) return;

    _currentUser = UserModel(
      id: _currentUser!.id,
      email: _currentUser!.email,
      role: _currentUser!.role,
      name: name,
      phone: phone,
      location: location,
    );
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'name': name,
        'phone': phone,
        'location': location,
      });
    } catch (e) {
      _errorMessage = "Erreur lors de la sauvegarde";
      print("Erreur update profil: $e");
    }
  }

  // ============================================================
  // 4. DÉCONNEXION
  // ============================================================
  
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null; 
    notifyListeners(); 
}
}