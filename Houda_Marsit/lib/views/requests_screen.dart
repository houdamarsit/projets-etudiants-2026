import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:valortrash/models/request_model.dart';
import 'package:valortrash/viewmodels/request_viewmodel.dart';

// ============================================================
// 1. PAGE GESTION DES DEMANDES (FOURNISSEUR)
// ============================================================

class ProviderRequestsScreen extends StatelessWidget {
  final String providerEmail;
  const ProviderRequestsScreen({super.key, required this.providerEmail});

  @override
  Widget build(BuildContext context) {
    final requestVM = context.watch<RequestViewModel>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "Demandes Reçues",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
              ),
            ),

            Expanded(

              child: FutureBuilder<List<RequestModel>>(
                future: requestVM.getProviderRequests(providerEmail), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                     return Center(child: Text("Erreur: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Aucune demande reçue."));
                  }

                  final requests = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text("Demande pour: ${request.offerType}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("De: ${request.recyclerEmail}\nStatut: ${_translateStatus(request.status)}"),
                          trailing: request.status == 'pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                      onPressed: () async {
                                        await context.read<RequestViewModel>().acceptRequest(request.id, request.offerId);
                                        

                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () async {
                                         await context.read<RequestViewModel>().rejectRequest(request.id);
                                      },
                                    ),
                                  ],
                                )
                              : Chip(
                                  label: Text(_translateStatus(request.status)),
                                  backgroundColor: request.status == 'accepted' ? Colors.green[100] : Colors.red[100],
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

  String _translateStatus(String status) {
    switch (status) {
      case 'pending': return 'En attente';
      case 'accepted': return 'Acceptée';
      case 'rejected': return 'Refusée';
      default: return status;
    }
  }
}

// ============================================================
// 2. PAGE MES DEMANDES (RECYCLEUR)
// ============================================================

class RecyclerRequestsScreen extends StatefulWidget {
  final String recyclerEmail;
  const RecyclerRequestsScreen({super.key, required this.recyclerEmail});

  @override
  State<RecyclerRequestsScreen> createState() => _RecyclerRequestsScreenState();
}

class _RecyclerRequestsScreenState extends State<RecyclerRequestsScreen> {

  Future<void> _confirmAndDelete(BuildContext context, String requestId, String offerTitle) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Annuler la demande"),
          content: Text("Voulez-vous vraiment supprimer votre demande pour \"$offerTitle\" ?"),
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
        await context.read<RequestViewModel>().deleteRequest(requestId);
        if (mounted) {
          setState(() {}); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Demande supprimée")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestVM = context.watch<RequestViewModel>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "Mes Demandes",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
              ),
            ),

            Expanded(

              child: FutureBuilder<List<RequestModel>>(
                future: requestVM.getRecyclerRequests(widget.recyclerEmail), // Utilisation de 'future'
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("Erreur de chargement: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                    ));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Vous n'avez envoyé aucune demande."));
                  }

                  final requests = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      
                      String statusText = request.status == 'pending' 
                          ? 'En attente' 
                          : (request.status == 'accepted' ? 'Acceptée' : 'Refusée');

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: Icon(
                            request.status == 'pending' 
                              ? Icons.hourglass_top 
                              : (request.status == 'accepted' ? Icons.check_circle : Icons.cancel),
                            color: request.status == 'pending' 
                              ? Colors.orange 
                              : (request.status == 'accepted' ? Colors.green : Colors.red),
                          ),
                          title: Text("Offre: ${request.offerType}"),
                          subtitle: Text("Fournisseur: ${request.providerEmail}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (request.status == 'accepted') 
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.email, size: 18),
                                  label: const Text("Contacter"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () {
                                    final Uri emailLaunchUri = Uri(
                                      scheme: 'mailto',
                                      path: request.providerEmail,
                                      queryParameters: {
                                        'subject': 'Réponse à votre demande - ValorTrash',
                                      },
                                    );
                                    launchUrl(emailLaunchUri);
                                  },
                                )
                              else
                                Text(
                                  statusText.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: request.status == 'pending' ? Colors.orange : Colors.red,
                                  ),
                                ),
                              
                              const SizedBox(width: 10),
                              
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmAndDelete(context, request.id, request.offerType);
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