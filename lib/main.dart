import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_dashboard.dart';
import 'screens/scam_shield_screen.dart';
import 'screens/medical_translation_screen.dart';
import 'services/firebase_service.dart';
import 'services/gemini_service.dart';

import 'services/notification_service.dart';
import 'services/background_monitor_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed (expected without google-services.json): $e");
  }

  await NotificationService.initialize();
  await BackgroundMonitorService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseService()),
        ChangeNotifierProvider(create: (_) => GeminiService()),
      ],
      child: const KinCareConnectApp(),
    ),
  );
}

class KinCareConnectApp extends StatelessWidget {
  const KinCareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kin-CareConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main_nav': (context) => const MainNavigator(),
      },
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(physics: const BouncingScrollPhysics()),
          child: child!,
        );
      },
    );
  }
}

// Global Bottom Navigation Bar identical to Instagram's Layout
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboard(),               // Routine Intelligence Dashboard (Home)
    MedicalTranslationScreen(),    // Medical Translation Agent (Services)
    ScamShieldScreen(),            // Scam Shield (Security)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.secondary, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined, size: 28),
              activeIcon: Icon(Icons.medical_services, size: 28),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined, size: 28),
              activeIcon: Icon(Icons.shield, size: 28),
              label: 'Security',
            ),
          ],
        ),
      ),
    );
  }
}
