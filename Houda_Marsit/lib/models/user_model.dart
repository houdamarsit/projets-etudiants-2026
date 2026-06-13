import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { fournisseur, recycleur, admin }

class UserModel {
  final String id;
  final String email;
  final UserRole role;
  
  // Champs supplémentaires pour le profil
  final String name;
  final String phone;
  final String location;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name = '',
    this.phone = '',
    this.location = '',
  });

  /// Factory pour créer un UserModel depuis un DocumentSnapshot Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Gestion flexible du nom
    String userName = data['name'] ?? data['nom'] ?? '';

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      role: stringToRole(data['role']),
      name: userName,
      phone: data['phone'] ?? '',
      location: data['location'] ?? '',
    );
  }

  /// Convertit un String en UserRole
  static UserRole stringToRole(String? role) {
    switch (role) {
      case 'fournisseur':
        return UserRole.fournisseur;
      case 'recycleur':
        return UserRole.recycleur;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.recycleur; 
    }
  }

  /// Convertit le UserRole en String (pour la BDD)
  String roleToString() {
    switch (role) {
      case UserRole.fournisseur:
        return 'fournisseur';
      case UserRole.recycleur:
        return 'recycleur';
      case UserRole.admin:
        return 'admin';
    }
  }
  
  /// Méthode utilitaire pour obtenir les initiales 
  String get initials {
    if (name.isNotEmpty) return name[0].toUpperCase();
    if (email.isNotEmpty) return email[0].toUpperCase();
    return "U";
  }
}