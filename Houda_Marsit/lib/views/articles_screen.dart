import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:valortrash/viewmodels/articles_viewmodel.dart';

// =====================================================
// --- PAGE LISTE DES ARTICLES ---
// =====================================================
class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  final Map<String, String> _articleImagesMap = const {
    "Guide de recyclage": "assets/images/guide.jpg",
    "L'importance de recyclage": "assets/images/importance.jpg",
  };
  final String _defaultArticleImage = "assets/images/default_article.jpg";

  @override
  Widget build(BuildContext context) {

    final articleVM = context.watch<ArticleViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: articleVM.getArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const Text("Aucun article pour le moment", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          var articles = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              var articleData = articles[index].data() as Map<String, dynamic>;
              return _buildModernArticleCard(context, articleData);
            },
          );
        },
      ),
    );
  }

  Widget _buildModernArticleCard(BuildContext context, Map<String, dynamic> article) {
    String title = article['title'] ?? 'Sans titre';
    String imagePath = _articleImagesMap[title] ?? _defaultArticleImage;
    
    // Gestion sécurisée du résumé
    String content = article['content'] ?? '';
    String summary = article['summary'] ?? (content.length > 100 ? content.substring(0, 100) + '...' : content);

    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article))
      ),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                imagePath,
                height: 180, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(
                  height: 180, color: Colors.green[50], 
                  child: Center(child: Icon(Icons.image, color: Colors.green[100], size: 50))
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text(summary, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text("Lire la suite", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, size: 16, color: Color(0xFF2E7D32)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// --- PAGE DÉTAILS ARTICLE ---
// =====================================================
class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    String title = article['title'] ?? 'Titre inconnu';
    String content = article['content'] ?? 'Pas de contenu disponible.';
    String author = article['author'] ?? 'ValorTrash';

    final Map<String, String> localImagesMap = {
      "Guide de recyclage": "assets/images/guide.jpg",
      "L'importance de recyclage": "assets/images/importance.jpg",
    };
    String imagePath = localImagesMap[title] ?? "assets/images/default_article.jpg";

    // Gestion de la date
    String date = "Date inconnue";
    if (article['createdAt'] != null && article['createdAt'] is Timestamp) {
      Timestamp timestamp = article['createdAt'];
      DateTime dateObj = timestamp.toDate();
      date = "${dateObj.day}/${dateObj.month}/${dateObj.year}";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de l'article"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              height: 220, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Container(
                  height: 220, color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey))
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black, height: 1.3)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(author, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 15),
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Divider(height: 30),
                  Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}