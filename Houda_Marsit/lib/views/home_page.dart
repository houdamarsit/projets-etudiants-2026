import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:valortrash/models/offer_model.dart';
import 'package:valortrash/models/request_model.dart';
import 'package:valortrash/viewmodels/auth_viewmodel.dart';
import 'package:valortrash/viewmodels/offer_viewmodel.dart';
import 'package:valortrash/viewmodels/request_viewmodel.dart';
import 'package:valortrash/services/firebase_service.dart';

import 'package:valortrash/views/login_screen.dart';
import 'package:valortrash/views/signup_screen.dart';
import 'package:valortrash/views/about_screen.dart';
import 'package:valortrash/views/chat_bot_screen.dart';
import 'package:valortrash/views/articles_screen.dart';
import 'package:valortrash/views/stats_screen.dart';
import 'package:valortrash/views/contact_screen.dart';
import 'package:valortrash/views/account_screen.dart';
import 'package:valortrash/views/edit_offer_screen.dart';
import 'package:valortrash/views/offer_detail_screen.dart'; 

// ============================================================
// PAGE PRINCIPALE
// ============================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- VARIABLES UI ---
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color lightGreen = const Color(0xFF66BB6A);
  bool get _isMobile => MediaQuery.of(context).size.width < 600;

  // Navigation Interne
  final List<Widget> _navigationHistory = [];
  Widget? _currentBodyContent;

  // --- VARIABLES DE STOCKAGE DES DONNÉES ---
  Future<List<OfferModel>>? _availableOffersFuture;
  Future<List<RequestModel>>? _recyclerRequestsFuture;
  Future<List<OfferModel>>? _userOffersFuture;
  Future<List<RequestModel>>? _providerRequestsFuture;
  Stream<QuerySnapshot>? _usersStream; 

  // Contrôleurs formulaire Fournisseur
  final _formQtyController = TextEditingController();
  final _formLocController = TextEditingController();
  final _formPriceController = TextEditingController();
  String? _selectedMaterial;
  String? _selectedTransaction;

  // Recherche Recycleur
  String _recyclerSearchQuery = "";

  // Données statiques
  final List<Map<String, dynamic>> _items = [
    {"title": "Carton & Papier", "img": "assets/images/carton.jpg"},
    {"title": "Métal", "img": "assets/images/metal.jpg"},
    {"title": "Plastique", "img": "assets/images/plastique.jpg"},
    {"title": "Bois", "img": "assets/images/bois.jpg"},
    {"title": "Verre", "img": "assets/images/verre.jpg"},
  ];

  final Map<String, Map<String, dynamic>> _materialTips = {
    "Carton & Papier": {"icon": Icons.description, "color": Colors.brown, "tips": ["Dépliez les cartons.", "Retirez les adhésifs."], "impact": "Recycler 1 tonne de papier économise 17 arbres."},
    "Métal": {"icon": Icons.build, "color": Colors.blueGrey, "tips": ["Lavez les canettes.", "Compressez-les."], "impact": "L'acier se recycle à l'infini."},
    "Plastique": {"icon": Icons.local_drink, "color": Colors.blue, "tips": ["Vérifiez le code de tri.", "Rincez les bouteilles."], "impact": "Réduit la dépendance au pétrole."},
    "Bois": {"icon": Icons.forest, "color": Colors.green, "tips": ["Séparez le bois traité du brut."], "impact": "Devient des panneaux de particules."},
    "Verre": {"icon": Icons.wine_bar, "color": Colors.teal, "tips": ["Déposez sans bouchon.", "Pas de vaisselle."], "impact": "Économise l'énergie d'un lave-vaisselle."},
  };
  
  final Map<String, String> _articleImagesMap = {
    "Guide de recyclage": "assets/images/guide.jpg",
    "L'importance de recyclage": "assets/images/importance.jpg",
  };
  final String _defaultArticleImage = "assets/images/default_article.jpg";

  // Timer
  late Timer _factTimer;
  int _currentFactIndex = 0;
  final List<String> _recyclingFacts = [
    "Recycler une canette économise l'énergie pour 3h de TV.",
    "Le verre se recycle à l'infini.",
    "1 personne = 1kg de déchets/jour en moyenne.",
    "Recycler 1 tonne de plastique économise 800kg de pétrole.",
    "Le papier se recycle jusqu'à 5 fois.",
  ];

  // --- LOGIQUE ---

  @override
  void initState() {
    super.initState();
    _startFactTimer();
  }

  @override
  void dispose() {
    _factTimer.cancel();
    _formQtyController.dispose();
    _formLocController.dispose();
    _formPriceController.dispose();
    super.dispose();
  }

  // --- GESTION DU CHARGEMENT DES DONNÉES ---
  
  void _loadDashboardData(String email, String? role) {
    final offerVM = context.read<OfferViewModel>();
    final requestVM = context.read<RequestViewModel>();

    if (role == 'recycleur') {
      if (_availableOffersFuture == null) _availableOffersFuture = offerVM.getAvailableOffers();
      if (_recyclerRequestsFuture == null) _recyclerRequestsFuture = requestVM.getRecyclerRequests(email);
    } else if (role == 'fournisseur') {
      if (_userOffersFuture == null) _userOffersFuture = offerVM.getUserOffers(email);
      if (_providerRequestsFuture == null) _providerRequestsFuture = requestVM.getProviderRequests(email);
    } else if (role == 'admin') {
       if (_usersStream == null) _usersStream = offerVM.getUsersStream();
       if (_availableOffersFuture == null) _availableOffersFuture = offerVM.getAvailableOffers();
    }
  }

  void _refreshProviderData(String email) {
    final offerVM = context.read<OfferViewModel>();
    final requestVM = context.read<RequestViewModel>();
    setState(() {
      _userOffersFuture = offerVM.getUserOffers(email);
      _providerRequestsFuture = requestVM.getProviderRequests(email);
    });
  }

  void _refreshRecyclerData(String email) {
    final offerVM = context.read<OfferViewModel>();
    final requestVM = context.read<RequestViewModel>();
    setState(() {
      _availableOffersFuture = offerVM.getAvailableOffers();
      _recyclerRequestsFuture = requestVM.getRecyclerRequests(email);
    });
  }

  void _startFactTimer() {
    _factTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentFactIndex = (_currentFactIndex + 1) % _recyclingFacts.length;
        });
      }
    });
  }

  void _navigateToSection(Widget newContent) {
    setState(() {
      if (_currentBodyContent != null) _navigationHistory.add(_currentBodyContent!);
      _currentBodyContent = newContent;
    });
  }

  void _goBack() {
    if (_navigationHistory.isNotEmpty) {
      setState(() => _currentBodyContent = _navigationHistory.removeLast());
    }
  }

  void _goHome() {
    setState(() {
      _navigationHistory.clear();
      _currentBodyContent = null;
    });
  }

  void _showMaterialDetails(String title) {
    var data = _materialTips[title] ?? {"icon": Icons.help_outline, "color": Colors.grey, "tips": ["Infos indisponibles."], "impact": "Contactez l'admin."};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(data['icon'], color: data['color'], size: 30), const SizedBox(width: 15), Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 20),
              const Text("Conseils", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
              const SizedBox(height: 10),
              ...data['tips'].map<Widget>((tip) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Row(children: [const Icon(Icons.check_circle_outline, size: 18, color: Colors.green), const SizedBox(width: 10), Expanded(child: Text(tip))]))).toList(),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(Icons.eco, color: Colors.green.shade700), const SizedBox(width: 10), Expanded(child: Text(data['impact'], style: TextStyle(fontSize: 13, color: Colors.green.shade800)))])),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(icon: const Icon(Icons.search), label: const Text("Voir les offres"), style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white), onPressed: () => Navigator.pop(context))),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final bool isLoggedIn = auth.isLoggedIn;
    final String? role = auth.user?.roleToString();
    final String? email = auth.user?.email;

    if (isLoggedIn && email != null && role != null) {
      _loadDashboardData(email, role);
    }

    final bodyContent = _currentBodyContent ?? (isLoggedIn ? _buildUserDashboard(role, email) : _buildPublicHomeContent());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      drawer: _navigationHistory.isEmpty && _currentBodyContent == null ? _buildAppDrawer() : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatBotScreen())),
        backgroundColor: darkGreen,
        icon: const Icon(Icons.smart_toy, color: Colors.white),
        label: const Text("Assistant IA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildTopNavBar(context, isLoggedIn, email, role),
          Expanded(child: bodyContent),
        ],
      ),
    );
  }

  // ============================================================
  // 1. INTERFACE PUBLIQUE
  // ============================================================
  
  Widget _buildPublicHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWaveHeader(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Marketplace Numérique", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 15),
                if (_isMobile) Column(children: [SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _items.map((item) => _buildHorizontalCard(item)).toList())), const SizedBox(height: 20), _buildDidYouKnowWidget()])
                else Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _items.map((item) => _buildHorizontalCard(item)).toList()))), const SizedBox(width: 20), Expanded(flex: 1, child: _buildDidYouKnowWidget())]),
                const SizedBox(height: 35),
                if (_isMobile) Column(children: [_buildArticlesSection(), const SizedBox(height: 20), _buildHowItWorks()])
                else Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: _buildArticlesSection()), const SizedBox(width: 20), Expanded(flex: 1, child: _buildHowItWorks())]),
                const SizedBox(height: 30),
                _buildStatsSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS UI PUBLICS ---
  
  Widget _buildWaveHeader() { return ClipPath(clipper: _WaveClipper(), child: Container(width: double.infinity, decoration: BoxDecoration(gradient: LinearGradient(colors: [darkGreen, lightGreen])), padding: EdgeInsets.fromLTRB(20, _isMobile ? 20 : 50, 20, _isMobile ? 60 : 80), constraints: BoxConstraints(minHeight: _isMobile ? 200 : 320), child: _isMobile ? _buildMobileHeaderLayout() : _buildWebHeaderLayout())); }
  Widget _buildMobileHeaderLayout() { return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.asset('assets/images/logo.jpg', fit: BoxFit.cover, errorBuilder: (c, o, s) => Icon(Icons.recycling, size: 40, color: darkGreen)))), const SizedBox(height: 10), const Text("VALORTRASH", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Text("La 1ère plateforme tunisienne qui transforme vos déchets en ressources.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11))]); }
  Widget _buildWebHeaderLayout() { return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.asset('assets/images/logo.jpg', fit: BoxFit.cover, errorBuilder: (c, o, s) => Icon(Icons.recycling, size: 50, color: darkGreen)))), const SizedBox(width: 15), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("VALORTRASH", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text("ValorTrash révolutionne la gestion des déchets en Tunisie. Connectez directement les détenteurs aux recycleurs.")])), const SizedBox(width: 15), Container(width: 380, height: 210, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Image.asset('assets/images/im.jpg', fit: BoxFit.cover, errorBuilder: (c, o, s) => Container(color: Colors.grey[300])))]); }
  Widget _buildTopNavBar(BuildContext context, bool isLoggedIn, String? email, String? role) { bool canGoBack = _navigationHistory.isNotEmpty; return Container(color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), child: Row(children: [if (canGoBack) IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: _goBack) else if (_isMobile) IconButton(icon: const Icon(Icons.menu, color: Colors.black87), onPressed: () => Scaffold.of(context).openDrawer()) else ...[Icon(Icons.recycling, color: darkGreen, size: 28), const SizedBox(width: 8), Text("VALORTRASH", style: TextStyle(color: darkGreen, fontWeight: FontWeight.w900, fontSize: 18))], if (canGoBack && _isMobile) Text("Retour", style: TextStyle(color: darkGreen, fontWeight: FontWeight.w800, fontSize: 18)), const Spacer(), if (!_isMobile) ...[_buildNavItem("Accueil"), _buildNavItem("Articles"), _buildNavItem("Statistiques"), _buildNavItem("Contact"), _buildNavItem("À propos"), const SizedBox(width: 20)], if (!isLoggedIn) ...[if (!_isMobile) ...[_buildTextButton("Se connecter", Colors.grey[700]!, false, isLoggedIn), const SizedBox(width: 10), _buildTextButton("S'inscrire", darkGreen, true, isLoggedIn)]] else Row(mainAxisSize: MainAxisSize.min, children: [_buildTextButton("Mon compte", Colors.grey[700]!, false, isLoggedIn), const SizedBox(width: 10), _buildTextButton("Déconnexion", Colors.red, false, isLoggedIn)])])); }
  Widget _buildNavItem(String title) { return InkWell(onTap: () { if (title == "Accueil") _goHome(); else if (title == "Articles") _navigateToSection(const ArticlesScreen()); else if (title == "Statistiques") _navigateToSection(const StatsScreen()); else if (title == "Contact") _navigateToSection(const ContactScreen()); else if (title == "À propos") _navigateToSection(const AboutScreen()); }, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10), child: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)))); }
  Widget _buildTextButton(String title, Color color, bool filled, bool isLoggedIn) { return InkWell(onTap: () { if (title == "Déconnexion") { context.read<AuthViewModel>().logout(); } else if (title == "Mon compte") { Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountScreen())); } else if (kIsWeb) { if (title == "S'inscrire") _showWebDialog(context, const SignupScreen()); else _showWebDialog(context, const LoginScreen()); } else { if (title == "S'inscrire") Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())); else Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); } }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: filled ? color : Colors.transparent, border: Border.all(color: filled ? color : Colors.grey.shade400), borderRadius: BorderRadius.circular(20)), child: Text(title, style: TextStyle(color: filled ? Colors.white : color, fontWeight: FontWeight.w600, fontSize: 13)))); }
  void _showWebDialog(BuildContext context, Widget screen) { showGeneralDialog(context: context, barrierDismissible: true, barrierLabel: "Fermer", barrierColor: Colors.black.withOpacity(0.5), transitionDuration: const Duration(milliseconds: 300), pageBuilder: (context, anim1, anim2) { return Align(alignment: Alignment.center, child: Container(width: 450, constraints: const BoxConstraints(maxHeight: 600), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: screen))); }, transitionBuilder: (context, anim1, anim2, child) { return FadeTransition(opacity: anim1, child: ScaleTransition(scale: anim1.drive(Tween<double>(begin: 0.8, end: 1.0).chain(CurveTween(curve: Curves.easeOut))), child: child)); }); }
  Widget _buildAppDrawer() { return Drawer(child: ListView(padding: EdgeInsets.zero, children: [DrawerHeader(decoration: BoxDecoration(color: darkGreen), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [const Icon(Icons.recycling, color: Colors.white, size: 40), const SizedBox(height: 10), const Text("VALORTRASH", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), Text("Valorisez vos déchets", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14))])), _buildDrawerItem(icon: Icons.home, title: "Accueil", onTap: () { Navigator.pop(context); _goHome(); }), _buildDrawerItem(icon: Icons.article, title: "Articles", onTap: () { Navigator.pop(context); _navigateToSection(const ArticlesScreen()); }), _buildDrawerItem(icon: Icons.info, title: "À propos", onTap: () { Navigator.pop(context); _navigateToSection(const AboutScreen()); }), const Divider(), if (context.watch<AuthViewModel>().isLoggedIn) _buildDrawerItem(icon: Icons.logout, title: "Déconnexion", color: Colors.red, onTap: () { Navigator.pop(context); context.read<AuthViewModel>().logout(); }) else ...[_buildDrawerItem(icon: Icons.login, title: "Se connecter", onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }), _buildDrawerItem(icon: Icons.person_add, title: "S'inscrire", onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())); })]])); }
  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap, Color? color}) { return InkWell(onTap: onTap, child: SizedBox(height: 50, width: double.infinity, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Row(children: [Icon(icon, color: color ?? darkGreen), const SizedBox(width: 15), Text(title, style: TextStyle(fontSize: 16, color: color ?? Colors.black87, fontWeight: FontWeight.w500))])))); }
  

  Widget _buildHorizontalCard(Map<String, dynamic> item) {
    return Container(
      width: 160, margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.asset(item['img'], height: 100, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 100, color: Colors.grey[200]))),
          Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)), const SizedBox(height: 6), SizedBox(width: double.infinity, height: 24, child: ElevatedButton(onPressed: () => _showMaterialDetails(item['title']), style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 112, 133, 112), padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))), child: const Text("En savoir plus", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600))))])),
        ],
      ),
    );
  }

  Widget _buildStatsSection() { return Row(children: [_buildStatCard("12,345", "Déchets\nValorisés", Icons.recycling), const SizedBox(width: 10), _buildStatCard("56,789", "Utilisateurs\nActifs", Icons.group), const SizedBox(width: 10), _buildStatCard("8,901", "Impact\nCO2", Icons.co2)]); }
  Widget _buildStatCard(String value, String label, IconData icon) { return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(children: [Icon(icon, color: darkGreen, size: 22), const SizedBox(height: 5), Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: darkGreen)), const SizedBox(height: 2), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Colors.grey, height: 1.2))]))); }
  Widget _buildDidYouKnowWidget() { return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: darkGreen, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lightbulb_outline, color: darkGreen, size: 30), const SizedBox(height: 10), const Text("Le Saviez-vous ?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))), const SizedBox(height: 10), AnimatedSwitcher(duration: const Duration(milliseconds: 500), child: Text(_recyclingFacts[_currentFactIndex], key: ValueKey<String>(_recyclingFacts[_currentFactIndex]), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)))])); }
  Widget _buildHowItWorks() { List<Map<String, dynamic>> steps = [{"icon": Icons.person_add, "title": "S'inscrire", "desc": "Créez un compte"}, {"icon": Icons.swap_horiz, "title": "Échanger", "desc": "Publiez ou cherchez"}, {"icon": Icons.eco, "title": "Agir", "desc": "Économie verte"}]; return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Comment ça marche ?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: darkGreen)), const SizedBox(height: 15), Column(children: steps.asMap().entries.map((entry) { int idx = entry.key; Map<String, dynamic> step = entry.value; return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Column(children: [CircleAvatar(radius: 12, backgroundColor: darkGreen, child: Text("${idx + 1}", style: TextStyle(color: Colors.white, fontSize: 12))), if (idx < steps.length - 1) Container(height: 30, width: 2, color: Colors.grey.shade300)]), const SizedBox(width: 15), Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 15.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(step['icon'], size: 18, color: darkGreen), const SizedBox(width: 8), Text(step['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]), const SizedBox(height: 4), Text(step['desc'], style: TextStyle(fontSize: 11, color: Colors.grey[600]))])))]); }).toList())])); }
  Widget _buildArticlesSection() { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Actualités & Guides", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black)), const SizedBox(height: 15), SizedBox(height: 220, child: StreamBuilder<QuerySnapshot>(stream: FirebaseService().getArticles(), builder: (context, snapshot) { if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}")); if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator()); if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Aucun article")); var articles = snapshot.data!.docs; return ListView.builder(scrollDirection: Axis.horizontal, itemCount: articles.length, itemBuilder: (context, index) { var articleData = articles[index].data() as Map<String, dynamic>; return _buildArticleCardHome(articleData); }); }))]); }
  

  Widget _buildArticleCardHome(Map<String, dynamic> article) {
    String title = article['title'] ?? '';
    String imagePath = _articleImagesMap[title] ?? _defaultArticleImage;
    return Container(
      width: 220, margin: const EdgeInsets.only(right: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.asset(imagePath, height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 120, color: Colors.grey[200]))),
          Padding(padding: const EdgeInsets.all(10.0), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  // ============================================================
  // 2. DASHBOARDS UTILISATEURS
  // ============================================================

  Widget _buildUserDashboard(String? role, String? email) {
    if (role == 'fournisseur') return _buildProviderDashboard(email);
    if (role == 'recycleur') return _buildRecyclerDashboard(email);
    if (role == 'admin') return _buildAdminDashboard();
    return const Center(child: Text("Rôle inconnu"));
  }

  // --- DASHBOARD FOURNISSEUR ---
  Widget _buildProviderDashboard(String? email) {
    if (email == null) return const Center(child: Text("Erreur email"));
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDashboardWaveHeader("Espace Fournisseur", email),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Lots en attente"),
                          const SizedBox(height: 10),
                          _buildPendingLotsList(email),
                          const SizedBox(height: 30),
                          _buildSectionHeader("Demandes Reçues"),
                          const SizedBox(height: 10),
                          _buildProviderRequestsList(email),
                          const SizedBox(height: 30),
                          _buildQuickDeclarationFormComplete(email),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader("Lots en attente"),
                              const SizedBox(height: 10),
                              _buildPendingLotsList(email),
                            ],
                          )),
                          const SizedBox(width: 20),
                          Expanded(flex: 3, child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader("Demandes Reçues"),
                              const SizedBox(height: 10),
                              _buildProviderRequestsList(email),
                            ],
                          )),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: _buildQuickDeclarationFormComplete(email)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingLotsList(String email) {
    return FutureBuilder<List<OfferModel>>(
      future: _userOffersFuture, // VARIABLE STOCKÉE
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();
        return Column(children: snapshot.data!.map((offer) => _buildLotCard(offer)).toList());
      },
    );
  }

  Widget _buildLotCard(OfferModel offer) {
    Color typeColor = Colors.green;
    if (offer.materialType.contains('Plastique')) typeColor = Colors.blue;
    if (offer.materialType.contains('Métal')) typeColor = Colors.orange;
    return Card(
      elevation: 2, margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(width: 8, height: 40, decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Lot #V - ${offer.id.substring(0, 4).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(offer.materialType, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ]),
                ]),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)), child: Text("${offer.quantity} kg", style: const TextStyle(fontWeight: FontWeight.bold)))
              ],
            ),
            const Divider(height: 20),
            Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey), const SizedBox(width: 5), Expanded(child: Text(offer.location, style: const TextStyle(color: Colors.grey, fontSize: 12)))]),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  label: const Text("Modifier", style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    _navigateToSection(EditOfferScreen(
                      offerId: offer.id,
                      initialData: offer.toJson(),
                      onUpdated: () {
                        _goBack();
                        _refreshProviderData(offer.userEmail); // Rafraîchissement manuel
                      },
                    ));
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    bool? confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text("Confirmation"), content: const Text("Supprimer ?"), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Non")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Oui", style: TextStyle(color: Colors.red)))]));
                    if (confirm == true) {
                      await context.read<OfferViewModel>().deleteOffer(offer.id);
                      _refreshProviderData(offer.userEmail);
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProviderRequestsList(String email) {
    return FutureBuilder<List<RequestModel>>(
      future: _providerRequestsFuture, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)), child: const Center(child: Text("Aucune demande reçue.")));
        var requests = snapshot.data!;
        return Column(
          children: requests.map((req) {
            return Card(
              elevation: 2, margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text("Offre: ${req.offerType}", style: const TextStyle(fontWeight: FontWeight.bold))),
                        if (req.status == 'accepted') Chip(label: const Text("Acceptée"), backgroundColor: Colors.green.shade100),
                        if (req.status == 'rejected') Chip(label: const Text("Refusée"), backgroundColor: Colors.red.shade100),
                      ],
                    ),
                    Text("De: ${req.recyclerEmail}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 10),
                    if (req.status == 'pending')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(icon: const Icon(Icons.cancel, size: 18, color: Colors.red), label: const Text("Refuser"), onPressed: () async {
                            await context.read<RequestViewModel>().rejectRequest(req.id);
                            _refreshProviderData(email);
                          }),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(icon: const Icon(Icons.check_circle, size: 18), label: const Text("Accepter"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () async {
                            await context.read<RequestViewModel>().acceptRequest(req.id, req.offerId);
                            _refreshProviderData(email);
                          }),
                        ],
                      )
                    else if (req.status == 'accepted')
                       Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(icon: const Icon(Icons.email, size: 18), label: const Text("Contacter"), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), onPressed: () => _launchEmail(req.recyclerEmail))),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickDeclarationFormComplete(String email) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Publier rapidement", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          DropdownButtonFormField<String>(
            value: _selectedMaterial,
            decoration: const InputDecoration(labelText: "Type de déchet", border: OutlineInputBorder()),
            items: ["Carton", "Plastique", "Métal", "Bois", "Verre"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedMaterial = v),
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _selectedTransaction,
            decoration: const InputDecoration(labelText: "Type de transaction", border: OutlineInputBorder()),
            items: ["Vente", "Don"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedTransaction = v),
          ),
          const SizedBox(height: 15),
          if (_selectedTransaction == 'Vente')
            TextField(controller: _formPriceController, decoration: const InputDecoration(labelText: "Prix (TND)", border: OutlineInputBorder()), keyboardType: TextInputType.number),
          if (_selectedTransaction == 'Vente') const SizedBox(height: 15),
          TextField(controller: _formQtyController, decoration: const InputDecoration(labelText: "Quantité (kg)", border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 15),
          TextField(controller: _formLocController, decoration: const InputDecoration(labelText: "Localisation", border: OutlineInputBorder())),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Publier"),
              style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
              onPressed: () async {
                if(_selectedMaterial == null || _selectedTransaction == null || _formQtyController.text.isEmpty || _formLocController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Champs vides"), backgroundColor: Colors.red));
                  return;
                }
                await context.read<OfferViewModel>().addOffer(userEmail: email, materialType: _selectedMaterial!, quantity: _formQtyController.text, location: _formLocController.text, transactionType: _selectedTransaction!, price: _selectedTransaction == 'Vente' ? _formPriceController.text : null);
                _formQtyController.clear(); _formLocController.clear(); _formPriceController.clear();
                setState(() { _selectedMaterial = null; _selectedTransaction = null; });
                _refreshProviderData(email); // Rafraîchissement
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Offre publiée !"), backgroundColor: Colors.green));
              },
            ),
          )
        ],
      ),
    );
  }

  // --- DASHBOARD RECYCLEUR ---
  Widget _buildRecyclerDashboard(String? email) {
    if (email == null) return const Center(child: Text("Erreur email"));
    final offerVM = context.read<OfferViewModel>();
    final requestVM = context.read<RequestViewModel>();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDashboardWaveHeader("Espace Recycleur", email),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Offres Disponibles"),
                          const SizedBox(height: 10),
                          _buildRecyclerOffersList(email, offerVM),
                          const SizedBox(height: 30),
                          _buildSectionHeader("Mes Demandes"),
                          const SizedBox(height: 10),
                          _buildRecyclerRequestsList(email, requestVM),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader("Offres Disponibles"),
                              const SizedBox(height: 10),
                              _buildRecyclerOffersList(email, offerVM),
                            ],
                          )),
                          const SizedBox(width: 20),
                          Expanded(flex: 3, child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader("Mes Demandes"),
                              const SizedBox(height: 10),
                              _buildRecyclerRequestsList(email, requestVM),
                            ],
                          )),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecyclerOffersList(String email, OfferViewModel offerVM) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(hintText: "Rechercher...", prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.white),
          onChanged: (value) => setState(() => _recyclerSearchQuery = value.toLowerCase()),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<OfferModel>>(
          future: _availableOffersFuture, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucune offre."));

            final filtered = snapshot.data!.where((o) => _recyclerSearchQuery.isEmpty || o.materialType.toLowerCase().contains(_recyclerSearchQuery)).toList();
            
            return Column(
              children: filtered.map((o) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(o.materialType, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${o.quantity} kg - ${o.location}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.visibility, color: Colors.blueGrey), onPressed: () => _navigateToSection(OfferDetailScreen(offerId: o.id, offerData: o.toJson(), userEmail: email, userRole: 'recycleur'))),
                      ElevatedButton(child: const Text("Demander"), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008B8B)), onPressed: () async {
                        await context.read<RequestViewModel>().sendRequest(offerId: o.id, offerType: o.materialType, providerEmail: o.userEmail, recyclerEmail: email);
                        _refreshRecyclerData(email); // Rafraîchissement
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Demande envoyée !"), backgroundColor: Colors.green));
                      }),
                    ],
                  ),
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecyclerRequestsList(String email, RequestViewModel requestVM) {
    return FutureBuilder<List<RequestModel>>(
      future: _recyclerRequestsFuture, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)), child: const Center(child: Text("Aucune demande.")));

        return Column(
          children: snapshot.data!.map((req) => Card(
            elevation: 2, margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(req.status == 'pending' ? Icons.hourglass_top : (req.status == 'accepted' ? Icons.check_circle : Icons.cancel), color: req.status == 'pending' ? Colors.orange : (req.status == 'accepted' ? Colors.green : Colors.red)),
              title: Text("Offre: ${req.offerType}"),
              subtitle: Text("Statut: ${req.status == 'pending' ? 'En attente' : (req.status == 'accepted' ? 'Acceptée' : 'Refusée')}"),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (req.status == 'accepted') ElevatedButton.icon(icon: const Icon(Icons.email, size: 18), label: const Text("Contacter"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => _launchEmail(req.providerEmail)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                   bool? c = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text("Supprimer ?"), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Non")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Oui"))]));
                   if(c==true) {
                     await context.read<RequestViewModel>().deleteRequest(req.id);
                     _refreshRecyclerData(email);
                   }
                }),
              ]),
            ),
          )).toList(),
        );
      },
    );
  }

  // --- DASHBOARD ADMIN ---
  Widget _buildAdminDashboard() {
    final offerVM = context.watch<OfferViewModel>();
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDashboardWaveHeader("Administration", "Admin"),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Utilisateurs"),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>( 
                  stream: _usersStream, 
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final users = snapshot.data!.docs;
                    return Column(children: users.map((u) { var data = u.data() as Map<String, dynamic>; return Card(child: ListTile(title: Text(data['email'] ?? 'N/A'), subtitle: Text(data['role'] ?? 'N/A'), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => offerVM.deleteUser(data['email'])))); }).toList());
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionHeader("Toutes les Offres"),
                 FutureBuilder<List<OfferModel>>( 
                  future: _availableOffersFuture, 
                  builder: (context, snapshot) {
                     if(!snapshot.hasData) return const CircularProgressIndicator();
                     return Column(children: snapshot.data!.map((o) => Card(child: ListTile(title: Text(o.materialType), subtitle: Text(o.userEmail), trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                        await offerVM.deleteOffer(o.id);
                        setState(() => _availableOffersFuture = offerVM.getAvailableOffers()); // Refresh manuel
                     })))).toList());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGETS COMMUNS
  // ============================================================
  Widget _buildDashboardWaveHeader(String title, String subtitle) { return ClipPath(clipper: _WaveClipper(), child: Container(width: double.infinity, decoration: BoxDecoration(gradient: LinearGradient(colors: [darkGreen, lightGreen])), padding: const EdgeInsets.fromLTRB(20, 50, 20, 60), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.recycling, color: Color(0xFF2E7D32), size: 30)), const SizedBox(height: 10), Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12))]))); }
  Widget _buildSectionHeader(String title) => Text(title.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1.1));
  Widget _buildEmptyState() => Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)), child: Center(child: Column(children: [Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey[400]), const SizedBox(height: 10), const Text("Aucune donnée")])));

  // --- UTILITAIRES ---
  void _launchEmail(String email) async {
    final String subject = "Contact via ValorTrash";
    if (kIsWeb) {
      final String gmailUrl = 'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=$subject';
      try { bool launched = await launchUrl(Uri.parse(gmailUrl), mode: LaunchMode.externalApplication); if (!launched) _showWebEmailFallback(email); } catch (e) { _showWebEmailFallback(email); }
    } else {
      final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email, queryParameters: {'subject': subject});
      if (await canLaunchUrl(emailLaunchUri)) { await launchUrl(emailLaunchUri); }
    }
  }
  void _showWebEmailFallback(String email) { showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Contacter par email"), content: Column(mainAxisSize: MainAxisSize.min, children: [const Text("Copiez l'adresse ci-dessous :"), const SizedBox(height: 10), SelectableText(email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)), const SizedBox(height: 15), ElevatedButton.icon(icon: const Icon(Icons.copy), label: const Text("Copier"), onPressed: () { Clipboard.setData(ClipboardData(text: email)); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email copié !"), backgroundColor: Colors.green)); })]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer"))])); }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.75);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.75);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height * 0.6);
    var secondEndPoint = Offset(size.width, size.height * 0.75);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}