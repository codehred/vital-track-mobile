import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para verificar sesión activa
import 'screens/splash_screen.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/forgot_password.dart';
import 'screens/register.dart';
import 'screens/profile_page.dart';
import 'screens/edit_profile_page.dart';
import 'screens/change_password_page.dart';
import 'screens/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint("Firebase conectado con éxito");
  } catch (e) {
    debugPrint("Error crítico al conectar con Firebase: $e");
  }

  await NotificationService().initialize();
  runApp(const VitalTrackApp());
}

class VitalTrackApp extends StatelessWidget {
  const VitalTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VitalTrack',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? '/dashboard'
          : '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/register': (context) => const Register(),
        '/profile': (context) => const ProfilePage(),
        '/edit_profile': (context) => const EditProfilePage(),
      },

      // manejo dinámico / parámetros
      onGenerateRoute: (settings) {
        if (settings.name == '/change_password') {
          final args = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => ChangePasswordPage(email: args ?? ""),
          );
        }
        return null;
      },
    );
  }
}
