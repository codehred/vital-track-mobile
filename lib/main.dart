import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para verificar sesión activa
import 'screens/splash_screen.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/forgot_password.dart';
import 'screens/register.dart';
import 'screens/profile_page.dart'; // Nueva importación
import 'screens/edit_profile_page.dart'; // Nueva importación
import 'screens/change_password_page.dart'; // Nueva importación
import 'screens/notification_service.dart';

void main() async {
  // Asegura que los servicios nativos de Flutter (como Firebase) estén listos
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa Firebase con la configuración del google-services.json
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
        useMaterial3: true, // Habilita el diseño moderno de Android
      ),
      // Lógica para determinar la pantalla inicial
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? '/dashboard'
          : '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/register': (context) => const Register(),

        // Rutas del perfil necesarias para navegar correctamente
        '/profile': (context) => const ProfilePage(),
        '/edit_profile': (context) => const EditProfilePage(),
        '/change_password': (context) => const ChangePasswordPage(),
      },
    );
  }
}
