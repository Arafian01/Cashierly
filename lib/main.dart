import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/kategori_provider.dart';
import 'providers/barang_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBuomVDqWWqMDm0h3GGZI5vZuWIbSvSn90",
      authDomain: "inventory-app-f8ff6.firebaseapp.com",
      projectId: "inventory-app-f8ff6",
      storageBucket: "inventory-app-f8ff6.firebasestorage.app",
      messagingSenderId: "594527888713",
      appId: "1:594527888713:web:4abaaf662abffeb9086698",
      measurementId: "G-WS5HEG6QKV",
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KategoriProvider()),
        ChangeNotifierProvider(create: (_) => BarangProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory App',
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}