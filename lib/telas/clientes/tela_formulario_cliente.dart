import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _dataNascimentoControlador = TextEditingController(text: c?.dataNascimento ?? '');
    _cpfControlador = TextEditingController(text: c?.cpf ?? '');
    _telefoneControlador = TextEditingController(text: c?.telefone ?? '');
    _emailControlador = TextEditingController(text: c?.email ?? '');
  }

  @override
  void dispose(){
    _nomeControlador.dispose();
    _dataNascimentoControlador.dispose();
    _cpfControlador.dispose();
    _telefoneControlador.dispose();
    _emailControlador.dispose();
    super.dispose();
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
              TextFormField(
                controller: _dataNascimentoControlador,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Data de nascimento (DD/MM/AAAA)'),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _DataNascimentoFormatter(),
                ],
                validator: Validadores.validarDataNascimento,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cpfControlador,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'CPF'),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CpfFormatter(),
                ],
                validator: Validadores.validarCpf,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefoneControlador,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Telefone'),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _TelefoneFormatter(),
                ],
                validator: Validadores.validarTelefone,
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

class _DataNascimentoFormatter extends TextInputFormatter{
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue anterior, TextEditingValue novo){
    final digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for(int i = 0; i < digitos.length && i < 8; i++){
      if (i == 2 || i == 4) 
        buffer.write('/');
      buffer.write(digitos[i]);
    }
    final texto = buffer.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class _CpfFormatter extends TextInputFormatter{
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue anterior, TextEditingValue novo){
    final digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for(int i = 0; i < digitos.length && i < 11; i++){
      if(i == 3 || i == 6) 
        buffer.write('.');
      if(i == 9) 
        buffer.write('-');
      buffer.write(digitos[i]);
    }
    final texto = buffer.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class _TelefoneFormatter extends TextInputFormatter{
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue anterior, TextEditingValue novo){
    final digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for(int i = 0; i < digitos.length && i < 11; i++){
      if(i == 0) 
        buffer.write('(');
      if(i == 2) 
        buffer.write(') ');
      if(i == 7) 
        buffer.write('-');
      buffer.write(digitos[i]);
    }
    final texto = buffer.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
