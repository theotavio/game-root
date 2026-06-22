class ProdutoModelo{
  final String codigo;
  final String nome;
  final String descricao;
  final String? urlFoto;
  final int quantidadeEstoque;
  final double valorUnitario;
  final String plataforma;
  final DateTime criadoEm;

  ProdutoModelo({
    required this.codigo,
    required this.nome,
    required this.descricao,
    this.urlFoto,
    required this.quantidadeEstoque,
    required this.valorUnitario,
    required this.plataforma,
    DateTime? criadoEm,
  }) : criadoEm = criadoEm ?? DateTime.now();

  double get valorTotalEstoque => quantidadeEstoque * valorUnitario;

  Map<String, dynamic> paraMapa() => {
    'codigo': codigo,
    'nome': nome,
    'descricao': descricao,
    'urlFoto': urlFoto,
    'quantidadeEstoque': quantidadeEstoque,
    'valorUnitario': valorUnitario,
    'plataforma': plataforma,
    'criadoEm': criadoEm.toIso8601String(),
  };

  factory ProdutoModelo.deMapa(Map<String, dynamic> mapa) => ProdutoModelo(
    codigo: mapa['codigo'], 
    nome: mapa['nome'], 
    descricao: mapa['descricao'] ?? '',
    urlFoto: mapa['urlFoto'], 
    quantidadeEstoque: mapa['quantidadeEstoque'] ?? 0, 
    valorUnitario: (mapa['valorUnitario'] as num).toDouble(), 
    plataforma: mapa['plataforma'] ?? '',
    criadoEm: DateTime.tryParse(mapa['criadoEm'] ?? '') ?? DateTime.now(),
  );

  ProdutoModelo copiarCom({
    String? nome,
    String? descricao,
    String? urlFoto,
    int? quantidadeEstoque,
    double? valorUnitario,
    String? plataforma,
  }){
    return ProdutoModelo(
      codigo: codigo,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      urlFoto: urlFoto ?? this.urlFoto,
      quantidadeEstoque: quantidadeEstoque ?? this.quantidadeEstoque,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      plataforma: plataforma ?? this.plataforma,
      criadoEm: criadoEm,
    );
  }
}