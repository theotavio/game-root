import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cliente_modelo.dart';
import '../../core/constants/rotas_app.dart';
import '../../core/utils/formatadores.dart';
import '../../providers/cliente_provedor.dart';

class TelaClientes extends StatelessWidget{
  const TelaClientes({super.key});

  @override
  Widget build(BuildContext context){
    final clientes = context.watch<ClienteProvedor>().clientes;

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(RotasApp.formularioClientes),
        child: const Icon(Icons.person_add_alt),
      ),
      body: ListView.builder(
        itemCount: clientes.length,
        itemBuilder: (context, indice){
          final cliente = clientes[indice];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                  child: Text(cliente.nome.substring(0, 1).toUpperCase())),
              title: Text(cliente.nome),
              subtitle: Text(
                  'CPF ${Formatadores.formatarCpf(cliente.cpf)} · ${Formatadores.formatarTelefone(cliente.telefone)}'),
              trailing: PopupMenuButton<String>(
                onSelected: (opcao){
                  if(opcao == 'editar')
                    Navigator.of(context).pushNamed(RotasApp.formularioClientes, arguments: cliente);
                  else if(opcao == 'excluir')
                    _confirmarExclusao(context, cliente);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'editar', child: Text('Editar')),
                  PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, ClienteModelo cliente){
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: Text('Deseja realmente excluir "${cliente.nome}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<ClienteProvedor>().excluirCliente(cliente.id);
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}