import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'history.page.dart';
import 'alert_page.dart';
import 'package:health/health.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF7DC3DE),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Health health = Health();

  List<Map<String, dynamic>> vitalsData = [
    {'icon': Icons.favorite, 'label': 'BPM', 'value': '--', 'unit': 'lpm'},
    {'icon': Icons.water_drop, 'label': 'SpO₂', 'value': '--', 'unit': '%'},
    {
      'icon': Icons.local_fire_department,
      'label': 'CALORÍAS',
      'value': '--',
      'unit': 'kcal',
    },
    {
      'icon': Icons.directions_walk,
      'label': 'PASOS',
      'value': '--',
      'unit': '',
    },
  ];

  List<FlSpot> chartSpots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autorizarYLeerDatos();
    });
  }

  Future<void> _autorizarYLeerDatos() async {
    List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    List<HealthDataAccess> permissions = types
        .map((e) => HealthDataAccess.READ)
        .toList();

    try {
      bool authorized = await health.requestAuthorization(
        types,
        permissions: permissions,
      );
      if (authorized) {
        _obtenerDatos(types);
      }
    } catch (e) {
      debugPrint("Error auth: $e");
    }
  }

  Future<void> _obtenerDatos(List<HealthDataType> types) async {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(hours: 24));
    DateTime midnight = DateTime(now.year, now.month, now.day);

    try {
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: types,
      );

      healthData = health.removeDuplicates(healthData);
      healthData.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

      double totalCalorias = 0;
      int totalPasos = 0;
      List<FlSpot> tempSpots = [];

      setState(() {
        for (var data in healthData) {
          final value = data.value;

          if (value is NumericHealthValue) {
            // LÓGICA DE TARJETAS
            if (data.type == HealthDataType.HEART_RATE) {
              double bpm = value.numericValue.toDouble();
              vitalsData[0]['value'] = bpm.round().toString();

              // LÓGICA GRÁFICO
              double hoursFromStart =
                  data.dateFrom.difference(yesterday).inMinutes / 60.0;
              tempSpots.add(FlSpot(hoursFromStart, bpm));
            } else if (data.type == HealthDataType.BLOOD_OXYGEN) {
              double val = value.numericValue.toDouble();
              if (val <= 1.0) val = val * 100;
              vitalsData[1]['value'] = val.round().toString();
            } else if (data.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              if (data.dateFrom.isAfter(midnight)) {
                totalCalorias += value.numericValue.toDouble();
              }
            } else if (data.type == HealthDataType.STEPS) {
              if (data.dateFrom.isAfter(midnight)) {
                totalPasos += value.numericValue.toInt();
              }
            }
          }
        }
        if (totalCalorias == 0 && totalPasos > 0) {
          // Si Health Connect nos da 0 pero hay pasos, calculamos aprox.
          totalCalorias = totalPasos * 0.04;
        }

        vitalsData[2]['value'] = totalCalorias.round().toString();
        vitalsData[3]['value'] = totalPasos.toString();

        chartSpots = tempSpots;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Signos Vitales',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Botón para refrescar manualmente
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF7DC3DE)),
            onPressed: _autorizarYLeerDatos,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsPage()),
              ),
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              label: const Text(
                'ALERTAS',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7DC3DE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- GRID DE TARJETAS ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vitalsData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                return VitalCard(
                  icon: vitalsData[index]['icon'],
                  label: vitalsData[index]['label'],
                  value: vitalsData[index]['value'],
                  unit: vitalsData[index]['unit'],
                );
              },
            ),

            const SizedBox(height: 20),

            // --- CONTENEDOR DEL GRÁFICO ---
            Container(
              height: 200, // Un poco más alto para que el gráfico respire
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, // Fondo blanco para resaltar el gráfico
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE5F4FB),
                  width: 2,
                ), // Borde sutil
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ritmo Cardíaco (24h)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: chartSpots.isEmpty
                        ? const Center(
                            child: Text(
                              "Esperando datos...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              gridData: const FlGridData(
                                show: false,
                              ), // Sin cuadrícula para limpieza
                              titlesData: const FlTitlesData(
                                show: false,
                              ), // Sin números en ejes
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: 24, // Eje X de 0 a 24 horas
                              minY: 40,
                              maxY: 160, // Rango de corazón
                              lineBarsData: [
                                LineChartBarData(
                                  spots: chartSpots,
                                  isCurved: true, // Curva suave
                                  color: const Color(0xFF7DC3DE),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    // Degradado bonito debajo de la línea
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(
                                          0xFF7DC3DE,
                                        ).withOpacity(0.4),
                                        const Color(
                                          0xFF7DC3DE,
                                        ).withOpacity(0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... VitalCard se queda igual
class VitalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const VitalCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF7DC3DE)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
