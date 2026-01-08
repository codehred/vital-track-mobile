import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para gestionar la contraseña

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // 1. Controladores y estados
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final Color primaryBlue = const Color(0xFF7DC3DE);

  // 2. Función para mostrar popups de error/éxito
  void _showMessage(String message, {bool isError = true}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isError ? 'Atención' : 'Éxito'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // 3. Lógica principal de cambio de contraseña
  Future<void> _updatePassword() async {
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validaciones locales
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Por favor, completa todos los campos.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('La nueva contraseña y su confirmación no coinciden.');
      return;
    }

    if (newPassword.length < 6) {
      _showMessage('La nueva contraseña debe tener al menos 6 caracteres.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser; //
      if (user != null && user.email != null) {
        // PASO CRÍTICO: Reautenticar al usuario
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(
          credential,
        ); // Valida contraseña actual

        // PASO FINAL: Actualizar contraseña en Firebase
        await user.updatePassword(newPassword); //

        if (mounted) {
          _showMessage('Contraseña actualizada correctamente.', isError: false);
          // Limpiar campos
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Error al actualizar.';
      if (e.code == 'wrong-password')
        errorMsg = 'La contraseña actual es incorrecta.';
      if (e.code == 'weak-password')
        errorMsg = 'La nueva contraseña es muy débil.';
      _showMessage(errorMsg);
    } catch (e) {
      _showMessage('Ocurrió un error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _passwordField(
                    'Contraseña Actual',
                    _currentPasswordController,
                    _obscureCurrent,
                    () {
                      setState(() => _obscureCurrent = !_obscureCurrent);
                    },
                  ),
                  const SizedBox(height: 15),
                  _passwordField(
                    'Nueva Contraseña',
                    _newPasswordController,
                    _obscureNew,
                    () {
                      setState(() => _obscureNew = !_obscureNew);
                    },
                  ),
                  const SizedBox(height: 15),
                  _passwordField(
                    'Confirmar Nueva Contraseña',
                    _confirmPasswordController,
                    _obscureConfirm,
                    () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Actualizar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEAF6FB),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: toggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
