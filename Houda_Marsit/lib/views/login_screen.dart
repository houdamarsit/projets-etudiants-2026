import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:valortrash/viewmodels/auth_viewmodel.dart';
import 'package:valortrash/views/home_page.dart';
import 'package:valortrash/views/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _handleLogin() async {
    setState(() => _errorMessage = null);

    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Champs vides");
      return;
    }

    // Appel au ViewModel au lieu du Service direct
    final authViewModel = context.read<AuthViewModel>();
    bool success = await authViewModel.login(email, password);

    if (!mounted) return;

    if (success) {
      // Navigation
      if (kIsWeb && Navigator.canPop(context)) {
        Navigator.pop(context); // Ferme le dialogue Web
      } else {
        // Mobile 
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } else {
      // Récupère l'erreur depuis le ViewModel
      setState(() => _errorMessage = authViewModel.errorMessage ?? "Identifiants incorrects");
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
      appBar: AppBar(title: const Text("Connexion"), backgroundColor: const Color(0xFF008B8B), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null) Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            TextField(controller: _emailController, decoration: InputDecoration(hintText: "Email", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 15),
            TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(hintText: "Mot de passe", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(onPressed: _handleLogin, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008B8B)), child: const Text("Se connecter"))
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
              child: const Text("S'inscrire")
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  const Text("Connexion", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.white))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20), const SizedBox(width: 10),
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                      ]),
                    ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: "Email", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), prefixIcon: const Icon(Icons.email_outlined)),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController, obscureText: true,
                    decoration: InputDecoration(hintText: "Mot de passe", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), prefixIcon: const Icon(Icons.lock_outline)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, height: 45,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008B8B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text("Se connecter", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Ouvre le dialogue d'inscription
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Fermer",
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, anim1, anim2) {
                          return Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 450,
                              child: const SignupScreen(), // Doit être adapté aussi pour le web
                            ),
                          );
                        },
                        transitionBuilder: (context, anim1, anim2, child) {
                          return FadeTransition(
                            opacity: anim1,
                            child: ScaleTransition(
                              scale: anim1.drive(Tween<double>(begin: 0.8, end: 1.0).chain(CurveTween(curve: Curves.easeOut))),
                              child: child,
                            ),
                          );
                        },
                      );
                    },
                    child: const Text("Pas de compte ? S'inscrire")
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}