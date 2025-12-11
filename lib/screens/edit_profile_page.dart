import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: 'Karol Martínez');
    final userController = TextEditingController(text: '@kydzam');
    final emailController = TextEditingController(
      text: 'testdecorreo@gmail.com',
    );
    final birthController = TextEditingController(text: '01/06/2005');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF7DC3DE),
              child: Icon(Icons.person, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 15),

            const Text(
              'Karol Martínez',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('@kydzam', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),

            _ProfileField(
              label: 'Nombre y Apellido',
              controller: nameController,
            ),
            _ProfileField(
              label: 'Nombre de Usuario',
              controller: userController,
            ),
            _ProfileField(
              label: 'Correo Electrónico',
              controller: emailController,
            ),
            _ProfileField(label: 'Date of Birth', controller: birthController),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7DC3DE),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text(
                'Actualizar Perfil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ProfileField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE5F4FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
