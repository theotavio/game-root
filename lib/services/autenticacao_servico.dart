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
  }){
    return _auth.createUserWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> enviarEmailRecuperacaoSenha(String email){
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sair() => _auth.signOut();

  Future<User?> aguardarUsuarioAtual() async{
  if(_auth.currentUser != null) 
    return _auth.currentUser;
  
  return await _auth
      .authStateChanges()
      .where((u) => u != null)
      .first
      .timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
}
}