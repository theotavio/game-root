import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AutenticacaoServico{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get mudancasDeUsuario => _auth.authStateChanges();
  User? get usuarioAtual => _auth.currentUser;

  Future<String> _buscarEmailPorNomeUsuario(String nomeUsuario) async{
    final consulta = await _firestore.collection('vendedores').where('nomeUsuario', isEqualTo: nomeUsuario.trim().toLowerCase()).limit(1).get();
    if(consulta.docs.isEmpty) 
      throw Exception('Usuário não encontrado');
    return consulta.docs.first.data()['email'] as String;
  }

  Future<UserCredential> entrarComUsuarioESenha({
    required String nomeUsuario,
    required String senha,
  }) async{
    final email = await _buscarEmailPorNomeUsuario(nomeUsuario);
    return _auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  Future<UserCredential> cadastrarVendedor({
    required String email,
    required String senha,
  }){
    return _auth.createUserWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> enviarEmailRecuperacaoSenha(String nomeUsuarioOuEmail) async{
    String email = nomeUsuarioOuEmail;
    if(!nomeUsuarioOuEmail.contains('@'))
      email = await _buscarEmailPorNomeUsuario(nomeUsuarioOuEmail);
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sair() => _auth.signOut();
}