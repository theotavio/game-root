import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/produto_modelo.dart';
import '../models/cliente_modelo.dart';
import '../models/vendedor_modelo.dart';
import '../models/venda_modelo.dart';
import '../core/utils/geradores_codigos.dart';

class FirestoreServico{
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _produtos => _db.collection('produtos');
  CollectionReference get _clientes => _db.collection('clientes');
  CollectionReference get _vendedores => _db.collection('vendedores');
  CollectionReference get _vendas => _db.collection('vendas');

  Future<String> _gerarCodigoProdutoUnico() async{
    String codigo;
    QuerySnapshot existente;

    do{
      codigo = GeradorCodigo.gerarCodigoProduto();
      existente = await _produtos.where('codigo', isEqualTo: codigo).limit(1).get();
    }while(existente.docs.isNotEmpty);

    return codigo;
  }

  Future<ProdutoModelo> criarProduto({
    required String nome,
    required String descricao,
    String? urlFoto,
    required int quantidadeEstoque,
    required double valorUnitario,
    required String plataforma,
  }) async{
    final codigo = await _gerarCodigoProdutoUnico();
    final produto = ProdutoModelo(
      codigo: codigo,
      nome: nome,
      descricao: descricao,
      urlFoto: urlFoto,
      quantidadeEstoque: quantidadeEstoque,
      valorUnitario: valorUnitario,
      plataforma: plataforma,
    );
    await _produtos.doc(codigo).set(produto.paraMapa());
    return produto;
  }

  Future<void> atualizarProduto(ProdutoModelo produto) => _produtos.doc(produto.codigo).update(produto.paraMapa());

  Future<void> excluirProduto(String codigo) => _produtos.doc(codigo).delete();

  Stream<List<ProdutoModelo>> ouvirProdutos(){
    return _produtos.orderBy('nome').snapshots().map((snap) => snap.docs.map((d) => ProdutoModelo.deMapa(d.data() as Map<String, dynamic>)).toList());
  }

  Future<void> darBaixaEstoque(String codigoProduto, int quantidadeVendida) async{
    final ref = _produtos.doc(codigoProduto);
    await _db.runTransaction((transacao) async{
      final doc = await transacao.get(ref);
      final estoqueAtual = (doc.data() as Map<String, dynamic>)['quantidadeEstoque'] as int;

      if(estoqueAtual < quantidadeVendida)
        throw Exception('Estoque insuficiente para o produto $codigoProduto');
      transacao.update(ref, {'quantidadeEstoque': estoqueAtual - quantidadeVendida});
    });
  }

  Future<String> _gerarIdUnico(CollectionReference colecao) async{
    String id;
    QuerySnapshot existente;

    do{
      id = GeradorCodigo.gerarIdNumerico();
      existente = await colecao.where('id', isEqualTo: id).limit(1).get();
    }while(existente.docs.isNotEmpty);

    return id;
  }

  Future<ClienteModelo> criarCliente({
    required String nome,
    required String dataNascimento,
    required String cpf,
    required String telefone,
    required String email,
  }) async{
    final id = await _gerarIdUnico(_clientes);
    final cliente = ClienteModelo(
      id: id,
      nome: nome,
      dataNascimento: dataNascimento,
      cpf: cpf,
      telefone: telefone,
      email: email,
    );
    await _clientes.doc(id).set(cliente.paraMapa());
    return cliente;
  }

  Future<void> atualizarCliente(ClienteModelo cliente) => _clientes.doc(cliente.id).update(cliente.paraMapa());

  Future<void> excluirCliente(String id) => _clientes.doc(id).delete();

  Stream<List<ClienteModelo>> ouvirClientes(){
    return _clientes.orderBy('nome').snapshots().map((snap) => snap.docs.map((d) => ClienteModelo.deMapa(d.data() as Map<String, dynamic>)).toList());
  }

  Future<VendedorModelo> criarVendedor({
    required String uidAuth,
    required String nome,
    required String email,
    required String telefone,
    required NivelVendedor nivel,
  }) async{
    final id = await _gerarIdUnico(_vendedores);
    final vendedor = VendedorModelo(
      id: id,
      nome: nome,
      email: email,
      telefone: telefone,
      nivel: nivel,
    );
    await _vendedores.doc(uidAuth).set(vendedor.paraMapa());
    return vendedor;
  }

  Future<VendedorModelo?> buscarVendedorPorUid(String uid) async{
    final doc = await _vendedores.doc(uid).get();

    if(!doc.exists) 
      return null;
    return VendedorModelo.deMapa(doc.data() as Map<String, dynamic>);
  }

  Future<void> atualizarPreferenciaBiometria(String uid, bool ativo){
    return _vendedores.doc(uid).update({'loginBiometricoAtivo': ativo});
  }

  Future<void> registrarVenda(VendaModelo venda) async{
    await _vendas.doc(venda.id).set(venda.paraMapa());
    for(final item in venda.itens)
      await darBaixaEstoque(item.produto.codigo, item.quantidade);
  }
}