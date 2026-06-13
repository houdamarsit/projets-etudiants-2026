import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:valortrash/viewmodels/offer_viewmodel.dart';

class AddOfferScreen extends StatefulWidget {
  final String userEmail;
  final VoidCallback? onFinish; 

  const AddOfferScreen({super.key, required this.userEmail, this.onFinish});

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  // Variables d'état
  String? _mat, _trans;
  final _qty = TextEditingController();
  final _loc = TextEditingController();
  final _price = TextEditingController();

  void _submit() async {
    // 1. Validation simple
    if (_mat == null || _trans == null || _qty.text.isEmpty || _loc.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_trans == 'Vente' && _price.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un prix pour la vente."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Appel au ViewModel
    try {
      await context.read<OfferViewModel>().addOffer(
        userEmail: widget.userEmail,
        materialType: _mat!,
        quantity: _qty.text,
        location: _loc.text,
        transactionType: _trans!,
        price: _trans == 'Vente' ? _price.text : null,
      );

      if (!mounted) return;

      // 3. Succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Votre offre a été publiée avec succès !"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // 4. Nettoyage et fermeture
      _qty.clear();
      _loc.clear();
      _price.clear();
      setState(() {
        _mat = null;
        _trans = null;
      });

      if (widget.onFinish != null) {
        widget.onFinish!();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la publication: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              const Text(
                "Nouvelle Offre",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 20),

              // Type de matériau
              DropdownButtonFormField<String>(
                value: _mat,
                items: ["Plastique", "Carton", "Métaux", "Bois"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _mat = v),
                decoration: const InputDecoration(labelText: "Type de matériau", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              TextField(
                  controller: _qty,
                  decoration: const InputDecoration(labelText: "Quantité (Kg)", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 15),

              TextField(
                  controller: _loc,
                  decoration: const InputDecoration(labelText: "Lieu de collecte", border: OutlineInputBorder())),
              const SizedBox(height: 15),

              // Type de transaction
              DropdownButtonFormField<String>(
                value: _trans,
                items: ["Vente", "Don"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _trans = v),
                decoration: const InputDecoration(labelText: "Type de transaction", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              // Affichage conditionnel du prix
              if (_trans == 'Vente')
                TextField(
                    controller: _price,
                    decoration: const InputDecoration(labelText: "Prix (TND)", border: OutlineInputBorder()),
                    keyboardType: TextInputType.number),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color(0xFF2E7D32), // Ta couleur darkGreen
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Publier l'offre", style: TextStyle(fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}