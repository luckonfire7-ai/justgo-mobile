import 'package:flutter/material.dart';
import '../main.dart';
import 'motor_select_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final plateCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final registrationKeyCtrl = TextEditingController();

  void _lanjut() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MotorSelectScreen(
          name: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          plateNumber: plateCtrl.text.trim().toUpperCase(),
          password: passwordCtrl.text,
          registrationKey: registrationKeyCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 40),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: JustGoColors.white,
                    ),
                    children: [
                      TextSpan(text: 'Gabung '),
                      TextSpan(text: 'JustGo', style: TextStyle(color: JustGoColors.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Terhubung dengan teman touring, kapan saja, di mana saja.',
                  style: TextStyle(color: JustGoColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama lengkap'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: plateCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Nomor polisi',
                    hintText: 'Contoh: L 1234 ABC',
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Nopol wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: registrationKeyCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Kode undangan',
                    hintText: 'Diberikan oleh admin komunitas',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Kode undangan wajib diisi' : null,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Belum punya kode? Hubungi admin komunitas touring kamu.',
                  style: TextStyle(color: JustGoColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _lanjut,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Lanjut pilih motor'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
