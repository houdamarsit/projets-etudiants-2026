import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:valortrash/models/offer_model.dart';
import 'package:valortrash/viewmodels/offer_viewmodel.dart';
import 'package:valortrash/viewmodels/request_viewmodel.dart';

import 'package:valortrash/views/offer_detail_screen.dart';

class SearchOffersScreen extends StatefulWidget {
  final String userEmail;
  final void Function(Widget) navigateTo;

  const SearchOffersScreen({
    super.key,
    required this.userEmail,
    required this.navigateTo,
  });

  @override
  State<SearchOffersScreen> createState() => _SearchOffersScreenState();
}

class _SearchOffersScreenState extends State<SearchOffersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Accès au ViewModel des Offres
    final offerVM = context.watch<OfferViewModel>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITRE
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "Rechercher des Offres",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
              ),
            ),

            // BARRE DE RECHERCHE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Rechercher (ex: Carton, Plastique...)",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          })
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  });
                },
              ),
            ),

            // LISTE DES OFFRES
            Expanded(

              child: FutureBuilder<List<OfferModel>>(
                future: offerVM.getAvailableOffers(), // 'future' au lieu de 'stream'
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Erreur: ${snapshot.error}"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Aucune offre disponible."));
                  }

                  // 2. Filtrage côté client
                  var allOffers = snapshot.data!;
                  var filteredOffers = allOffers.where((offer) {
                    bool matchesSearch = _searchQuery.isEmpty ||
                                        offer.materialType.toLowerCase().contains(_searchQuery);
                    return matchesSearch;
                  }).toList();

                  if (filteredOffers.isEmpty) {
                    return Center(
                        child: Text(_searchQuery.isEmpty
                            ? "Aucune offre disponible pour le moment."
                            : "Aucun résultat pour '$_searchQuery'"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filteredOffers.length,
                    itemBuilder: (context, index) {
                      final offer = filteredOffers[index];
                      return _buildOfferCard(offer);
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

  // --- CONSTRUCTION DE LA CARTE OFFRE ---
  Widget _buildOfferCard(OfferModel offer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_outline, color: Colors.green),
                  ),
                  const SizedBox(width: 10),
                  Text(offer.materialType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
                  child: Text("${offer.quantity} kg", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Expanded(child: Text(offer.location, style: const TextStyle(color: Colors.grey))),
            ]),
            const SizedBox(height: 12),
            
            // BOUTONS D'ACTION
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text("Détails"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                  onPressed: () {
                    widget.navigateTo(OfferDetailScreen(
                      offerId: offer.id,
                      offerData: offer.toJson(),
                      userEmail: widget.userEmail,
                      userRole: 'recycleur',
                    ));
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text("Envoyer demande"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008B8B), foregroundColor: Colors.white),
                  onPressed: () => _sendRecyclingRequest(offer),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIQUE D'ENVOI DE DEMANDE ---
  void _sendRecyclingRequest(OfferModel offer) async {
    final requestVM = context.read<RequestViewModel>();

    try {
      await requestVM.sendRequest(
        offerId: offer.id,
        offerType: offer.materialType,
        providerEmail: offer.userEmail,
        recyclerEmail: widget.userEmail,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Demande envoyée avec succès !"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
      );
    }
  }
}