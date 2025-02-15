import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taurusai/models/user.dart';
import 'package:taurusai/screens/home_page.dart';
import 'package:taurusai/screens/login_screen.dart';
import 'package:taurusai/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyA1M1MkPGdu4tmiHSZFdVhhQuGmR0dm7Mo",
              authDomain: "taurusai-812e1.firebaseapp.com",
              projectId: "taurusai-812e1",
              storageBucket: "taurusai-812e1.firebasestorage.app",
              messagingSenderId: "652369010478",
              appId: "1:652369010478:web:0808ebc5137f022488a4bf",
              measurementId: "G-PY5PCW39ZN"));
    } else {
      await Firebase.initializeApp();
    }
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  User? currentUser = await AuthService().getCurrentUser();

  runApp(MyApp(initialUser: currentUser));
}

class MyApp extends StatelessWidget {
  final User? initialUser;

  MyApp({this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: initialUser != null ? HomePage(user: initialUser!) : LoginScreen(),
    );
  }
}
