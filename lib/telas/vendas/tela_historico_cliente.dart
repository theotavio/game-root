import 'package:flutter/material.dart';
import '../../models/cliente_modelo.dart';
import '../../core/utils/formatadores.dart';
import '../../services/firestore_servico.dart';

class TelaHistoricoCliente extends StatefulWidget {
  final ClienteModelo cliente;
  const TelaHistoricoCliente({super.key, required this.cliente});

  @override
  State<TelaHistoricoCliente> createState() => _TelaHistoricoClienteState();
}

class _TelaHistoricoClienteState extends State<TelaHistoricoCliente> {
  final FirestoreServico _servico = FirestoreServico();
  late Future<List<Map<String, dynamic>>> _futuroVendas;

  @override
  void initState() {
    super.initState();
    _futuroVendas = _servico.buscarVendasPorCliente(widget.cliente.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compras de ${widget.cliente.nome.split(' ').first}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futuroVendas,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if(snapshot.hasError)
            return Center(child: Text('Erro: ${snapshot.error}'));
          final vendas = snapshot.data ?? [];
          if(vendas.isEmpty)
            return const Center(
              child: Text('Este cliente ainda não realizou compras.'),
            );
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vendas.length,
            itemBuilder: (context, i) {
              final venda = vendas[i];
              final itens = (venda['itens'] as List<dynamic>?) ?? [];
              final total =
                  (venda['valorTotalVenda'] as num?)?.toDouble() ?? 0;
              final dataStr = venda['realizadaEm'] as String? ?? '';
              final data = DateTime.tryParse(dataStr);
              final dataFormatada = data != null
                  ? '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}  ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}'
                  : 'Data desconhecida';
              final endereco =
                  venda['enderecoAproximado'] as String? ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text(
                    Formatadores.formatarMoeda(total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dataFormatada),
                      if (endereco.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 13, color: Colors.grey),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  endereco,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  children: itens.map((item){
                    final nome = item['nomeProduto'] ?? '';
                    final qtd = item['quantidade'] ?? 0;
                    final valorUnit = (item['valorUnitario'] as num?)?.toDouble() ?? 0;
                    final valorTotal = (item['valorTotal'] as num?)?.toDouble() ?? 0;
                    return ListTile(
                      dense: true,
                      title: Text(nome),
                      subtitle: Text(
                          '${qtd}x ${Formatadores.formatarMoeda(valorUnit)}'),
                      trailing: Text(
                        Formatadores.formatarMoeda(valorTotal),
                        style:
                            const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}