import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/kategori_provider.dart';
import 'providers/barang_provider.dart';
import 'providers/transaksi_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'firebase_options.dart';
import 'widgets/app_theme.dart';

import 'screens/splash_screen.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    initializeDateFormatting('id_ID', null),
  ]);

  await _configureFirestore();

  final providers = <ChangeNotifierProvider<dynamic>>[
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => KategoriProvider()),
    ChangeNotifierProvider(create: (_) => BarangProvider()),
    ChangeNotifierProvider(create: (_) => TransaksiProvider()),
    ChangeNotifierProvider(create: (_) => CartProvider()),
  ];
  
  runApp(
    MultiProvider(
      providers: providers,
      child: const MyApp(),
    ),
  );
}

Future<void> _configureFirestore() async {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firestore settings already configured: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Inventory App',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme.copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(themeProvider.lightTheme.textTheme),
          ),
          darkTheme: themeProvider.darkTheme.copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(themeProvider.darkTheme.textTheme),
          ),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}