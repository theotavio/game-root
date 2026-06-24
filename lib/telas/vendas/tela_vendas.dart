import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cliente_modelo.dart';
import '../../models/produto_modelo.dart';
import '../../core/utils/formatadores.dart';
import '../../providers/autenticacao_provedor.dart';
import '../../providers/cliente_provedor.dart';
import '../../providers/produto_provedor.dart';
import '../../providers/venda_provedor.dart';
import '../../widgets/barra_pesquisa.dart';

class TelaVendas extends StatefulWidget{
  const TelaVendas({super.key});

  @override
  State<TelaVendas> createState() => _TelaVendasState();
}

class _TelaVendasState extends State<TelaVendas>{
  String _termoPesquisa = '';

  Future<void> _escolherCliente() async{
    final clientes = context.read<ClienteProvedor>().clientes;
    final escolhido = await showModalBottomSheet<ClienteModelo>(
      context: context,
      builder: (_) => ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Selecione o cliente',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ...clientes.map((c) => ListTile(
                leading: CircleAvatar(
                    child: Text(c.nome.substring(0, 1).toUpperCase())),
                title: Text(c.nome),
                subtitle: Text(Formatadores.formatarCpf(c.cpf)),
                onTap: () => Navigator.pop(context, c),
              )),
        ],
      ),
    );
    if(escolhido != null && mounted)
      context.read<VendaProvedor>().selecionarCliente(escolhido);
  }

  Future<void> _adicionarProduto(ProdutoModelo produto) async{
    final controlador = TextEditingController(text: '1');
    final quantidade = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(produto.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estoque disponível: ${produto.quantidadeEstoque}'),
            const SizedBox(height: 12),
            TextField(
              controller: controlador,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controlador.text) ?? 1),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if(quantidade != null && quantidade > 0 && mounted){
      if(quantidade > produto.quantidadeEstoque){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Quantidade maior que o estoque disponível')));
        return;
      }
      context.read<VendaProvedor>().adicionarProduto(produto, quantidade);
    }
  }

  Future<void> _finalizarVenda() async{
    final vendedorId = context.read<AutenticacaoProvedor>().vendedorLogado?.id;
    if(vendedorId == null) 
      return;

    final sucesso = await context.read<VendaProvedor>().finalizarVenda(vendedorId);
    if(!mounted) 
      return;
    final provedor = context.read<VendaProvedor>();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sucesso
          ? 'Venda registrada com sucesso!'
          : provedor.mensagemErro ?? 'Erro ao finalizar venda'),
    ));
  }

  @override
  Widget build(BuildContext context){
    final todosProdutos = context.watch<ProdutoProvedor>().produtos;
    final produtosFiltrados = _termoPesquisa.isEmpty
        ? todosProdutos
        : todosProdutos
            .where((p) => p.nome.toLowerCase().contains(_termoPesquisa.toLowerCase())).toList();
    final venda = context.watch<VendaProvedor>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova venda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Cancelar venda',
            onPressed: venda.itensCarrinho.isEmpty
                ? null
                : () => context.read<VendaProvedor>().cancelarVenda(),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(venda.clienteSelecionado?.nome ?? 'Selecione o cliente'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _escolherCliente,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: BarraPesquisa(
              dica: 'Pesquisar produto',
              aoMudar: (texto) => setState(() => _termoPesquisa = texto),
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: produtosFiltrados.length,
              itemBuilder: (_, i) {
                final produto = produtosFiltrados[i];
                return GestureDetector(
                  onTap: () => _adicionarProduto(produto),
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: produto.urlFoto != null
                              ? Image.network(produto.urlFoto!,
                                  fit: BoxFit.cover)
                              : const Icon(Icons.videogame_asset_outlined,
                                  size: 40),
                        ),
                        Text(produto.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12)),
                        Text(Formatadores.formatarMoeda(produto.valorUnitario),
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: venda.itensCarrinho.isEmpty
                ? const Center(child: Text('Nenhum item adicionado'))
                : ListView.builder(
                    itemCount: venda.itensCarrinho.length,
                    itemBuilder: (_, i) {
                      final item = venda.itensCarrinho[i];
                      return ListTile(
                        title: Text(item.produto.nome),
                        subtitle: Text(
                            '${item.quantidade}x ${Formatadores.formatarMoeda(item.produto.valorUnitario)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Formatadores.formatarMoeda(item.valorTotal),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () => context
                                  .read<VendaProvedor>()
                                  .removerProduto(item.produto.codigo),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border(top: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total: ${Formatadores.formatarMoeda(venda.valorTotal)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: venda.finalizandoVenda ? null : _finalizarVenda,
                  child: venda.finalizandoVenda
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Finalizar venda'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}