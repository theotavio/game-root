import 'package:flutter/material.dart';

class CampoTextoPersonalizado extends StatelessWidget{
  final TextEditingController controlador;
  final String rotulo;
  final bool obscurecer;
  final Widget? sufixo;
  final TextInputType? tipoTeclado;
  final int linhas;
  final String? Function(String?)? validador;

  const CampoTextoPersonalizado({
    super.key,
    required this.controlador,
    required this.rotulo,
    this.obscurecer = false,
    this.sufixo,
    this.tipoTeclado,
    this.linhas = 1,
    this.validador,
  });

  @override
  Widget build(BuildContext context){
    return TextFormField(
      controller: controlador,
      obscureText: obscurecer,
      keyboardType: tipoTeclado,
      maxLines: obscurecer ? 1 : linhas,
      decoration: InputDecoration(labelText: rotulo, suffixIcon: sufixo),
      validator: validador,
    );
  }
}