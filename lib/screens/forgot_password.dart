import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'verification_code_page.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _enviarCodigoReal() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    // Generar código de 6 dígitos
    String nuevoCodigo = (Random().nextInt(900000) + 100000).toString();

    try {
      await FirebaseFirestore.instance
          .collection('recuperaciones')
          .doc(email)
          .set({'codigo': nuevoCodigo, 'fecha': DateTime.now()});

      // enviar correo vía EmailJS
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': 'service_4cto80b',
          'template_id': 'template_dkgdwoq',
          'user_id': '5SKJONSo-hBoDAE7V',
          'template_params': {
            'user_email': _emailController.text.trim(),
            'codigo_generado': nuevoCodigo,
          },
        }),
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationCodePage(email: email),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Recuperar Acceso',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _enviarCodigoReal,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Enviar código"),
            ),
          ],
        ),
      ),
    );
  }
}
