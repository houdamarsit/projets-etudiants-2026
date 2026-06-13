import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Détection de la taille de l'écran
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            const Text("Notre Impact", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
            Text("Ensemble pour un avenir vert", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 20),
            
            // Grille de Statistiques Compacte
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              
              
              crossAxisCount: isMobile ? 2 : 4, 
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              childAspectRatio: 0.9, 
              children: [
                _buildCompactStatCard("12,345", "Déchets\nValorisés", Icons.recycling, Colors.green),
                _buildCompactStatCard("56,789", "Utilisateurs\nActifs", Icons.group, Colors.blue),
                _buildCompactStatCard("8,901", "Tonnes CO2\nÉconomisées", Icons.co2, Colors.orange),
                _buildCompactStatCard("99%", "Taux de\nSatisfaction", Icons.thumb_up, Colors.purple),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Petite note en bas 
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        "Chaque action compte. Merci de faire partie du changement.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour une carte de stat COMPACTE
  Widget _buildCompactStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Icon(icon, color: color, size: 28), 
          const SizedBox(height: 10),
          FittedBox( 
            child: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color))
          ),
          const SizedBox(height: 6),
          Text(
            label, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500, height: 1.2)
          ),
        ],
      ),
    );
  }
}