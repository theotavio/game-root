import 'package:flutter/material.dart';

class BotaoPersonalizado extends StatelessWidget{
  final String texto;
  final bool carregando;
  final VoidCallback aoPressionar;

  const BotaoPersonalizado({
    super.key,
    required this.texto,
    required this.aoPressionar,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: carregando ? null : aoPressionar,
        child: carregando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(texto),
      ),
    );
  }
}