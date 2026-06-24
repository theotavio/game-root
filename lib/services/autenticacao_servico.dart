import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoServico{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get mudancasDeUsuario => _auth.authStateChanges();
  User? get usuarioAtual => _auth.currentUser;

  Future<UserCredential> entrarComEmailESenha({
    required String email,
    required String senha,
  }){
    return _auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  Future<UserCredential> cadastrarVendedor({
    required String email,
    required String senha,
  }) {
    return _auth.createUserWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> enviarEmailRecuperacaoSenha(String email){
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sair() => _auth.signOut();
}