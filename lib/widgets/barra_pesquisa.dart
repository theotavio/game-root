import 'package:flutter/material.dart';

class BarraPesquisa extends StatelessWidget{
  final String dica;
  final ValueChanged<String> aoMudar;

  const BarraPesquisa({super.key, required this.dica, required this.aoMudar});

  @override
  Widget build(BuildContext context){
    return TextField(
      onChanged: aoMudar,
      decoration: InputDecoration(
        hintText: dica,
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}