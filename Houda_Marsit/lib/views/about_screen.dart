import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Détection de la taille de l'écran
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER AVEC FOND VERT
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipOval(child: Image.asset('assets/images/logo.jpg', fit: BoxFit.cover, errorBuilder: (c,o,s) => const Icon(Icons.recycling, size: 50, color: Color(0xFF2E7D32)))),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("VALORTRASH", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 5),
                  Text("Tous Recycleurs, Acteurs Solidaires de l'Humanité", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, letterSpacing: 1.2)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NOTRE HISTOIRE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Notre Histoire", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
                  const Divider(color: Color(0xFF2E7D32), thickness: 2, endIndent: 280),
                  const SizedBox(height: 10),
                  Text(
                    "ValorTrash est né d'une conviction simple : en Tunisie, nos déchets sont une richesse inexploitée. Face à l'urgence écologique, ValorTrash voit les déchets non plus comme un fardeau, mais comme une opportunité économique. Notre mission est de démocratiser le recyclage en Tunisie en créant le pont numérique manquant entre les citoyens et les structures de valorisation. Ensemble, transformons nos habitudes pour un avenir durable.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
                  ),
                  const SizedBox(height: 25),

                  // NOS OBJECTIFS 
                  const Text("Nos Objectifs", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
                  const Divider(color: Color(0xFF2E7D32), thickness: 2, endIndent: 280),
                  const SizedBox(height: 15),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isMobile ? 2 : 4, 
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9, 
                    children: [
                      _buildCompactObjectiveCard(Icons.public, "Impact Environnemental", Colors.green),
                      _buildCompactObjectiveCard(Icons.handshake, "Solidarité", Colors.blue),
                      _buildCompactObjectiveCard(Icons.monetization_on, "Économie Circulaire", Colors.orange),
                      _buildCompactObjectiveCard(Icons.school, "Sensibilisation", Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Center(child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget CARTE COMPACTE
  static Widget _buildCompactObjectiveCard(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)
          ),
        ],
      ),
    );
  }
}