import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/forgot_password.dart';
import 'screens/register.dart';
import 'screens/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      theme: ThemeData(primarySwatch: Colors.blueGrey, fontFamily: 'Arial'),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/register': (context) => const Register(),
      },
    );
  }
}
