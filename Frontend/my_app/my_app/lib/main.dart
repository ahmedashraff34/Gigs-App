import 'package:flutter/material.dart';
import 'Screens/auth.dart';
import 'Screens/runner_home_screen.dart';
import 'Screens/poster_home_screen.dart';
import 'Screens/admin_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/token_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gigs',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFF11366A),
          onPrimary: Colors.white,
          secondary: const Color(0xFFEBF1FD),
          onSecondary: const Color(0xFF11366A),
          error: Colors.red,
          onError: Colors.white,
          background: const Color(0xFFF6F6F6),
          onBackground: const Color(0xFF11366A),
          surface: Colors.white,
          onSurface: const Color(0xFF11366A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: TokenService.isAuthenticated(),
        builder: (ctx, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authSnapshot.data == true) {
            // If the user is authenticated, we can decide where to send them.
            // For now, let's default to the RunnerHomeScreen to show the new screen.
            return const RunnerHomeScreen();
          }

          // If not authenticated, show the login screen.
          return const AuthScreen();
        },
      ),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/runner-home': (context) => const RunnerHomeScreen(),
        '/poster-home': (context) => const PosterHomeScreen(),
        '/admin-dashboard': (context) => const AdminDashboard(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        );
      },
    );
  }
}