import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valortrash/viewmodels/auth_viewmodel.dart';
import 'package:valortrash/views/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Contrôleurs pour les champs de texte
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthViewModel>().user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _locationController.text = user.location;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Sauvegarder les modifications
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        // Mise à jour dans Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.id).update({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
        });

        
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil mis à jour !"), backgroundColor: Colors.green),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Déconnexion
  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthViewModel>();
    final user = auth.user;


    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté")),
      );
    }


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Mon Compte", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3AA17E),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) _loadUserData(); 
              });
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar et Infos principales
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF3AA17E).withOpacity(0.2),
                    child: Text(
                      user.initials, 
                      style: const TextStyle(fontSize: 40, color: Color(0xFF3AA17E), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _nameController.text.isNotEmpty ? _nameController.text : "Utilisateur",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  
                  // Le Chip du Rôle
                  Chip(
                    label: Text(user.roleToString().toUpperCase()),
                    backgroundColor: user.roleToString() == 'fournisseur' 
                        ? Colors.orange.shade100 
                        : (user.roleToString() == 'admin' ? Colors.red.shade100 : Colors.green.shade100),
                    labelStyle: TextStyle(
                      color: user.roleToString() == 'fournisseur' 
                          ? Colors.orange.shade800 
                          : (user.roleToString() == 'admin' ? Colors.red.shade800 : Colors.green.shade800),
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Carte des informations
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        _buildEditableField("Nom complet", Icons.person_outline, _nameController),
                        const SizedBox(height: 20),
                        _buildEditableField("Email", Icons.email_outlined, _emailController),
                        const SizedBox(height: 20),
                        _buildEditableField("Téléphone", Icons.phone_outlined, _phoneController),
                        const SizedBox(height: 20),
                        _buildEditableField("Ville", Icons.location_on_outlined, _locationController),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bouton Sauvegarder
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3AA17E)),
                        child: const Text("Sauvegarder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Bouton Déconnexion
                  TextButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: _logout,
                    label: const Text("Se déconnecter", style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableField(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _isEditing ? const Color(0xFF3AA17E) : Colors.grey),
        filled: true,
        fillColor: _isEditing ? Colors.grey[50] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3AA17E), width: 1),
        ),
      ),
    );
  }
}