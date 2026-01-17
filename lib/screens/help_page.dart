import 'package:flutter/material.dart';
import 'contact_page.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final Color primaryBlue = const Color(0xFF7DC3DE);
  final Color lightBlue = const Color(0xFFEAF6FB);

  String _searchText = '';
  bool _showFAQ = true;

  final List<Map<String, String>> _faqList = [
    {
      'question': '¿Qué es VitalTrack?',
      'answer':
          'VitalTrack es una aplicación diseñada para el monitoreo de signos vitales como frecuencia cardíaca, temperatura corporal y oxigenación.',
    },
    {
      'question': '¿Los datos se actualizan en tiempo real?',
      'answer':
          'Sí, los datos se actualizan conforme los sensores envían nueva información al sistema.',
    },
    {
      'question': '¿Puedo modificar los límites de alertas?',
      'answer':
          'Sí, desde la sección de alertas puedes configurar y eliminar alertas según tus necesidades.',
    },
    {
      'question': '¿Mis datos están seguros?',
      'answer':
          'La información se maneja de forma confidencial y solo es utilizada dentro de la aplicación.',
    },
    {
      'question': '¿VitalTrack sustituye a un médico?',
      'answer':
          'No, la aplicación es únicamente informativa y no reemplaza la atención médica profesional.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqList
        .where(
          (faq) => faq['question']!.toLowerCase().contains(
            _searchText.toLowerCase(),
          ),
        )
        .toList();

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
          'Centro De Ayuda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: primaryBlue,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Cómo te podemos ayudar?',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    setState(() => _searchText = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _showFAQ = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _showFAQ ? primaryBlue : lightBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'FAQ',
                          style: TextStyle(
                            color: _showFAQ ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navega a la página de contacto
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_showFAQ ? primaryBlue : lightBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Contáctanos',
                          style: TextStyle(
                            color: !_showFAQ ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredFaqs.length,
              itemBuilder: (context, index) {
                final faq = filteredFaqs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      faq['question']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    iconColor: Colors.black54,
                    collapsedIconColor: Colors.black54,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      Text(
                        faq['answer']!,
                        style: const TextStyle(
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
