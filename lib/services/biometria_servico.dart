import 'package:local_auth/local_auth.dart';

class BiometriaServico{
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> dispositivoSuportaBiometria() async{
    return await _auth.isDeviceSupported();
  }

  Future<List<BiometricType>> tiposDisponiveis(){
    return _auth.getAvailableBiometrics();
  }

  Future<bool> autenticar({
    String motivo = 'Confirme sua identidade para entrar no GameRoot',
  }) async{
    try{
      return await _auth.authenticate(
        localizedReason: motivo,
          biometricOnly: true,
          persistAcrossBackgrounding: true,
      );
    }catch(_){
      return false;
    }
  }
}