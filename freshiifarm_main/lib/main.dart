import 'package:flutter/material.dart';
//FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'package:freshiifarm_main/firebase_options.dart';
//PAGES
import 'package:freshiifarm_main/splashScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase connected successfully!");
  } catch (e) {
    print("❌ Firebase connection failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshiiFarm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 195, 227, 54)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
