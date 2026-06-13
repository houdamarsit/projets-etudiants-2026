import 'package:flutter/material.dart';

// ============================================================
// CHATBOT IA INTELLIGENT (VERSION 1.0)
// ============================================================

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // Base de connaissances du Bot 
  final Map<String, String> _knowledgeBase = {
    // Matériaux
    'carton': '📦 **Carton** : Dépliez les cartons et retirez les adhésifs. Ne jetez pas les cartons souillés (pizza) avec les propres.',
    'plastique': '🥤 **Plastique** : Vérifiez le code de tri (triangle). Rincez les bouteilles et écrasez-les pour gagner de la place.',
    'métal': '🛠️ **Métal** : Lavez les canettes et bocaux. Ils se recyclent à l\'infini !',
    'verre': '🍷 **Verre** : Déposez les bouteilles sans bouchon. Attention : la vaisselle et les miroirs ne vont pas dans le verre de tri.',
    'bois': '🪵 **Bois** : Séparez le bois traité du bois brut. Le bois humide ou pourri n\'est généralement pas recyclable.',
    
    // Fonctionnement de l'app
    'offre': 'Pour publier une offre, connectez-vous en tant que **Fournisseur**, puis remplissez le formulaire rapide sur votre tableau de bord.',
    'vendre': 'Vous pouvez vendre vos déchets en créant une offre de type "Vente". Le recycleur vous contactera pour convenir du prix.',
    'donner': 'Vous pouvez donner vos déchets en créant une offre de type "Don". C\'est un geste solidaire et écologique !',
    'inscription': 'Pour vous inscrire, cliquez sur "S\'inscrire" sur la page d\'accueil. Choisissez votre rôle : Fournisseur ou Recycleur.',
    'recycleur': 'Un recycleur peut chercher des offres, envoyer des demandes et contacter les fournisseurs.',
    'fournisseur': 'Un fournisseur peut déclarer des lots de déchets et recevoir des demandes de recyclage.',
    'bonjour': 'Bonjour ! 👋 Je suis l\'assistant ValorTrash. Comment puis-je vous aider ? Vous pouvez me poser des questions sur le tri (ex: "Carton") ou l\'utilisation de l\'application.',
    'salut': 'Salut ! 👋 Je suis là pour vous aider à valoriser vos déchets. Que voulez-vous savoir ?',
    'merci': 'Avec plaisir ! 🌱 N\'hésitez pas si vous avez d\'autres questions. Ensemble, valorisons nos déchets !',
    'aide': 'Je peux vous aider sur les sujets suivants :\n- Comment trier (Carton, Plastique, Verre...)\n- Comment publier une offre\n- Comment s\'inscrire\n\nTapez un mot-clé !',
    'contact': 'Vous pouvez contacter l\'équipe ValorTrash via la page "Contact" dans le menu.',
  };

  @override
  void initState() {
    super.initState();
    // Message de bienvenue
    _addBotMessage("Bonjour ! 👋 Je suis l'assistant virtuel ValorTrash.\n\nJe peux vous renseigner sur le **tri sélectif** ou vous aider à **utiliser l'application**.\n\nTapez votre question (ex: *Comment trier le plastique ?*)");
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: false));
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _controller.clear();
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _processInput(text);
      _scrollToBottom();
    });
  }

  void _processInput(String input) {
    String response = _findBestAnswer(input);
    _addBotMessage(response);
  }

  String _findBestAnswer(String input) {
    input = input.toLowerCase().trim();
    
    // Recherche de mots-clés dans la base de connaissances
    List<String> keys = _knowledgeBase.keys.toList();
    
    // Priorité aux mots-clés exacts ou contenus
    for (var key in keys) {
      if (input.contains(key)) {
        return _knowledgeBase[key]!;
      }
    }

    // Réponse par défaut 
    return "🤔 Je ne suis pas sûr de comprendre votre demande.\n\nVous pouvez me demander des informations sur :\n- Les matériaux (*Carton, Plastique, Verre...*)\n- L'application (*Offre, Inscription, Contact*)\n\nOu tapez **'Aide'** pour voir ce que je peux faire.";
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assistant IA"),
        backgroundColor: const Color(0xFF00695C),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          // Zone des messages
          Flexible(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              reverse: true, 
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _buildMessage(_messages[index]),
            ),
          ),
          const Divider(height: 1.0),
          // Zone de saisie
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  // Widget pour un message
  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: message.isUser
            ? _buildUserLayout(message)
            : _buildBotLayout(message),
      ),
    );
  }

  // Layout Bot
  List<Widget> _buildBotLayout(ChatMessage message) {
    return [
      // Avatar Bot
      Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.eco, color: Color(0xFF2E7D32)),
        ),
      ),
      // Bulle de message
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                message.text,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // Layout User 
  List<Widget> _buildUserLayout(ChatMessage message) {
    return [
      // Bulle de message
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                message.text,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      // Avatar User
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
    ];
  }

  // Zone de saisie de texte
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _controller,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: "Écrivez votre message...",
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF2E7D32)),
                onPressed: () => _handleSubmitted(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modèle de données pour un message
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}