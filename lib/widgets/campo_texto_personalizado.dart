import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoTextoPersonalizado extends StatelessWidget{
  final TextEditingController controlador;
  final String rotulo;
  final bool obscurecer;
  final Widget? sufixo;
  final TextInputType? tipoTeclado;
  final int linhas;
  final String? Function(String?)? validador;
  final List<TextInputFormatter>? inputFormatters;

  const CampoTextoPersonalizado({
    super.key,
    required this.controlador,
    required this.rotulo,
    this.obscurecer = false,
    this.sufixo,
    this.tipoTeclado,
    this.linhas = 1,
    this.validador,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context){
    return TextFormField(
      controller: controlador,
      obscureText: obscurecer,
      keyboardType: tipoTeclado,
      maxLines: obscurecer ? 1 : linhas,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(labelText: rotulo, suffixIcon: sufixo),
      validator: validador,
    );
  }
}