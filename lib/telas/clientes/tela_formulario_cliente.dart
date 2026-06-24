import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cliente_modelo.dart';
import '../../core/utils/validadores.dart';
import '../../providers/cliente_provedor.dart';
import '../../widgets/campo_texto_personalizado.dart';
import '../../widgets/botao_personalizado.dart';

class TelaFormularioCliente extends StatefulWidget{
  final ClienteModelo? clienteParaEditar;
  const TelaFormularioCliente({super.key, this.clienteParaEditar});

  @override
  State<TelaFormularioCliente> createState() => _TelaFormularioClienteState();
}

class _TelaFormularioClienteState extends State<TelaFormularioCliente>{
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeControlador;
  late final TextEditingController _dataNascimentoControlador;
  late final TextEditingController _cpfControlador;
  late final TextEditingController _telefoneControlador;
  late final TextEditingController _emailControlador;
  bool _salvando = false;

  bool get _editando => widget.clienteParaEditar != null;

  @override
  void initState(){
    super.initState();
    final c = widget.clienteParaEditar;
    _nomeControlador = TextEditingController(text: c?.nome ?? '');
    _dataNascimentoControlador =
        TextEditingController(text: c?.dataNascimento ?? '');
    _cpfControlador = TextEditingController(text: c?.cpf ?? '');
    _telefoneControlador = TextEditingController(text: c?.telefone ?? '');
    _emailControlador = TextEditingController(text: c?.email ?? '');
  }

  Future<void> _salvar() async{
    if(!_formKey.currentState!.validate()) 
      return;
    setState(() => _salvando = true);
    final provedor = context.read<ClienteProvedor>();

    try{
      if(_editando){
        final atualizado = widget.clienteParaEditar!.copiarCom(
          nome: _nomeControlador.text.trim(),
          dataNascimento: _dataNascimentoControlador.text.trim(),
          cpf: _cpfControlador.text.trim(),
          telefone: _telefoneControlador.text.trim(),
          email: _emailControlador.text.trim(),
        );
        await provedor.atualizarCliente(atualizado);
      }else{
        await provedor.criarCliente(
          nome: _nomeControlador.text.trim(),
          dataNascimento: _dataNascimentoControlador.text.trim(),
          cpf: _cpfControlador.text.trim(),
          telefone: _telefoneControlador.text.trim(),
          email: _emailControlador.text.trim(),
        );
      }
      if(mounted)
        Navigator.of(context).pop();
    }finally{
      if(mounted) 
        setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar cliente' : 'Novo cliente')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CampoTextoPersonalizado(
                controlador: _nomeControlador,
                rotulo: 'Nome completo',
                validador: (v) => Validadores.validarCampoObrigatorio(v, mensagem: 'Informe o nome'),
              ),
              const SizedBox(height: 12),
              CampoTextoPersonalizado(
                controlador: _dataNascimentoControlador,
                rotulo: 'Data de nascimento (DD/MM/AAAA)',
                tipoTeclado: TextInputType.datetime,
                validador: Validadores.validarDataNascimento,
              ),
              const SizedBox(height: 12),
              CampoTextoPersonalizado(
                controlador: _cpfControlador,
                rotulo: 'CPF',
                tipoTeclado: TextInputType.number,
                validador: Validadores.validarCpf,
              ),
              const SizedBox(height: 12),
              CampoTextoPersonalizado(
                controlador: _telefoneControlador,
                rotulo: 'Telefone',
                tipoTeclado: TextInputType.phone,
                validador: Validadores.validarTelefone,
              ),
              const SizedBox(height: 12),
              CampoTextoPersonalizado(
                controlador: _emailControlador,
                rotulo: 'E-mail',
                tipoTeclado: TextInputType.emailAddress,
                validador: Validadores.validarEmail,
              ),
              const SizedBox(height: 24),
              BotaoPersonalizado(
                texto: _editando ? 'Salvar alterações' : 'Cadastrar cliente',
                carregando: _salvando,
                aoPressionar: _salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}