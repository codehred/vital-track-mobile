import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'change_password_page.dart';

class VerificationCodePage extends StatefulWidget {
  final String email;
  const VerificationCodePage({super.key, required this.email});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final TextEditingController _codeController = TextEditingController();

  Future<void> _validarYPasar() async {
    var doc = await FirebaseFirestore.instance
        .collection('recuperaciones')
        .doc(widget.email)
        .get();

    if (doc.exists && doc.data()?['codigo'] == _codeController.text.trim()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordPage(email: widget.email),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Código incorrecto")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verificar Código")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Ingresa el código enviado a ${widget.email}"),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validarYPasar,
              child: const Text("Validar"),
            ),
          ],
        ),
      ),
    );
  }
}
