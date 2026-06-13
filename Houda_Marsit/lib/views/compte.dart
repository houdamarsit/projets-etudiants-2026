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
  // On récupère l'utilisateur via le ViewModel, pas besoin de variable locale
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
      // Les autres champs (phone, location) ne sont pas dans ton UserModel actuel,
      // on les laisse vides ou tu dois les ajouter au modèle.
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
        await FirebaseFirestore.instance.collection('users').doc(user.id).update({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
        });
        
        
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil mis à jour !"), backgroundColor: Colors.green),
      );
      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
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
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF3AA17E).withOpacity(0.2),
                    child: const Icon(Icons.person, size: 50, color: Color(0xFF3AA17E)),
                  ),
                  const SizedBox(height: 30),

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

                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3AA17E)),
                        child: const Text("Sauvegarder", style: TextStyle(color: Colors.white)),
                      ),
                    ),

                  const SizedBox(height: 30),

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