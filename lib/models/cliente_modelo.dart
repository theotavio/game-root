class ClienteModelo{
  final String id;
  final String nome;
  final String dataNascimento;
  final String cpf;
  final String telefone;
  final String email;

  ClienteModelo({
    required this.id,
    required this.nome,
    required this.dataNascimento,
    required this.cpf,
    required this.telefone,
    required this.email,
  });

  Map<String, dynamic> paraMapa() => {
    'id': id,
    'nome': nome,
    'dataNascimento': dataNascimento,
    'cpf': cpf,
    'telefone': telefone,
    'email': email,
  };

  factory ClienteModelo.deMapa(Map<String, dynamic> mapa) => ClienteModelo(
    id: mapa['id'],
    nome: mapa['nome'],
    dataNascimento: mapa['dataNascimento'],
    cpf: mapa['cpf'],
    telefone: mapa['telefone'],
    email: mapa['email'],
  );

  ClienteModelo copiarCom({
    String? nome,
    String? dataNascimento,
    String? cpf,
    String? telefone,
    String? email,
  }){
    return ClienteModelo(
      id: id,
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
    );
  }
}