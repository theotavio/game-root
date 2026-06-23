import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/produto_modelo.dart';
import '../models/cliente_modelo.dart';
import '../models/item_venda_modelo.dart';
import '../models/venda_modelo.dart';
import '../services/firestore_servico.dart';
import '../services/localizacao_servico.dart';

class VendaProvedor extends ChangeNotifier{
  final FirestoreServico _firestoreServico = FirestoreServico();
  final LocalizacaoServico _localizacaoServico = LocalizacaoServico();

  ClienteModelo? clienteSelecionado;
  final List<ItemVendaModelo> itensCarrinho = [];
  bool finalizandoVenda = false;
  String? mensagemErro;

  double get valorTotal => itensCarrinho.fold(0, (soma, item) => soma + item.valorTotal);

  void selecionarCliente(ClienteModelo cliente){
    clienteSelecionado = cliente;
    notifyListeners();
  }

  void adicionarProduto(ProdutoModelo produto, int quantidade){
    final indice = itensCarrinho.indexWhere((i) => i.produto.codigo == produto.codigo);

    if(indice >= 0)
      itensCarrinho[indice].quantidade += quantidade;
    else
      itensCarrinho.add(ItemVendaModelo(produto: produto, quantidade: quantidade));
    notifyListeners();
  }

  void removerProduto(String codigoProduto){
    itensCarrinho.removeWhere((i) => i.produto.codigo == codigoProduto);
    notifyListeners();
  }

  void cancelarVenda(){
    itensCarrinho.clear();
    clienteSelecionado = null;
    notifyListeners();
  }

  Future<bool> finalizarVenda(String vendedorId) async{
    if(clienteSelecionado == null){
      mensagemErro = 'Selecione um cliente';
      notifyListeners();
      return false;
    }
    if(itensCarrinho.isEmpty){
      mensagemErro = 'Adicione ao menos um produto';
      notifyListeners();
      return false;
    }

    finalizandoVenda = true;
    notifyListeners();
    try{
      final posicao = await _localizacaoServico.obterPosicaoAtual();
      final venda = VendaModelo(
        id: const Uuid().v4(),
        clienteId: clienteSelecionado!.id,
        nomeCliente: clienteSelecionado!.nome,
        vendedorId: vendedorId,
        itens: List.of(itensCarrinho),
        latitude: posicao.latitude,
        longitude: posicao.longitude,
      );
      await _firestoreServico.registrarVenda(venda);
      cancelarVenda();
      return true;
    }catch (e){
      mensagemErro = e.toString();
      return false;
    }finally{
      finalizandoVenda = false;
      notifyListeners();
    }
  }
}