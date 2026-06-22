import 'package:flutter/material.dart';

class CoresApp{
  CoresApp._();

  static const Color roxoPrimario = Color(0xFF7C5CFC);
  static const Color cianoSecundario = Color(0xFF2EE6D6);
  static const Color coralDestaque = Color(0xFFFF6B6B);
  static const Color verdeSucesso = Color(0xFF4CD787);
  static const Color vermelhoErro = Color(0xFFFF5252);
  static const Color amareloAlerta = Color(0xFFFFC857);
  static const Color fundoClaro = Color(0xFFF7F8FC);
  static const Color superficie = Color(0xFFEFEAFE);
  static const Color textoPrincipal = Color(0xFF1E1B33);
  static const Color textoSecundario = Color(0xFF6E6A85);
  static const Color bordaSuave = Color(0xFFE1DEF5);

  static const LinearGradient gradientePrincipal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [roxoPrimario, cianoSecundario],
  );
}