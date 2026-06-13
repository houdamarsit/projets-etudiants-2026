import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:valortrash/viewmodels/request_viewmodel.dart';

class OfferDetailScreen extends StatelessWidget {
  final String offerId;
  final Map<String, dynamic> offerData;
  final String? userEmail;
  final String? userRole;

  const OfferDetailScreen({
    super.key,
    required this.offerId,
    required this.offerData,
    this.userEmail,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    // Extraction des données
    String type = offerData['materialType']?.toString() ?? 'Non spécifié';
    String quantity = offerData['quantity']?.toString() ?? '0';
    String location = offerData['location']?.toString() ?? 'Non spécifié';
    String transaction = offerData['transactionType']?.toString() ?? 'Non spécifié';
    String providerEmail = offerData['userEmail']?.toString() ?? 'Non spécifié';
    String price = offerData['price']?.toString() ?? '';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Détails : $type",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
              ),
              const SizedBox(height: 20),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.category, "Type de déchet", type),
                      const Divider(),
                      _buildInfoRow(Icons.scale, "Quantité", "$quantity kg"),
                      const Divider(),
                      _buildInfoRow(Icons.location_on, "Localisation", location),
                      const Divider(),
                      if (transaction == 'Vente' && price.isNotEmpty) ...[
                        _buildInfoRow(Icons.attach_money, "Prix", "$price TND", color: Colors.green),
                        const Divider(),
                      ],
                      _buildInfoRow(Icons.swap_horiz, "Type d'échange", transaction),
                      const Divider(),
                      _buildInfoRow(Icons.person, "Fournisseur", providerEmail),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),


              if (userRole != 'admin' && userEmail != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text("Envoyer une demande de recyclage"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008B8B),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),

                    onPressed: () async {
                      try {
                        await context.read<RequestViewModel>().sendRequest(
                          offerId: offerId,
                          offerType: type,
                          providerEmail: providerEmail,
                          recyclerEmail: userEmail!,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Demande envoyée avec succès !"), backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? const Color(0xFF008B8B)),
        const SizedBox(width: 15),
        Text("$label :", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Text(value, style: TextStyle(fontSize: 16, color: color ?? Colors.black))),
      ],
    );
  }
}