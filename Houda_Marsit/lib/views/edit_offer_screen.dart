import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:valortrash/viewmodels/offer_viewmodel.dart';

class EditOfferScreen extends StatefulWidget {
  final String offerId;
  final Map<String, dynamic> initialData;
  final VoidCallback? onUpdated;

  const EditOfferScreen({
    super.key,
    required this.offerId,
    required this.initialData,
    this.onUpdated,
  });

  @override
  State<EditOfferScreen> createState() => _EditOfferScreenState();
}

class _EditOfferScreenState extends State<EditOfferScreen> {
  late TextEditingController _qtyController;
  late TextEditingController _locController;
  late TextEditingController _priceController;

  String? _selectedMat;
  String? _selectedTrans;
  String? _selectedStatus;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _qtyController = TextEditingController(text: widget.initialData['quantity']?.toString() ?? '');
    _locController = TextEditingController(text: widget.initialData['location']?.toString() ?? '');
    _priceController = TextEditingController(text: widget.initialData['price']?.toString() ?? '');

    _selectedMat = widget.initialData['materialType']?.toString();
    _selectedTrans = widget.initialData['transactionType']?.toString();

    // Normalisation du statut pour l'affichage
    String rawStatus = widget.initialData['status']?.toString() ?? 'Disponible';
    if (rawStatus == 'available') {
      _selectedStatus = "Disponible";
    } else if (rawStatus == 'unavailable' || rawStatus == 'taken') {
      _selectedStatus = "Non disponible";
    } else {
      _selectedStatus = rawStatus;
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _locController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_selectedMat == null || _selectedTrans == null || _selectedStatus == null ||
        _qtyController.text.isEmpty || _locController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez remplir tous les champs."), backgroundColor: Colors.red));
      return;
    }

    if (_selectedTrans == 'Vente' && _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez entrer un prix."), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> updatedData = {
        'materialType': _selectedMat,
        'quantity': _qtyController.text,
        'location': _locController.text,
        'transactionType': _selectedTrans,
        'price': _selectedTrans == 'Vente' ? _priceController.text : null,
        'status': _selectedStatus,
      };

      // Appel au ViewModel au lieu de Firestore
      await context.read<OfferViewModel>().updateOffer(widget.offerId, updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Offre modifiée avec succès !"), backgroundColor: Colors.green),
        );

        if (widget.onUpdated != null) {
          widget.onUpdated!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              const Text(
                "Modifier l'offre",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 20),

              // Statut
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ["Disponible", "Non disponible"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStatus = v),
                decoration: const InputDecoration(
                  labelText: "Statut de l'offre",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // Type de matériau
              DropdownButtonFormField<String>(
                value: _selectedMat,
                items: ["Plastique", "Carton", "Métaux", "Bois"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedMat = v),
                decoration: const InputDecoration(labelText: "Type de matériau", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              // Quantité
              TextField(
                controller: _qtyController,
                decoration: const InputDecoration(labelText: "Quantité (Kg)", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              // Localisation
              TextField(
                controller: _locController,
                decoration: const InputDecoration(labelText: "Lieu de collecte", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              // Type de transaction
              DropdownButtonFormField<String>(
                value: _selectedTrans,
                items: ["Vente", "Don"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTrans = v),
                decoration: const InputDecoration(labelText: "Type de transaction", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              // Prix (conditionnel)
              if (_selectedTrans == 'Vente')
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "Prix (TND)", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),

              const SizedBox(height: 30),

              // Bouton Sauvegarder
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.update),
                    label: const Text("Mettre à jour"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008B8B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _saveChanges,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}