import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/rotas_app.dart';
import '../../core/utils/validadores.dart';
import '../../providers/autenticacao_provedor.dart';
import '../../services/preferencias_servico.dart';
import '../../widgets/campo_texto_personalizado.dart';
import '../../widgets/botao_personalizado.dart';

class TelaLogin extends StatefulWidget{
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin>{
  final _formKey = GlobalKey<FormState>();
  final _emailControlador = TextEditingController();
  final _senhaControlador = TextEditingController();
  bool _senhaVisivel = false;
  bool _biometriaAtiva = false;

  @override
  void initState(){
    super.initState();
    PreferenciasServico().obterBiometriaAtiva().then((ativa){
      setState(() => _biometriaAtiva = ativa);
    });
  }

  Future<void> _entrar() async{
    if(!_formKey.currentState!.validate()) 
      return;

    final provedor = context.read<AutenticacaoProvedor>();
    final sucesso = await provedor.entrarComEmailESenha(
      _emailControlador.text.trim(),
      _senhaControlador.text,
    );
    if(!mounted) 
      return;
    if(sucesso)
      Navigator.of(context).pushReplacementNamed(RotasApp.inicial);
    else
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provedor.mensagemErro ?? 'Erro ao entrar')),
      );
  }

  Future<void> _entrarComBiometria() async{
    final provedor = context.read<AutenticacaoProvedor>();
    final sucesso = await provedor.entrarComBiometria();
    if(!mounted) 
      return;
    if(sucesso)
      Navigator.of(context).pushReplacementNamed(RotasApp.inicial);
    else
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provedor.mensagemErro ?? 'Não foi possível autenticar'),
        ),
      );
  }

  @override
  void dispose(){
    _emailControlador.dispose();
    _senhaControlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final provedor = context.watch<AutenticacaoProvedor>();
    final carregando = provedor.carregando;

    if(!provedor.inicializado){
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 60),
                Text('Bem-vindo de volta',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Entre com seu e-mail e senha',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),
                CampoTextoPersonalizado(
                  controlador: _emailControlador,
                  rotulo: 'E-mail',
                  tipoTeclado: TextInputType.emailAddress,
                  validador: Validadores.validarEmail,
                ),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(
                  controlador: _senhaControlador,
                  rotulo: 'Senha',
                  obscurecer: !_senhaVisivel,
                  sufixo: IconButton(
                    icon: Icon(_senhaVisivel
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                  validador: Validadores.validarSenha,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(RotasApp.recuperarSenha),
                    child: const Text('Esqueci minha senha'),
                  ),
                ),
                const SizedBox(height: 12),
                BotaoPersonalizado(
                  texto: 'Entrar',
                  carregando: carregando,
                  aoPressionar: _entrar,
                ),
                if (provedor.inicializado && _biometriaAtiva) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _entrarComBiometria,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Entrar com biometria / Face'),
                  ),
                ],
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(RotasApp.cadastroVendedor),
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}