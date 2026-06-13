import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valortrash/models/offer_model.dart';
import 'package:valortrash/viewmodels/offer_viewmodel.dart';

import 'package:valortrash/views/edit_offer_screen.dart';

class ProviderOffersHistoryScreen extends StatefulWidget {
  final String userEmail;
  final void Function(Widget) navigateTo;

  const ProviderOffersHistoryScreen({
    super.key,
    required this.userEmail,
    required this.navigateTo,
  });

  @override
  State<ProviderOffersHistoryScreen> createState() => _ProviderOffersHistoryScreenState();
}

class _ProviderOffersHistoryScreenState extends State<ProviderOffersHistoryScreen> {
  
  // --- LOGIQUE DE SUPPRESSION ---
  Future<void> _confirmAndDelete(BuildContext context, String offerId, String offerTitle) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: Text("Voulez-vous vraiment supprimer \"$offerTitle\" ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // Appel au ViewModel pour supprimer
        await context.read<OfferViewModel>().deleteOffer(offerId);
        
        if (mounted) {

          setState(() {});
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Offre supprimée avec succès")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur : $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offerVM = context.watch<OfferViewModel>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "Mes Offres Publiées",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
              ),
            ),

            // Liste des offres
            Expanded(

              child: FutureBuilder<List<OfferModel>>(
                future: offerVM.getUserOffers(widget.userEmail),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("Erreur de chargement: ${snapshot.error}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    ));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Vous n'avez publié aucune offre."));
                  }

                  var offers = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(
                            offer.materialType, 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF008B8B)),
                          ),
                          subtitle: Text(
                            "Quantité: ${offer.quantity} kg\nLieu: ${offer.location}\nType: ${offer.transactionType}"
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Navigation vers l'écran d'édition
                                  widget.navigateTo(
                                    EditOfferScreen(
                                      offerId: offer.id,
                                      initialData: offer.toJson(),
                                      onUpdated: () {

                                        setState(() {});
                                      },
                                    )
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmAndDelete(context, offer.id, offer.materialType);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}