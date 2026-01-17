import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _requestPermissions();

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Notificación tocada: ${response.payload}');
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final generalEnabled = prefs.getBool('notifications_general') ?? true;

    if (!generalEnabled) return;

    final soundEnabled = prefs.getBool('notifications_sound') ?? true;
    final vibrationEnabled = prefs.getBool('notifications_vibration') ?? false;

    final String channelId = _getChannelId(soundEnabled, vibrationEnabled);
    final String channelName = _getChannelName(soundEnabled, vibrationEnabled);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notificaciones de signos vitales',
      importance: Importance.high,
      priority: Priority.high,
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
      vibrationPattern: vibrationEnabled
          ? Int64List.fromList([0, 500, 200, 500])
          : null,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: soundEnabled,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  String _getChannelId(bool sound, bool vibration) {
    if (sound && vibration) {
      return 'vitaltrack_sound_vibration';
    } else if (sound && !vibration) {
      return 'vitaltrack_sound_only';
    } else if (!sound && vibration) {
      return 'vitaltrack_vibration_only';
    } else {
      return 'vitaltrack_silent';
    }
  }

  String _getChannelName(bool sound, bool vibration) {
    if (sound && vibration) {
      return 'VitalTrack - Sonido y Vibración';
    } else if (sound && !vibration) {
      return 'VitalTrack - Solo Sonido';
    } else if (!sound && vibration) {
      return 'VitalTrack - Solo Vibración';
    } else {
      return 'VitalTrack - Silencioso';
    }
  }

  Future<void> showVitalSignAlert({
    required String vitalSign,
    required String value,
    required String status,
  }) async {
    String emoji = '';
    String statusText = '';

    switch (status.toLowerCase()) {
      case 'high':
        emoji = '⚠️';
        statusText = 'Alto';
        break;
      case 'low':
        emoji = '⚠️';
        statusText = 'Bajo';
        break;
      case 'critical':
        emoji = '🚨';
        statusText = 'Crítico';
        break;
      default:
        emoji = 'ℹ️';
        statusText = 'Normal';
    }

    await showNotification(
      title: '$emoji Alerta de $vitalSign',
      body: 'Tu $vitalSign está $statusText: $value',
      payload: 'vital_sign_alert',
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
