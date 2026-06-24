import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/validadores.dart';
import '../../providers/autenticacao_provedor.dart';
import '../../widgets/campo_texto_personalizado.dart';
import '../../widgets/botao_personalizado.dart';

class TelaRecuperarSenha extends StatefulWidget{
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha>{
  final _formKey = GlobalKey<FormState>();
  final _controlador = TextEditingController();

  Future<void> _enviar() async{
    if(!_formKey.currentState!.validate()) 
      return;

    final provedor = context.read<AutenticacaoProvedor>();
    final sucesso = await provedor.enviarRecuperacaoSenha(_controlador.text.trim());
    if(!mounted) 
      return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(sucesso
          ? 'Enviamos um e-mail com instruções para redefinir sua senha'
          : provedor.mensagemErro ?? 'Não foi possível enviar o e-mail'),
    ));
    if(sucesso) 
      Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context){
    final carregando = context.watch<AutenticacaoProvedor>().carregando;
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Informe seu usuário ou e-mail cadastrado. Enviaremos um link para redefinir sua senha.'),
              const SizedBox(height: 24),
              CampoTextoPersonalizado(
                controlador: _controlador,
                rotulo: 'Usuário ou e-mail',
                validador: (v) => Validadores.validarCampoObrigatorio(
                    v, mensagem: 'Informe o usuário ou e-mail'),
              ),
              const SizedBox(height: 24),
              BotaoPersonalizado(
                  texto: 'Enviar', carregando: carregando, aoPressionar: _enviar),
            ],
          ),
        ),
      ),
    );
  }
}