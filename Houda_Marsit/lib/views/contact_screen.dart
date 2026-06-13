import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  // --- LOGIQUE UTILISATEUR  ---
  
  void _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  void _makeCall(String phoneNumber) async {
    final Uri telLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(telLaunchUri)) {
      await launchUrl(telLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {

    String adminEmail = "contact@valortrash.tn";
    String adminPhone = "+216 20 123 456";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF2E7D32).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.headset_mic_outlined, size: 40, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 15),
                  const Text("Contactez-nous", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                  const SizedBox(height: 5),
                  Text("Nous sommes là pour vous aider", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Cartes de Contact
            _buildContactCard(
              icon: Icons.email_outlined,
              title: "Email",
              subtitle: "Écrivez-nous directement",
              value: adminEmail,
              color: Colors.red,
              onTap: () => _launchEmail(adminEmail),
            ),
            const SizedBox(height: 15),
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: "Téléphone",
              subtitle: "Appelez-nous",
              value: adminPhone,
              color: Colors.green,
              onTap: () => _makeCall(adminPhone),
            ),
            const SizedBox(height: 30),

            // Formulaire Rapide
            const Text("Envoyer un message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Votre nom", 
                        prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400]), 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), 
                        filled: true, 
                        fillColor: Colors.grey[100]
                      )
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Votre message", 
                        prefixIcon: Icon(Icons.message_outlined, color: Colors.grey[400]), 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), 
                        filled: true, 
                        fillColor: Colors.grey[100]
                      ), 
                      maxLines: 3
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text("Envoyer", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32), 
                          padding: const EdgeInsets.symmetric(vertical: 14), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        onPressed: () {
                       
                       
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fonctionnalité à implémenter")),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  
  Widget _buildContactCard({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required String value, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(color: Colors.grey[600])),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ),
    );
  }
}