import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para crear la cuenta
import 'package:cloud_firestore/cloud_firestore.dart'; // Para guardar datos adicionales
import 'dart:ui';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Controladores para capturar el texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController();

  // Función para mostrar el popup de error con animación y fondo oscurecido
  void _showErrorPopup(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 15),
                  const Text(
                    '¡Atención!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: child,
        );
      },
    );
  }

  // Lógica de registro real con Firebase
  Future<void> _handleRegister() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String pass = _passwordController.text;
    String confirmPass = _confirmPasswordController.text;
    String deviceId = _deviceIdController.text.trim();

    // 1. Validaciones locales básicas
    if (name.isEmpty || email.isEmpty || pass.isEmpty || deviceId.isEmpty) {
      _showErrorPopup('Por favor, completa todos los campos obligatorios (*).');
      return;
    }
    if (pass != confirmPass) {
      _showErrorPopup('Las contraseñas no coinciden.');
      return;
    }
    if (pass.length < 6) {
      _showErrorPopup('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    try {
      // 2. CREAR USUARIO EN FIREBASE AUTH
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      // 3. ENVIAR CORREO DE VERIFICACIÓN
      await userCredential.user?.sendEmailVerification();

      // 4. GUARDAR DATOS EN FIRESTORE
      // Usamos el UID único de Firebase para identificar al usuario en la base de datos
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user?.uid)
          .set({
            'nombre': name,
            'email': email,
            'dispositivo_id': deviceId,
            'fecha_creacion': DateTime.now(),
            'verificado': false,
          });

      // 5. Mostrar pantalla de éxito/espera de verificación
      _showVerificationScreen();
    } on FirebaseAuthException catch (e) {
      // Errores específicos de Firebase
      if (e.code == 'weak-password') {
        _showErrorPopup('La contraseña es muy débil.');
      } else if (e.code == 'email-already-in-use') {
        _showErrorPopup('Este correo ya está registrado.');
      } else if (e.code == 'invalid-email') {
        _showErrorPopup('El formato del correo es inválido.');
      } else {
        _showErrorPopup('Error: ${e.message}');
      }
    } catch (e) {
      _showErrorPopup('Ocurrió un error inesperado: $e');
    }
  }

  void _showVerificationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VerificationPendingScreen(email: _emailController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ingresa tus datos para registrarte en VitalTrack.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildTextField("Nombre Completo *", _nameController, Icons.person),
            _buildTextField(
              "Correo Electrónico *",
              _emailController,
              Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              "Identificador de Dispositivo *",
              _deviceIdController,
              Icons.watch,
              hint: "Ej: Reloj_Karol (Para separar tus datos)",
            ),
            _buildTextField(
              "Contraseña *",
              _passwordController,
              Icons.lock,
              isPassword: true,
            ),
            _buildTextField(
              "Confirmar Contraseña *",
              _confirmPasswordController,
              Icons.lock_reset,
              isPassword: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed:
                    _handleRegister, // Llamamos a la función asíncrona corregida
                child: const Text(
                  'Registrarse',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class VerificationPendingScreen extends StatelessWidget {
  final String email;
  const VerificationPendingScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 100,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 20),
              const Text(
                "¡Casi listo!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Hemos enviado un enlace de verificación a $email. Por favor, revisa tu bandeja de entrada y confirma tu cuenta antes de intentar entrar.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false),
                child: const Text("Ir al Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
