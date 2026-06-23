import 'dart:math';

class GeradorCodigo{
  GeradorCodigo._();

  static final Random _aleatorio = Random.secure();

  static String gerarCodigoProduto({int tamanho = 6}){
    const caracteres = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    return List.generate(tamanho, (_) => caracteres[_aleatorio.nextInt(caracteres.length)]).join();
  }

  static String gerarIdNumerico({int tamanho = 6}){
    const digitos = '0123456789';
    
    final primeiro = digitos.substring(1)[_aleatorio.nextInt(9)];
    final resto = List.generate(tamanho - 1, (_) => digitos[_aleatorio.nextInt(digitos.length)]).join();

    return '$primeiro$resto';
  }
}