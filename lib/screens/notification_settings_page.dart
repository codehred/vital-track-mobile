import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final Color primaryBlue = const Color(0xFF7DC3DE);
  final NotificationService _notificationService = NotificationService();

  bool general = true;
  bool sound = true;
  bool vibration = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      general = prefs.getBool('notifications_general') ?? true;
      sound = prefs.getBool('notifications_sound') ?? true;
      vibration = prefs.getBool('notifications_vibration') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_general', general);
    await prefs.setBool('notifications_sound', sound);
    await prefs.setBool('notifications_vibration', vibration);
  }

  Future<void> _testNotification() async {
    await _notificationService.showNotification(
      title: '✅ Notificación de Prueba',
      body: 'Las notificaciones están funcionando correctamente',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notificación de prueba enviada'),
          backgroundColor: primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _testVitalSignAlert() async {
    await _notificationService.showVitalSignAlert(
      vitalSign: 'Frecuencia Cardíaca',
      value: '95 BPM',
      status: 'high',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Alerta de signo vital enviada'),
          backgroundColor: primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: primaryBlue),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Configuración de Notificaciones',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active,
                  title: 'Notificaciones Generales',
                  subtitle: 'Activa o desactiva todas las notificaciones',
                  value: general,
                  onChanged: (value) async {
                    setState(() => general = value);
                    await _saveSettings();

                    if (!value) {
                      await _notificationService.cancelAll();
                    }
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
                _buildSwitchTile(
                  icon: Icons.volume_up,
                  title: 'Sonido',
                  subtitle: 'Reproducir sonido al recibir notificaciones',
                  value: sound,
                  enabled: general,
                  onChanged: (value) async {
                    setState(() => sound = value);
                    await _saveSettings();
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
                _buildSwitchTile(
                  icon: Icons.vibration,
                  title: 'Vibración',
                  subtitle: 'Vibrar al recibir notificaciones',
                  value: vibration,
                  enabled: general,
                  onChanged: (value) async {
                    setState(() => vibration = value);
                    await _saveSettings();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: primaryBlue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recibirás alertas cuando tus signos vitales estén fuera del rango normal',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: general ? _testNotification : null,
            icon: const Icon(Icons.notifications),
            label: const Text('Probar Notificación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: general ? _testVitalSignAlert : null,
            icon: const Icon(Icons.favorite),
            label: const Text('Probar Alerta de Signo Vital'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled ? primaryBlue.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: enabled ? primaryBlue : Colors.grey, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled ? Colors.black87 : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        activeThumbColor: primaryBlue,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
