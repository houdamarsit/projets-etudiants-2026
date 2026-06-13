import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valortrash/models/offer_model.dart';

class OfferViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // 1. LECTURE (STREAMS)
  // ============================================================

  /// Récupère les offres disponibles (Pour Recycleur / Recherche)
  Future<List<OfferModel>> getAvailableOffers() async {
    try {
      final snapshot = await _firestore
          .collection('offers')
          .where('status', isEqualTo: 'Disponible')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OfferModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("Erreur chargement offres: $e");
      return []; 
    }
  }

  /// Récupère TOUTES les offres d'un utilisateur (Pour Historique Fournisseur)
  Future<List<OfferModel>> getUserOffers(String userEmail) async {
    try {
      final snapshot = await _firestore
          .collection('offers')
          .where('userEmail', isEqualTo: userEmail)
          .orderBy('createdAt', descending: true)
          .get(); 

      return snapshot.docs
          .map((doc) => OfferModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("Erreur chargement offres utilisateur: $e");
      return [];
    }
  }
  /// Récupère les offres ACTIVES d'un utilisateur (Pour Dashboard Fournisseur)
  Stream<List<OfferModel>> getActiveUserOffers(String userEmail) {
    return _firestore
        .collection('offers')
        .where('userEmail', isEqualTo: userEmail)
        .where('status', isEqualTo: 'Disponible')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferModel.fromFirestore(doc))
            .toList());
  }

  /// Récupère TOUTES les offres (Pour Admin)
  Stream<List<OfferModel>> getAllOffers() {
    return _firestore
        .collection('offers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferModel.fromFirestore(doc))
            .toList());
  }

  // ============================================================
  // 2. ÉCRITURE (ACTIONS)
  // ============================================================

  /// Ajoute une nouvelle offre
  Future<void> addOffer({
    required String userEmail,
    required String materialType,
    required String quantity,
    required String location,
    required String transactionType,
    String? price,
    String status = 'Disponible',
  }) async {
    try {
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
    } catch (e) {
      debugPrint("Erreur ajout offre: $e");
      rethrow;
    }
  }

  /// Met à jour une offre existante
  Future<void> updateOffer(String offerId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('offers').doc(offerId).update(data);
    } catch (e) {
      debugPrint("Erreur mise à jour offre: $e");
      rethrow;
    }
  }

  /// Supprime une offre
  Future<void> deleteOffer(String offerId) async {
    try {
      await _firestore.collection('offers').doc(offerId).delete();
    } catch (e) {
      debugPrint("Erreur suppression offre: $e");
      rethrow;
    }
  }

  // ============================================================
  // 3. ADMINISTRATION
  // ============================================================

  /// Récupère la liste des utilisateurs (Pour Admin)
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  /// Supprime un utilisateur par email
  Future<void> deleteUser(String email) async {
    try {
      var query = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.delete();
      }
    } catch (e) {
      debugPrint("Erreur suppression user: $e");
      rethrow;
    }
  }
}