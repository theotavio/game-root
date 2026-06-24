import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/rotas_app.dart';
import '../../core/utils/formatadores.dart';
import '../../providers/cliente_provedor.dart';

class TelaHistorico extends StatelessWidget{
  const TelaHistorico({super.key});

  @override
  Widget build(BuildContext context){
    final clientes = context.watch<ClienteProvedor>().clientes;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de compras')),
      body: clientes.isEmpty
          ? const Center(child: Text('Nenhum cliente cadastrado'))
          : ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (context, i) {
                final cliente = clientes[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child:
                          Text(cliente.nome.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(cliente.nome),
                    subtitle: Text(
                        'CPF ${Formatadores.formatarCpf(cliente.cpf)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushNamed(
                      RotasApp.historicoCliente,
                      arguments: cliente,
                    ),
                  ),
                );
              },
            ),
    );
  }
}