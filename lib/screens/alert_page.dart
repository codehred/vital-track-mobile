import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  Timer? _timer;

  Health health = Health();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, String>> alerts = [];
  bool isLoading = true;
  bool deleteMode = false;

  @override
  void initState() {
    super.initState();
    _initNotifications();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVitalsAndNotify();
    });

    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        debugPrint("Escaneando signos vitales en segundo plano...");
        _checkVitalsAndNotify();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showSystemNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'vitaltrack_alerts_SILENT',
          'Alertas Silenciosas',
          channelDescription:
              'Notificaciones sobre anomalías en signos vitales',
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.red,
          playSound: false,
          enableVibration: false,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    int uniqueId = DateTime.now().microsecondsSinceEpoch.remainder(2147483647);

    await flutterLocalNotificationsPlugin.show(uniqueId, title, body, details);
  }

  Future<void> _checkVitalsAndNotify() async {
    setState(() => isLoading = true);

    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(hours: 24));

    List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
    ];

    List<Map<String, String>> detectedAlerts = [];

    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      bool authorized = await health.requestAuthorization(types);
      if (authorized) {
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
          startTime: yesterday,
          endTime: now,
          types: types,
        );

        healthData = health.removeDuplicates(healthData);

        var highBpmPoints = healthData
            .where(
              (d) =>
                  d.type == HealthDataType.HEART_RATE &&
                  (d.value as NumericHealthValue).numericValue > 100,
            )
            .toList();

        if (highBpmPoints.isNotEmpty) {
          double maxVal = 0;
          for (var p in highBpmPoints) {
            double v = (p.value as NumericHealthValue).numericValue.toDouble();
            if (v > maxVal) maxVal = v;
          }

          String msg = '${maxVal.round()} BPM detectados hoy';
          detectedAlerts.add({
            'title': 'Frecuencia Cardíaca Alta',
            'value': msg,
          });

          await _showSystemNotification(
            '¡Alerta Cardíaca!',
            'Tu ritmo cardíaco subió a ${maxVal.round()} BPM.',
          );
        }

        var lowSpo2Points = healthData
            .where((d) => d.type == HealthDataType.BLOOD_OXYGEN)
            .toList();

        double minSpo2 = 100.0;
        bool foundLow = false;

        for (var p in lowSpo2Points) {
          double v = (p.value as NumericHealthValue).numericValue.toDouble();
          if (v <= 1.0) v = v * 100;

          if (v < 92.0) {
            foundLow = true;
            if (v < minSpo2) minSpo2 = v;
          }
        }

        if (foundLow) {
          String msg = '${minSpo2.round()}% nivel crítico';
          detectedAlerts.add({'title': 'Hipoxia Detectada', 'value': msg});

          await _showSystemNotification(
            'Oxígeno Bajo',
            'Tu saturación cayó al ${minSpo2.round()}%.',
          );
        }
      }
    } catch (e) {
      debugPrint("Error obteniendo alertas: $e");
    }

    setState(() {
      alerts = detectedAlerts;
      isLoading = false;
    });

    for (int i = 0; i < alerts.length; i++) {
      _listKey.currentState?.insertItem(i);
    }
  }

  Future<void> _confirmDelete(int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, size: 40, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                'Eliminar alerta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '¿Deseas descartar esta alerta?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      final removedItem = alerts[index];

      _listKey.currentState!.removeItem(
        index,
        (context, animation) => _buildAnimatedItem(removedItem, animation),
        duration: const Duration(milliseconds: 300),
      );

      setState(() {
        alerts.removeAt(index);
        if (alerts.isEmpty) deleteMode = false;
      });
    }
  }

  Widget _buildAnimatedItem(
    Map<String, String> alert,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 45,
                      height: 45,
                      child: Center(
                        child: Icon(Icons.warning, color: Colors.red, size: 32),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert['title']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            alert['value']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (deleteMode)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      int idx = alerts.indexOf(alert);
                      if (idx != -1) _confirmDelete(idx);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Alertas Detectadas'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF7DC3DE)),
            onPressed: _checkVitalsAndNotify,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isLoading)
              const LinearProgressIndicator(color: Color(0xFF7DC3DE)),
            Expanded(
              child: alerts.isEmpty && !isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: Colors.green.withOpacity(0.5),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Sin alertas activas",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const Text(
                            "Tus signos vitales están estables.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : AnimatedList(
                      key: _listKey,
                      initialItemCount: alerts.length,
                      itemBuilder: (context, index, animation) {
                        if (index >= alerts.length) {
                          return const SizedBox.shrink();
                        }
                        return _buildAnimatedItem(alerts[index], animation);
                      },
                    ),
            ),
            if (alerts.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => setState(() => deleteMode = !deleteMode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deleteMode
                        ? Colors.grey
                        : const Color(0xFF7DC3DE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    deleteMode ? 'Cancelar Edición' : 'Gestionar Alertas',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
