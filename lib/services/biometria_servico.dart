import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometriaServico{
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> dispositivoSuportaBiometria() async{
    final suportado = await _auth.isDeviceSupported();
    if(!suportado) 
      return false;
    final tipos = await _auth.getAvailableBiometrics();
    return tipos.isNotEmpty;
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
        biometricOnly: false,
        persistAcrossBackgrounding: true,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Autenticação necessária',
            cancelButton: 'Cancelar',
            signInHint: 'Toque no sensor',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
            localizedFallbackTitle: 'Usar senha',
          ),
        ],
      );
    }catch (_){
      return false;
    }
  }
}