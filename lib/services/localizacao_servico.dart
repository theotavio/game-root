import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  Future<String> obterEnderecoAproximado(double latitude, double longitude) async{
    try{
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if(placemarks.isEmpty) 
        return '$latitude, $longitude';

      final p = placemarks.first;

      final partes = [
        p.street,
        p.subLocality,  
        p.locality,     
        p.administrativeArea, 
      ].where((parte) => parte != null && parte.isNotEmpty).toList();

      return partes.isNotEmpty
          ? partes.join(', ')
          : '$latitude, $longitude';
    }catch (_){
      return '$latitude, $longitude';
    }
  }

  Future<({Position posicao, String endereco})> obterPosicaoEEndereco() async{
    final posicao = await obterPosicaoAtual();
    final endereco = await obterEnderecoAproximado(
      posicao.latitude,
      posicao.longitude,
    );
    return (posicao: posicao, endereco: endereco);
  }
}