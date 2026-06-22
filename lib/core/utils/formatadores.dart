import 'package:intl/intl.dart';

class Formatadores{
  Formatadores._();

  static final NumberFormat _formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  static String formatarMoeda(double valor) => _formatoMoeda.format(valor);

  static String formatarCpf(String cpf){
    final d = cpf.replaceAll(RegExp(r'\D'), '');
    if(d.length != 11)
     return cpf;
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9, 11)}';
  }

  static String formatarTelefone(String telefone){
    final d = telefone.replaceAll(RegExp(r'\D'), '');
    if(d.length == 11)
      return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7, 11)}';
    else if(d.length == 10)
      return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6, 10)}';
    return telefone;
  }
}