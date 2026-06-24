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
  bool inicializado = false; // ← novo
  String? mensagemErro;
  String? _ultimaSenhaDigitada;

  AutenticacaoProvedor(){
    _autenticacaoServico.mudancasDeUsuario.listen((usuario) async{
      if(usuario != null)
        await _carregarVendedor(usuario.uid);
      else
        vendedorLogado = null;
      inicializado = true;
      notifyListeners();
    });
  }

  Future<bool> entrarComEmailESenha(String email, String senha) async{
    _iniciarCarregamento();
    try{
      final credencial = await _autenticacaoServico.entrarComEmailESenha(
        email: email.trim(),
        senha: senha,
      );
      _ultimaSenhaDigitada = senha;
      await _carregarVendedor(credencial.user!.uid);
      return true;
    }on FirebaseAuthException catch (e){
      mensagemErro = _traduzirErroFirebase(e.code);
      return false;
    }catch (e){
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
    mensagemErro = 'Autenticação biométrica falhou';
    notifyListeners();
    return false;
  }

  final credenciais = await _preferenciasServico.obterCredenciaisBiometria();
  if(credenciais == null){
    mensagemErro = 'Configure a biometria nas configurações após fazer login.';
    notifyListeners();
    return false;
  }

  _iniciarCarregamento();
  try{
    final credencial = await _autenticacaoServico.entrarComEmailESenha(
      email: credenciais.email,
      senha: credenciais.senha,
    );
    await _carregarVendedor(credencial.user!.uid);
    return true;
  }on FirebaseAuthException catch (e){
    mensagemErro = _traduzirErroFirebase(e.code);
    return false;
  }finally{
    _finalizarCarregamento();
  }
}

  Future<bool> cadastrarVendedor({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required NivelVendedor nivel,
  }) async{
    _iniciarCarregamento();
    try{
      final credencial = await _autenticacaoServico.cadastrarVendedor(
        email: email.trim(),
        senha: senha,
      );

      await _firestoreServico.criarVendedor(
        uidAuth: credencial.user!.uid,
        nome: nome,
        email: email.trim(),
        telefone: telefone,
        nivel: nivel,
      );

      await _autenticacaoServico.sair();
      vendedorLogado = null;
      return true;
    }on FirebaseAuthException catch (e){
      mensagemErro = _traduzirErroFirebase(e.code);
      return false;
    }catch (e){
      mensagemErro = 'Erro ao cadastrar: ${e.toString()}';
      return false;
    }finally{
      _finalizarCarregamento();
    }
  }

  Future<bool> enviarRecuperacaoSenha(String email) async{
    _iniciarCarregamento();
    try{
      await _autenticacaoServico.enviarEmailRecuperacaoSenha(email.trim());
      return true;
    }catch (e){
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

    await _preferenciasServico.definirBiometriaAtiva(
      ativo,
      email: ativo ? vendedorLogado!.email : null,
      senha: ativo ? _ultimaSenhaDigitada : null,
    );
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
    try{
      final vendedor = await _firestoreServico.buscarVendedorPorUid(uid);
      vendedorLogado = vendedor;
    }catch (e){
      vendedorLogado = null;
    }
    notifyListeners();
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
        return 'E-mail ou senha incorretos';
      case 'email-already-in-use':
        return 'Já existe um vendedor com este e-mail';
      case 'invalid-email':
        return 'E-mail inválido';
      case 'weak-password':
        return 'Senha muito fraca';
      default:
        return 'Erro de autenticação ($codigo)';
    }
  }
}