import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_settings_page.dart';
import 'change_password_page.dart';

class ConfigurationPage extends StatelessWidget {
  const ConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Configuración de Notificaciones'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Cambiar Contraseña'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Verificamos que el email no sea nulo antes de navegar
              if (userEmail != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangePasswordPage(email: userEmail),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No se pudo obtener el correo del usuario"),
                  ),
                );
              }
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Borrar Cuenta',
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              //agregar funcionalidad de borrar cuenta
            },
          ),
        ],
      ),
    );
  }
}
