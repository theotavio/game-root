import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/cores_app.dart';

class TemaApp {
  TemaApp._();

  static ThemeData get temaClaro{
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: CoresApp.fundoClaro,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CoresApp.roxoPrimario,
        primary: CoresApp.roxoPrimario,
        secondary: CoresApp.cianoSecundario,
        error: CoresApp.vermelhoErro,
        surface: CoresApp.superficie,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: CoresApp.textoPrincipal,
        displayColor: CoresApp.textoPrincipal,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CoresApp.fundoClaro,
        foregroundColor: CoresApp.textoPrincipal,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CoresApp.bordaSuave),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CoresApp.bordaSuave),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CoresApp.roxoPrimario, width: 1.6)
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CoresApp.roxoPrimario,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CoresApp.bordaSuave),
        ),
      ),
    );
  }
}