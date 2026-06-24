import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferenciasServico{
  static const _chaveBiometria = 'login_biometrico_ativo';
  static const _chaveEmail = 'biometria_email';
  static const _chaveSenha = 'biometria_senha';

  final _storage = const FlutterSecureStorage();

  Future<bool> obterBiometriaAtiva() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveBiometria) ?? false;
  }

  Future<void> definirBiometriaAtiva(
    bool ativo, {
    String? email,
    String? senha,
  }) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveBiometria, ativo);
    if(ativo && email != null && senha != null){
      await _storage.write(key: _chaveEmail, value: email);
      await _storage.write(key: _chaveSenha, value: senha);
    }else if(!ativo){
      await _storage.delete(key: _chaveEmail);
      await _storage.delete(key: _chaveSenha);
    }
  }

  Future<({String email, String senha})?> obterCredenciaisBiometria() async {
    final email = await _storage.read(key: _chaveEmail);
    final senha = await _storage.read(key: _chaveSenha);

    if(email == null || senha == null) 
      return null;
    return (email: email, senha: senha);
  }
}