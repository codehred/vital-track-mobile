import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  static const Color primaryBlue = Color(0xFF7DC3DE);
  static const Color textBlue = Color(0xFF4A90B8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Política de Privacidad',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última actualización: 03/12/2025',
              style: TextStyle(color: textBlue, fontSize: 12),
            ),
            const SizedBox(height: 15),
            const Text(
              'VitalTrack respeta y protege la privacidad de sus usuarios. '
              'Esta política describe cómo se recopila, utiliza y protege la '
              'información personal proporcionada a través de la aplicación.',
              style: TextStyle(color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 25),
            const Text(
              'Términos y Condiciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A90B8),
              ),
            ),
            const SizedBox(height: 15),
            _buildItem(
              '1.',
              'La aplicación VitalTrack está diseñada únicamente con fines informativos '
                  'y de monitoreo. No sustituye la atención médica profesional ni el diagnóstico clínico.',
            ),
            _buildItem(
              '2.',
              'El usuario es responsable de la veracidad de los datos ingresados. '
                  'VitalTrack no se hace responsable por interpretaciones incorrectas de la información mostrada.',
            ),
            _buildItem(
              '3.',
              'La información recopilada se utiliza exclusivamente para mejorar la experiencia del usuario '
                  'y ofrecer un mejor seguimiento de los signos vitales.',
            ),
            _buildItem(
              '4.',
              'Los datos personales no serán compartidos con terceros sin el consentimiento del usuario, '
                  'excepto cuando sea requerido por la ley.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Al utilizar esta aplicación, el usuario acepta los presentes términos y condiciones. '
              'VitalTrack se reserva el derecho de modificar esta política en cualquier momento.',
              style: TextStyle(color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
