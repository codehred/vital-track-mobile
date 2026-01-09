import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'history.page.dart';
import 'alert_page.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _autorizarYLeerDatos();
  }

  Future<void> _autorizarYLeerDatos() async {
    List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
    ];

    // Definimos permisos de lectura explícitos para la versión 10.x
    List<HealthDataAccess> permissions = types
        .map((e) => HealthDataAccess.READ)
        .toList();

    try {
      // 1. Pedir autorización
      bool authorized = await health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (authorized) {
        DateTime now = DateTime.now();
        DateTime yesterday = now.subtract(const Duration(hours: 24));

        // 2. Obtener datos con parámetros nombrados
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
          startTime: yesterday,
          endTime: now,
          types: types,
        );

        // 3. Procesar y actualizar la UI
        setState(() {
          for (var data in healthData) {
            String valorString = "0";

            // Extraemos el valor numérico de forma genérica
            final value = data.value;
            if (value is NumericHealthValue) {
              valorString = value.numericValue.toInt().toString();
            }

            // Asignación a los índices de tu lista vitalsData
            if (data.type == HealthDataType.HEART_RATE) {
              vitalsData[0]['value'] = valorString; // BPM
            } else if (data.type == HealthDataType.BLOOD_OXYGEN) {
              vitalsData[1]['value'] = valorString; // SpO2
            } else if (data.type == HealthDataType.STEPS) {
              vitalsData[3]['value'] = valorString; // PASOS
            }
          }
        });
      } else {
        debugPrint("Permisos denegados por el usuario");
      }
    } catch (e) {
      debugPrint("Error crítico en salud: $e");
    }
  }

  List<Map<String, dynamic>> vitalsData = [
    {'icon': Icons.favorite, 'label': 'BPM', 'value': '--', 'unit': 'lpm'},
    {'icon': Icons.water_drop, 'label': 'SpO₂', 'value': '--', 'unit': '%'},
    {
      'icon': Icons.psychology,
      'label': 'ESTRÉS',
      'value': '--',
      'unit': '/100',
    },
    {
      'icon': Icons.directions_walk,
      'label': 'PASOS',
      'value': '--',
      'unit': '',
    },
  ];

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F4FB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'Espacio para gráfica',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
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
                fontSize: 16,
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
                    fontSize: 28,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
