import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valortrash/models/request_model.dart';

class RequestViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // 1. LECTURE (STREAMS)
  // ============================================================

  /// Récupère les demandes reçues par un fournisseur
  Future<List<RequestModel>> getProviderRequests(String providerEmail) async {
    try {
      final snapshot = await _firestore
          .collection('requests')
          .where('providerEmail', isEqualTo: providerEmail)
          .orderBy('requestedAt', descending: true)
          .get(); 

      return snapshot.docs
          .map((doc) => RequestModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Erreur chargement demandes fournisseur: $e");
      return [];
    }
  }

  /// Récupère les demandes envoyées par un recycleur
  Future<List<RequestModel>> getRecyclerRequests(String recyclerEmail) async {
    try {
      final snapshot = await _firestore
          .collection('requests')
          .where('recyclerEmail', isEqualTo: recyclerEmail)
          .orderBy('requestedAt', descending: true)
          .get(); // Utilisation de .get()

      return snapshot.docs
          .map((doc) => RequestModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Erreur chargement demandes recycleur: $e");
      return [];
    }
  }
  // ============================================================
  // 2. ÉCRITURE (ACTIONS)
  // ============================================================

  /// Envoie une nouvelle demande de recyclage
  Future<void> sendRequest({
    required String offerId,
    required String offerType,
    required String providerEmail,
    required String recyclerEmail,
  }) async {
    try {
      await _firestore.collection('requests').add({
        'offerId': offerId,
        'offerType': offerType,
        'providerEmail': providerEmail,
        'recyclerEmail': recyclerEmail,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Erreur envoi demande: $e");
      rethrow; 
    }
  }

  /// Accepte une demande ET met à jour le statut de l'offre associée
  Future<void> acceptRequest(String requestId, String offerId) async {
    try {
      WriteBatch batch = _firestore.batch();

      // 1. Mettre à jour la demande
      DocumentReference requestRef = _firestore.collection('requests').doc(requestId);
      batch.update(requestRef, {'status': 'accepted'});

      // 2. Mettre à jour l'offre (la passer en "Non disponible")
      if (offerId.isNotEmpty) {
        DocumentReference offerRef = _firestore.collection('offers').doc(offerId);
        batch.update(offerRef, {'status': 'Non disponible'});
      }

      await batch.commit();
    } catch (e) {
      debugPrint("Erreur acceptation demande: $e");
      rethrow;
    }
  }

  /// Refuse une demande
  Future<void> rejectRequest(String requestId) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'rejected'
      });
    } catch (e) {
      debugPrint("Erreur refus demande: $e");
      rethrow;
    }
  }

  /// Supprime une demande (pour le recycleur ou nettoyage fournisseur)
  Future<void> deleteRequest(String requestId) async {
    try {
      await _firestore.collection('requests').doc(requestId).delete();
    } catch (e) {
      debugPrint("Erreur suppression demande: $e");
      rethrow;
    }
  }
}