class Validadores{
  Validadores._();

  static String? validarEmail(String? valor){
    if(valor == null || valor.trim().isEmpty)
      return "Informe o e-mail";
    
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if(!regex.hasMatch(valor.trim()))
      return 'E-mail inválido';
    return null;
  }

  static String? validarSenha(String? valor){
    if(valor == null || valor.isEmpty)
      return 'Informe a senha';

    if(valor.length < 6)
      return 'A senha deve ter ao menos 6 caracteres';
    
    final temNumero = RegExp(r'[0-9]').hasMatch(valor);
    final temLetra = RegExp(r'[a-zA-Z]').hasMatch(valor);

    if(!temNumero || !temLetra)
      return 'A senha deve conter letras e números';
    return null;
  }

  static String? validarTelefone(String? valor){
    if(valor == null || valor.trim().isEmpty)
      return 'Informe o telefone';
    
    final apenasDigitos = valor.replaceAll(RegExp(r'\D'), '');

    if(apenasDigitos.length < 10 || apenasDigitos.length > 11)
      return 'Telefone inválido. Use (DDD) NNNNN-NNNN';
    return null;
  }

  static String? validarDataNascimento(String? valor){
    if(valor == null || valor.trim().isEmpty)
      return 'Informe a data de nascimento';
    
    final regex = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');

    final m = regex.firstMatch(valor.trim());
    if(m == null)
      return 'Use o formato DD/MM/AAAA';
    
    final dia = int.parse(m.group(1)!);
    final mes = int.parse(m.group(2)!);
    final ano = int.parse(m.group(3)!);

    try{
      final data = DateTime(ano, mes, dia);
      if(data.day != dia || data.month != mes || data.year != ano)
        return 'Data inválida';
      
      final hoje = DateTime.now();
      if(data.isAfter(hoje))
        return 'A data não pode ser futura';
      
      int idade = hoje.year - ano;
      if(hoje.month < mes || (hoje.month == mes && hoje.day < dia))
        idade--;
      if(idade < 18 || idade > 120)
        return 'Idade fora do intervalor permitido (18 - 120)';
    }catch(_){
      return 'Data inválida';
    }
    return null;
  }

  static String? validarCpf(String? valor){
    if(valor == null || valor.trim().isEmpty)
      return 'Informe o CPF';
    
    final cpf = valor.replaceAll(RegExp(r'\D'), '');
    if(cpf.length < 11)
      return 'CPF deve ter 11 dígitos';
    if(RegExp(r'^(\d)\1{10}$').hasMatch(cpf))
      return 'CPF inválido';
    
    final numeros = cpf.split('').map(int.parse).toList();

    int calcularDigito(List<int> base){
      int soma = 0;
      int peso = base.length + 1;

      for(final n in base){
        soma += n * peso;
        peso--;
      }

      final resto = soma % 11;
      
      return resto < 2 ? 0 : 11 - resto;
    }

    final d1 = calcularDigito(numeros.sublist(0,9));
    final d2 = calcularDigito(numeros.sublist(0,10));
    if(d1 != numeros[9] || d2 != numeros[10])
      return 'CPF inválido';
    return null;
  }

  static String? validarCampoObrigatorio(String? valor, {String mensagem = 'Campo obrigatório'}){
    if(valor == null || valor.trim().isEmpty)
      return mensagem;
    return null;
  }

  static String? validarNumero(String? valor, {String mensagem = 'Informe um número válido'}){
    if(valor == null || valor.trim().isEmpty)
      return mensagem;
    if(double.tryParse(valor.replaceAll(',', '.')) == null)
      return mensagem;
    return null;
  }
}