import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:valortrash/viewmodels/auth_viewmodel.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  String? _errorMessage;

  void _handleSignup() async {
    setState(() => _errorMessage = null);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _selectedRole == null) {
      setState(() => _errorMessage = "Veuillez remplir tous les champs.");
      return;
    }

    // Appel au ViewModel
    final authViewModel = context.read<AuthViewModel>();
    bool success = await authViewModel.register(
      _emailController.text, 
      _passwordController.text, 
      _selectedRole!
    );

    if (!mounted) return;

    if (success) {
      
      Navigator.pop(context);
      
      
      
    } else {
      // Récupère l'erreur du ViewModel
      setState(() => _errorMessage = authViewModel.errorMessage ?? "Erreur : Email peut-être déjà utilisé.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebContent();
    } else {
      return _buildMobileContent();
    }
  }

  // --- Version Mobile ---
  Widget _buildMobileContent() {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription"), backgroundColor: const Color(0xFF008B8B)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
            const SizedBox(height: 15),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe", prefixIcon: Icon(Icons.lock))),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: "Rôle",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              items: const [
                DropdownMenuItem(value: 'fournisseur', child: Text("Fournisseur")),
                DropdownMenuItem(value: 'recycleur', child: Text("Recycleur"))
              ],
              onChanged: (val) => setState(() => _selectedRole = val),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008B8B),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("S'inscrire", style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  // --- Version Web ---
  Widget _buildWebContent() {

    return Material( 
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre de titre
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: const BoxDecoration(
                color: Color(0xFF008B8B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Créer un compte", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white),
                  )
                ],
              ),
            ),
            
            // Corps du formulaire
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),

                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Mot de passe",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    hint: const Text("Sélectionner un rôle"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.people_outline),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'fournisseur', child: Text("Fournisseur")),
                      DropdownMenuItem(value: 'recycleur', child: Text("Recycleur"))
                    ],
                    onChanged: (val) => setState(() => _selectedRole = val),
                  ),
                  const SizedBox(height: 25),
                  
                  // Bouton d'inscription
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008B8B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("S'inscrire", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}