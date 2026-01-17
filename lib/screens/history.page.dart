import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'alert_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Health health = Health();

  String selectedRange = 'Hoy';
  final List<String> ranges = [
    'Hoy',
    'Últimos 2 días',
    'Últimos 5 días',
    'Última semana',
  ];

  String bpmValue = '--';
  List<FlSpot> bpmSpots = [];

  String spo2Value = '--';
  List<FlSpot> spo2Spots = [];

  String calValue = '--';
  List<FlSpot> calSpots = [];

  String stepsValue = '--';
  List<FlSpot> stepsSpots = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataForRange(selectedRange);
    });
  }

  Future<void> _fetchDataForRange(String range) async {
    setState(() => isLoading = true);

    DateTime now = DateTime.now();
    DateTime startTime;

    switch (range) {
      case 'Hoy':
        startTime = DateTime(now.year, now.month, now.day);
        break;
      case 'Últimos 2 días':
        startTime = now.subtract(const Duration(days: 2));
        break;
      case 'Últimos 5 días':
        startTime = now.subtract(const Duration(days: 5));
        break;
      case 'Última semana':
        startTime = now.subtract(const Duration(days: 7));
        break;
      default:
        startTime = DateTime(now.year, now.month, now.day);
    }

    List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    try {
      bool authorized = await health.requestAuthorization(types);
      if (authorized) {
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
          startTime: startTime,
          endTime: now,
          types: types,
        );

        healthData = health.removeDuplicates(healthData);
        healthData.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

        _processData(healthData, startTime);
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    }

    setState(() => isLoading = false);
  }

  void _processData(List<HealthDataPoint> data, DateTime startTime) {
    List<FlSpot> tempBpm = [];
    List<FlSpot> tempSpo2 = [];
    List<FlSpot> tempCal = [];
    List<FlSpot> tempSteps = [];

    double lastBpm = 0;
    double lastSpo2 = 0;
    double totalCal = 0;
    int totalSteps = 0;

    for (var point in data) {
      double xValue = point.dateFrom.difference(startTime).inMinutes.toDouble();

      if (point.value is NumericHealthValue) {
        double val = (point.value as NumericHealthValue).numericValue
            .toDouble();

        if (point.type == HealthDataType.HEART_RATE) {
          tempBpm.add(FlSpot(xValue, val));
          lastBpm = val;
        } else if (point.type == HealthDataType.BLOOD_OXYGEN) {
          if (val <= 1.0) val *= 100;
          tempSpo2.add(FlSpot(xValue, val));
          lastSpo2 = val;
        } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          tempCal.add(FlSpot(xValue, val));
          totalCal += val;
        } else if (point.type == HealthDataType.STEPS) {
          tempSteps.add(FlSpot(xValue, val));
          totalSteps += val.toInt();
        }
      }
    }

    if (totalCal == 0 && totalSteps > 0) {
      totalCal = totalSteps * 0.04;
      tempCal.add(const FlSpot(0, 0));
      tempCal.add(FlSpot(100, totalCal));
    }

    setState(() {
      bpmSpots = tempBpm;
      spo2Spots = tempSpo2;
      calSpots = tempCal;
      stepsSpots = tempSteps;

      bpmValue = lastBpm > 0 ? lastBpm.round().toString() : '--';
      spo2Value = lastSpo2 > 0 ? lastSpo2.round().toString() : '--';
      calValue = totalCal > 0 ? totalCal.round().toString() : '--';
      stepsValue = totalSteps > 0 ? totalSteps.toString() : '--';
    });
  }

  void _showDownloadPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        //pasar valores
        return DownloadProgressDialog(
          bpm: bpmValue,
          spo2: spo2Value,
          cal: calValue,
          steps: stepsValue,
          range: selectedRange,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Historial',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 0,
        foregroundColor: Colors.black87,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRange,
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        items: ranges
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedRange = val);
                            _fetchDataForRange(val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _showDownloadPopup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7DC3DE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Descargar reporte'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _MetricCard(
              title: 'Frecuencia Cardíaca',
              value: bpmValue,
              unit: 'BPM',
              spots: bpmSpots,
              color: const Color(0xFF7DC3DE),
            ),
            _MetricCard(
              title: 'SpO₂',
              value: spo2Value,
              unit: '%',
              spots: spo2Spots,
              color: Colors.blueAccent,
            ),
            _MetricCard(
              title: 'Calorías Quemadas',
              value: calValue,
              unit: 'kcal',
              spots: calSpots,
              color: Colors.orangeAccent,
            ),
            _MetricCard(
              title: 'Pasos',
              value: stepsValue,
              unit: 'pasos',
              spots: stepsSpots,
              color: Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final List<FlSpot> spots;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.spots,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: spots.isEmpty
                ? Center(
                    child: Text(
                      "Sin datos",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: color),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

//new pop-up¿
class DownloadProgressDialog extends StatefulWidget {
  final String bpm;
  final String spo2;
  final String cal;
  final String steps;
  final String range;

  const DownloadProgressDialog({
    super.key,
    required this.bpm,
    required this.spo2,
    required this.cal,
    required this.steps,
    required this.range,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    _generateAndOpenPdf();
  }

  Future<void> _generateAndOpenPdf() async {
    //barra de progreso
    for (int i = 0; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => progress = i / 10);
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text("Reporte VitalTrack")),
              pw.SizedBox(height: 10),
              pw.Text(
                "Fecha de generación: ${DateTime.now().toString().split('.')[0]}",
              ),
              pw.Text("Rango de datos: ${widget.range}"),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                "Resumen de Signos Vitales",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 15),
              _pdfRow("Frecuencia Cardíaca", widget.bpm, "BPM"),
              _pdfRow("Saturación de Oxígeno", widget.spo2, "%"),
              _pdfRow("Calorías Quemadas", widget.cal, "kcal"),
              _pdfRow("Pasos Totales", widget.steps, "pasos"),
              pw.SizedBox(height: 40),
              pw.Footer(
                title: pw.Text("Generado automáticamente por VitalTrack App"),
              ),
            ],
          );
        },
      ),
    );

    for (int i = 6; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => progress = i / 10);
    }

    //guardado y apertura
    try {
      final output = await getExternalStorageDirectory();
      final file = File("${output!.path}/Reporte_VitalTrack.pdf");

      //  escritura de archivo
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        Navigator.of(
          context,
        ).pop(); //el pop up se cerrará automáticamente al abrir el archivo

        OpenFile.open(file.path);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reporte generado con éxito"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error PDF: $e");
      if (mounted) Navigator.of(context).pop();
    }
  }

  pw.Widget _pdfRow(String label, String value, String unit) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(
            "$value $unit",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Descargando\nReporte...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF7DC3DE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.file_copy, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 30),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF7DC3DE),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 15),
            const Text(
              "Su reporte está descargándose. No cierre la aplicación ni apague el dispositivo.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
