import 'package:geolocator/geolocator.dart';

class LocalizacaoServico{
  Future<Position> obterPosicaoAtual() async{
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();

    if(!servicoAtivo)
      throw Exception('Ative o GPS para registrar a localização da venda');

    LocationPermission permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied)
        throw Exception('Permissão de localização negada');
    }
    if(permissao == LocationPermission.deniedForever)
      throw Exception('Permissão negada permanentemente. Habilite nas configurações do aparelho.');

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}