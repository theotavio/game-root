enum NivelVendedor {a, b} extension NivelVendedorExtensao on NivelVendedor{
  String get rotulo => this == NivelVendedor.a ? 'A' : 'B';

  static NivelVendedor deTexto(String texto){
    return texto.toUpperCase() == 'A' ? NivelVendedor.a : NivelVendedor.b;
  }
}

class VendedorModelo{
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final NivelVendedor nivel;
  final bool loginBiometricoAtivo;

  VendedorModelo({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.nivel,
    this.loginBiometricoAtivo = false,
  });

  bool get podeGerenciarProdutos => nivel == NivelVendedor.a;

  Map<String, dynamic> paraMapa() => {
    'id': id,
    'nome': nome,
    'email': email,
    'telefone': telefone,
    'nivel': nivel.rotulo,
    'loginBiometricoAtivo': loginBiometricoAtivo,
  };

  factory VendedorModelo.deMapa(Map<String, dynamic> mapa) => VendedorModelo(
    id: mapa['id'],
    nome: mapa['nome'],
    email: mapa['email'],
    telefone: mapa['telefone'],
    nivel: NivelVendedorExtensao.deTexto(mapa['nivel'] ?? 'B'),
    loginBiometricoAtivo: mapa['loginBiometricoAtivo'] ?? false,
  );

  VendedorModelo copiarCom({bool? loginBiometricoAtivo}){
    return VendedorModelo(
      id: id, 
      nome: nome, 
      email: email, 
      telefone: telefone, 
      nivel: nivel,
      loginBiometricoAtivo: loginBiometricoAtivo ?? this.loginBiometricoAtivo,
    );
  }
}