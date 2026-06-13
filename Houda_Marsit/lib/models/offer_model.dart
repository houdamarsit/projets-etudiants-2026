import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String userEmail;
  final String materialType;
  final String quantity;
  final String location;
  final String transactionType;
  final String price;
  final String status;
  final DateTime? createdAt; // AJOUT IMPORTANT

  OfferModel({
    required this.id,
    required this.userEmail,
    required this.materialType,
    required this.quantity,
    required this.location,
    required this.transactionType,
    required this.price,
    required this.status,
    this.createdAt,
  });

  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Gestion de la date
    DateTime? date;
    if (data['createdAt'] != null) {
       date = (data['createdAt'] as Timestamp).toDate();
    }

    return OfferModel(
      id: doc.id,
      userEmail: data['userEmail'] ?? '',
      materialType: data['materialType'] ?? 'Inconnu',
      quantity: data['quantity']?.toString() ?? '0',
      location: data['location'] ?? '',
      transactionType: data['transactionType'] ?? '',
      price: data['price']?.toString() ?? '',
      status: data['status'] ?? 'Disponible',
      createdAt: date, 
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
      'materialType': materialType,
      'quantity': quantity,
      'location': location,
      'transactionType': transactionType,
      'price': price,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(), 
    };
  }
}