import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  // AUTHENTIFICATION (Inscription / Connexion)
  // ============================================================

  // Inscription (Vérifie si l'email existe, puis crée l'utilisateur)
  Future<bool> register(String email, String password, String role) async {
    try {
      // Vérifier si l'email existe déjà
      var query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (query.docs.isNotEmpty) return false; // Email déjà utilisé

      // Créer l'utilisateur
      await _firestore.collection('users').add({
        'email': email,
        'password': password, 
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Erreur lors de l'inscription: $e");
      return false;
    }
  }

  // Connexion 
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      var query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (query.docs.isNotEmpty) {
        var doc = query.docs.first;
        return {
          'id': doc.id,
          'email': doc['email'],
          'role': doc['role'],
        };
      }
      return null;
    } catch (e) {
      print("Erreur de connexion: $e");
      return null;
    }
  }

  // ============================================================
  // GESTION DES UTILISATEURS (Admin)
  // ============================================================

  Future<void> updateUser(String email, Map<String, dynamic> data) async {
    try {
      var query = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update(data);
      }
    } catch (e) {
      print("Erreur mise à jour: $e");
    }
  }

  Future<void> deleteUser(String email) async {
    try {
      var query = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.delete();
      }
    } catch (e) {
      print("Erreur suppression user: $e");
    }
  }

  // ============================================================
  // GESTION DES OFFRES
  // ============================================================

  Future<void> addOffer({
    required String userEmail,
    required String materialType,
    required String quantity,
    required String location,
    required String transactionType,
    String? price,
    String status = 'Disponible',
  }) async {
    await _firestore.collection('offers').add({
      'userEmail': userEmail,
      'materialType': materialType,
      'quantity': quantity,
      'location': location,
      'transactionType': transactionType,
      'price': price ?? '',
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteOffer(String offerId) async {
    try {
      await _firestore.collection('offers').doc(offerId).delete();
    } catch (e) {
      print("Erreur suppression offre: $e");
    }
  }

  // ============================================================
  // AUTRES (Articles, Images)
  // ============================================================

  // Récupérer les articles 
  Stream<QuerySnapshot> getArticles() {
    return _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Upload d'image 
  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('uploads/$fileName');
      TaskSnapshot snapshot = await ref.putFile(imageFile);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erreur upload image: $e");
      return null;
    }
  }
}