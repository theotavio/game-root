import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vendedor_modelo.dart';
import '../services/autenticacao_servico.dart';
import '../services/firestore_servico.dart';
import '../services/biometria_servico.dart';
import '../services/preferencias_servico.dart';

class AutenticacaoProvedor extends ChangeNotifier{
  final AutenticacaoServico _autenticacaoServico = AutenticacaoServico();
  final FirestoreServico _firestoreServico = FirestoreServico();
  final BiometriaServico _biometriaServico = BiometriaServico();
  final PreferenciasServico _preferenciasServico = PreferenciasServico();

  VendedorModelo? vendedorLogado;
  bool carregando = false;
  String? mensagemErro;

  Future<bool> entrarComUsuarioESenha(String usuario, String senha) async{
    _iniciarCarregamento();

    try{
      final credencial = await _autenticacaoServico.entrarComUsuarioESenha(
        nomeUsuario: usuario,
        senha: senha,
      );
      await _carregarVendedor(credencial.user!.uid);
      return true;
    }on FirebaseAuthException catch (e){
      mensagemErro = _traduzirErroFirebase(e.code);
      return false;
    }catch(e){
      mensagemErro = e.toString();
      return false;
    }finally{
      _finalizarCarregamento();
    }
  }

  Future<bool> entrarComBiometria() async{
    final disponivel = await _biometriaServico.dispositivoSuportaBiometria();
    if(!disponivel){
      mensagemErro = 'Biometria não disponível neste aparelho';
      notifyListeners();
      return false;
    }

    final autenticado = await _biometriaServico.autenticar();
    if(!autenticado){
      mensagemErro = 'Não foi possível confirmar sua identidade';
      notifyListeners();
      return false;
    }

    final usuario = _autenticacaoServico.usuarioAtual;
    if(usuario == null){
      mensagemErro = 'Faça login com usuário e senha ao menos uma vez antes de usar a biometria';
      notifyListeners();
      return false;
    }

    await _carregarVendedor(usuario.uid);
    notifyListeners();
    return true;
  }

  Future<bool> cadastrarVendedor({
    required String nomeUsuario,
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required NivelVendedor nivel,
  }) async{
    _iniciarCarregamento();

    try{
      final credencial = await _autenticacaoServico.cadastrarVendedor(email: email, senha: senha);
      vendedorLogado = await _firestoreServico.criarVendedor(
        uidAuth: credencial.user!.uid,
        nomeUsuario: nomeUsuario,
        nome: nome,
        email: email,
        telefone: telefone,
        nivel: nivel,
      );
      return true;
    }on FirebaseAuthException catch(e){
      mensagemErro = _traduzirErroFirebase(e.code);
      return false;
    }finally{
      _finalizarCarregamento();
    }
  }

  Future<bool> enviarRecuperacaoSenha(String usuarioOuEmail) async{
    _iniciarCarregamento();

    try{
      await _autenticacaoServico.enviarEmailRecuperacaoSenha(usuarioOuEmail);
      return true;
    } catch(e){
      mensagemErro = e.toString();
      return false;
    }finally{
      _finalizarCarregamento();
    }
  }

  Future<void> alternarLoginBiometrico(bool ativo) async{
    if(vendedorLogado == null) 
      return;
    
    final uid = _autenticacaoServico.usuarioAtual?.uid;
    if(uid == null)
      return;
    
    await _preferenciasServico.definirBiometriaAtiva(ativo);
    await _firestoreServico.atualizarPreferenciaBiometria(uid, ativo);
    vendedorLogado = vendedorLogado!.copiarCom(loginBiometricoAtivo: ativo);
    notifyListeners();
  }

  Future<void> sair() async{
    await _autenticacaoServico.sair();
    vendedorLogado = null;
    notifyListeners();
  }

  Future<void> _carregarVendedor(String uid) async{
    vendedorLogado = await _firestoreServico.buscarVendedorPorUid(uid);
  }

  void _iniciarCarregamento(){
    carregando = true;
    mensagemErro = null;
    notifyListeners();
  }

  void _finalizarCarregamento(){
    carregando = false;
    notifyListeners();
  }

  String _traduzirErroFirebase(String codigo){
    switch(codigo){
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Usuário ou senha incorretos';
      case 'email-already-in-use':
        return 'Já existe um vendedor com este e-mail';
      case 'weak-password':
        return 'Senha muito fraca';
      default:
        return 'Erro de autenticação ($codigo)';
    }
  }
}