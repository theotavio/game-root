import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/produto_modelo.dart';
import '../../core/constants/rotas_app.dart';
import '../../core/utils/formatadores.dart';
import '../../providers/autenticacao_provedor.dart';
import '../../providers/produto_provedor.dart';
import '../../widgets/barra_pesquisa.dart';

class TelaProdutos extends StatelessWidget{
  const TelaProdutos({super.key});

  @override
  Widget build(BuildContext context){
    final vendedor = context.watch<AutenticacaoProvedor>().vendedorLogado;
    if(vendedor == null || !vendedor.podeGerenciarProdutos)
      return Scaffold(
        appBar: AppBar(title: const Text('Produtos')),
        body:
            const Center(child: Text('Apenas vendedores nível A podem acessar esta tela.')),
      );

    final produtoProvedor = context.watch<ProdutoProvedor>();

    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(RotasApp.formularioProduto),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: BarraPesquisa(
              dica: 'Pesquisar produto pelo nome',
              aoMudar: produtoProvedor.pesquisar,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: produtoProvedor.produtosFiltrados.length,
              itemBuilder: (context, indice) {
                final produto = produtoProvedor.produtosFiltrados[indice];
                return _CartaoProduto(produto: produto);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoProduto extends StatelessWidget{
  final ProdutoModelo produto;
  const _CartaoProduto({required this.produto});

  @override
  Widget build(BuildContext context){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: produto.urlFoto != null
              ? CachedNetworkImage(
                  imageUrl: produto.urlFoto!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover)
              : Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.videogame_asset)),
        ),
        title: Text(produto.nome),
        subtitle: Text(
            'Código ${produto.codigo} · Estoque ${produto.quantidadeEstoque} · ${Formatadores.formatarMoeda(produto.valorUnitario)}'),
        trailing: PopupMenuButton<String>(
          onSelected: (opcao) {
            if(opcao == 'editar')
              Navigator.of(context).pushNamed(RotasApp.formularioProduto, arguments: produto);
            else if(opcao == 'excluir')
              _confirmarExclusao(context);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(value: 'excluir', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context){
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Deseja realmente excluir "${produto.nome}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<ProdutoProvedor>().excluirProduto(produto.codigo);
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}