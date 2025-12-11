import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  final Color primaryBlue = const Color(0xFF7DC3DE);
  final Color lightBlue = const Color(0xFFEAF6FB);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(uri)) {
      throw Exception('No se pudo hacer la llamada');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Soporte VitalTrack&body=Hola, necesito ayuda con...',
    );
    if (!await launchUrl(uri)) {
      throw Exception('No se pudo abrir el cliente de correo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contáctanos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '¿Necesitas ayuda adicional?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contáctanos a través de cualquiera de estos medios',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 30),
          _buildContactOption(
            icon: Icons.headset_mic,
            title: 'Servicio Al Cliente',
            subtitle: 'Atención de Lun-Vie 9:00 AM - 6:00 PM',
            color: Colors.blue,
            onTap: () => _makePhoneCall('+527444738589'),
          ),
          const SizedBox(height: 15),
          _buildContactOption(
            icon: Icons.language,
            title: 'Página Web',
            subtitle: 'www.vitaltrack.com',
            color: Colors.teal,
            onTap: () => _launchURL('https://codehred.github.io/vital-track/'),
          ),
          const SizedBox(height: 15),
          _buildContactOption(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'soporte@vitaltrack.com',
            color: Colors.orange,
            onTap: () => _sendEmail('testdevitaltrack@gmail.com'),
          ),
          const SizedBox(height: 15),
          _buildContactOption(
            icon: Icons.chat,
            title: 'WhatsApp',
            subtitle: '+52 7444738589',
            color: Colors.green,
            onTap: () => _launchURL('https://wa.me/527444738589'),
          ),
          const SizedBox(height: 15),
          _buildContactOption(
            icon: Icons.facebook,
            title: 'Facebook',
            subtitle: '@VitalTrackApp',
            color: Colors.blue[800]!,
            onTap: () =>
                _launchURL('https://www.facebook.com/FisicaMientrasHagoCosas'),
          ),
          const SizedBox(height: 15),
          _buildContactOption(
            icon: Icons.camera_alt,
            title: 'Instagram',
            subtitle: '@vitaltrack_official',
            color: Colors.purple,
            onTap: () => _launchURL('https://www.instagram.com/katarinabluu/'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
