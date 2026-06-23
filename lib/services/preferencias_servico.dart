import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasServico{
  static const _chaveBiometria = 'login_biometrico_ativo';

  Future<bool> obterBiometriaAtiva() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveBiometria) ?? false;
  }

  Future<void> definirBiometriaAtiva(bool ativo) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveBiometria, ativo);
  }
}