import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vendedor_modelo.dart';
import '../../core/constants/rotas_app.dart';
import '../../core/utils/validadores.dart';
import '../../providers/autenticacao_provedor.dart';
import '../../widgets/campo_texto_personalizado.dart';
import '../../widgets/botao_personalizado.dart';

class TelaCadastroVendedor extends StatefulWidget{
  const TelaCadastroVendedor({super.key});

  @override
  State<TelaCadastroVendedor> createState() => _TelaCadastroVendedorState();
}

class _TelaCadastroVendedorState extends State<TelaCadastroVendedor>{
  final _formKey = GlobalKey<FormState>();
  final _nomeUsuarioControlador = TextEditingController();
  final _nomeControlador = TextEditingController();
  final _emailControlador = TextEditingController();
  final _telefoneControlador = TextEditingController();
  final _senhaControlador = TextEditingController();
  NivelVendedor _nivelSelecionado = NivelVendedor.b;

  Future<void> _cadastrar() async{
    if(!_formKey.currentState!.validate()) 
      return;

    final provedor = context.read<AutenticacaoProvedor>();
    final sucesso = await provedor.cadastrarVendedor(
      nomeUsuario: _nomeUsuarioControlador.text.trim(),
      nome: _nomeControlador.text.trim(),
      email: _emailControlador.text.trim(),
      telefone: _telefoneControlador.text.trim(),
      senha: _senhaControlador.text,
      nivel: _nivelSelecionado,
    );
    if(!mounted) 
      return;
    if(sucesso)
      Navigator.of(context).pushReplacementNamed(RotasApp.inicial);
    else
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provedor.mensagemErro ?? 'Erro ao cadastrar')),
      );
  }

  @override
  Widget build(BuildContext context){
    final carregando = context.watch<AutenticacaoProvedor>().carregando;
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de vendedor')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CampoTextoPersonalizado(
                  controlador: _nomeUsuarioControlador,
                  rotulo: 'Nome de usuário',
                  validador: (v) => Validadores.validarCampoObrigatorio(v, mensagem: 'Informe um usuário'),
                ),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(
                  controlador: _nomeControlador,
                  rotulo: 'Nome completo',
                  validador: (v) => Validadores.validarCampoObrigatorio(v, mensagem: 'Informe o nome'),
                ),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(
                  controlador: _emailControlador,
                  rotulo: 'E-mail',
                  tipoTeclado: TextInputType.emailAddress,
                  validador: Validadores.validarEmail,
                ),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(
                  controlador: _telefoneControlador,
                  rotulo: 'Telefone',
                  tipoTeclado: TextInputType.phone,
                  validador: Validadores.validarTelefone,
                ),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(
                  controlador: _senhaControlador,
                  rotulo: 'Senha',
                  obscurecer: true,
                  validador: Validadores.validarSenha,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<NivelVendedor>(
                  initialValue: _nivelSelecionado,
                  decoration: const InputDecoration(labelText: 'Nível do vendedor'),
                  items: NivelVendedor.values
                      .map((n) => DropdownMenuItem(
                          value: n, child: Text('Nível ${n.rotulo}')))
                      .toList(),
                  onChanged: (v) => setState(() => _nivelSelecionado = v!),
                ),
                const SizedBox(height: 24),
                BotaoPersonalizado(
                    texto: 'Cadastrar',
                    carregando: carregando,
                    aoPressionar: _cadastrar),
              ],
            ),
          ),
        ),
      ),
    );
  }
}