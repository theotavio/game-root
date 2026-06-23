import 'package:flutter/foundation.dart';
import '../models/produto_modelo.dart';
import '../services/firestore_servico.dart';

class ProdutoProvedor extends ChangeNotifier{
  final FirestoreServico _servico = FirestoreServico();

  List<ProdutoModelo> produtos = [];
  String termoPesquisa = '';

  ProdutoProvedor(){
    _servico.ouvirProdutos().listen((lista){
      produtos = lista;
      notifyListeners();
    });
  }

  List<ProdutoModelo> get produtosFiltrados{
    if(termoPesquisa.trim().isEmpty) 
      return produtos;

    final termo = termoPesquisa.toLowerCase();
    return produtos.where((p) => p.nome.toLowerCase().contains(termo)).toList();
  }

  void pesquisar(String termo){
    termoPesquisa = termo;
    notifyListeners();
  }

  Future<void> criarProduto({
    required String nome,
    required String descricao,
    String? urlFoto,
    required int quantidadeEstoque,
    required double valorUnitario,
    required String plataforma,
  }) {
    return _servico.criarProduto(
      nome: nome,
      descricao: descricao,
      urlFoto: urlFoto,
      quantidadeEstoque: quantidadeEstoque,
      valorUnitario: valorUnitario,
      plataforma: plataforma,
    );
  }

  Future<void> atualizarProduto(ProdutoModelo produto) => _servico.atualizarProduto(produto);

  Future<void> excluirProduto(String codigo) => _servico.excluirProduto(codigo);
}