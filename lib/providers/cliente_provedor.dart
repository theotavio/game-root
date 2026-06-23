import 'package:flutter/foundation.dart';
import '../models/cliente_modelo.dart';
import '../services/firestore_servico.dart';

class ClienteProvedor extends ChangeNotifier{
  final FirestoreServico _servico = FirestoreServico();

  List<ClienteModelo> clientes = [];

  ClienteProvedor(){
    _servico.ouvirClientes().listen((lista){
      clientes = lista;
      notifyListeners();
    });
  }

  Future<ClienteModelo> criarCliente({
    required String nome,
    required String dataNascimento,
    required String cpf,
    required String telefone,
    required String email,
  }) {
    return _servico.criarCliente(
      nome: nome,
      dataNascimento: dataNascimento,
      cpf: cpf,
      telefone: telefone,
      email: email,
    );
  }

  Future<void> atualizarCliente(ClienteModelo cliente) => _servico.atualizarCliente(cliente);

  Future<void> excluirCliente(String id) => _servico.excluirCliente(id);
}