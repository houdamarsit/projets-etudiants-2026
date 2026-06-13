class RequestModel {
  final String id;
  final String offerId;
  final String offerType;
  final String providerEmail;
  final String recyclerEmail;
  final String status;

  RequestModel({
    required this.id,
    required this.offerId,
    required this.offerType,
    required this.providerEmail,
    required this.recyclerEmail,
    required this.status,
  });

  factory RequestModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RequestModel(
      id: id,
      offerId: data['offerId'] ?? '',
      offerType: data['offerType'] ?? 'Inconnu',
      providerEmail: data['providerEmail'] ?? '',
      recyclerEmail: data['recyclerEmail'] ?? '',
      status: data['status'] ?? 'pending',
    );
  }
}