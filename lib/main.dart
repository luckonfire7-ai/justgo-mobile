import 'package:flutter/material.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const JustGoApp());
}

// Palet warna identitas JustGo - hitam/putih/oranye ala KTM
class JustGoColors {
  static const orange = Color(0xFFFF6A00);
  static const black = Color(0xFF121212);
  static const surfaceDark = Color(0xFF1C1C1C);
  static const surfaceDarker = Color(0xFF161616);
  static const border = Color(0xFF2A2A2A);
  static const white = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF9A9A9A);
  static const danger = Color(0xFFE02424);
}

class JustGoApp extends StatelessWidget {
  const JustGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JustGo',
      debugShowCheckedModeBanner: false,
      // Dark theme permanen untuk mode riding - bukan opsional.
      // Alasan: kontras lebih baik di bawah sinar matahari langsung,
      // dan lebih hemat baterai saat layar menyala berjam-jam saat touring.
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: JustGoColors.black,
        colorScheme: const ColorScheme.dark(
          primary: JustGoColors.orange,
          secondary: JustGoColors.orange,
          surface: JustGoColors.surfaceDark,
          onPrimary: JustGoColors.black,
          onSurface: JustGoColors.white,
          error: JustGoColors.danger,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: JustGoColors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: JustGoColors.orange,
            foregroundColor: JustGoColors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: JustGoColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: JustGoColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: JustGoColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: JustGoColors.orange, width: 1.5),
          ),
          labelStyle: const TextStyle(color: JustGoColors.textMuted),
        ),
        cardTheme: const CardThemeData(
          color: JustGoColors.surfaceDark,
          elevation: 0,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: JustGoColors.orange,
          unselectedLabelColor: JustGoColors.textMuted,
          indicatorColor: JustGoColors.orange,
        ),
      ),
      home: const RegisterScreen(),
    );
  }
}
