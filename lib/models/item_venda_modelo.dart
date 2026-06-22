import 'produto_modelo.dart';

class ItemVendaModelo{
  final ProdutoModelo produto;
  int quantidade;

  ItemVendaModelo({
    required this.produto,
    required this.quantidade,
  });

  double get valorTotal => produto.valorUnitario * quantidade;

  Map<String, dynamic> paraMapa() => {
    'codigoProduto': produto.codigo,
    'nomeProduto': produto.nome,
    'quantidade': quantidade,
    'valorUnitario': produto.valorUnitario,
    'valorTotal': valorTotal,
  };
}