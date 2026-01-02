import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Internal file imports
import 'firebase_options.dart';
import 'screens/login.dart';
import 'screens/home.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before any platform calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initial system UI setting (useful for the splash screen phase)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Dark icons for Android
      statusBarBrightness: Brightness.light, // Dark icons for iOS
    ),
  );

  // 3. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sentiment Analysis',

      // THEME CONFIGURATION
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),

        // --- GLOBAL STATUS BAR FIX ---
        // This ensures that every page using an AppBar will force black icons
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark, // Android Black Icons
            statusBarBrightness: Brightness.light, // iOS Black Icons
          ),
        ),
      ),

      home: const AuthWrapper(),
    );
  }
}

// AuthWrapper: Listens to the user's login state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the stream is still connecting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.pink)),
          );
        }

        // If the user object exists, they are logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }

        // Default to Login Page
        return const LoginPage();
      },
    );
  }
}
