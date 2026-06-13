import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valortrash/services/firebase_service.dart';

class ArticleViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // Récupère le flux des articles depuis le service
  Stream<QuerySnapshot> getArticles() {
    return _firebaseService.getArticles();
  }
}