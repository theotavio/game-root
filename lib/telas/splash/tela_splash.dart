import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants/cores_app.dart';
import '../../core/constants/rotas_app.dart';

class TelaSplash extends StatefulWidget{
  const TelaSplash({super.key});

  @override
  State<TelaSplash> createState() => _TelaSplashState();
}

class _TelaSplashState extends State<TelaSplash> with SingleTickerProviderStateMixin{
  final AudioPlayer _player = AudioPlayer();
  late final AnimationController _controller;

  @override
  void initState(){
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _tocarSomEIniciar();
  }

  Future<void> _tocarSomEIniciar() async{
    try{
      await _player.play(AssetSource('sounds/som_abertura.mp3'));
    }catch(_){}
      await Future.delayed(const Duration(seconds: 3));
      
      if(mounted) 
        Navigator.of(context).pushReplacementNamed(RotasApp.login);
  }

  @override
  void dispose(){
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: CoresApp.gradientePrincipal),
        child: Center(
          child: FadeTransition(
            opacity: _controller,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/logo_gameroot.svg', 
                  width: 140, 
                  height: 140,
                ),
                const SizedBox(height: 20),
                const Text(
                  'GameRoot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gestão de vendas de jogos',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}