import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/offer_viewmodel.dart';
import 'viewmodels/request_viewmodel.dart';
import 'viewmodels/articles_viewmodel.dart';
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ValortrashApp());
}

class ValortrashApp extends StatelessWidget {
  const ValortrashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => OfferViewModel()),
        ChangeNotifierProvider(create: (_) => RequestViewModel()),
        ChangeNotifierProvider(create: (_) => ArticleViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VALORTRASH',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF008B8B),
        ),
        home: const HomePage(), // HomePage décide quoi afficher toute seule
      ),
    );
  }
}