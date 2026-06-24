import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/autenticacao_provedor.dart';
import '../../services/biometria_servico.dart';
import '../../models/vendedor_modelo.dart';

class TelaConfiguracoes extends StatefulWidget{
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes>{
  bool _verificandoSuporte = true;
  bool _suportado = false;

  @override
  void initState(){
    super.initState();
    BiometriaServico().dispositivoSuportaBiometria().then((valor){
      setState(() {
        _suportado = valor;
        _verificandoSuporte = false;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    final provedor = context.watch<AutenticacaoProvedor>();
    final vendedor = provedor.vendedorLogado;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            title: Text(vendedor?.nome ?? ''),
            subtitle: Text('Nível ${vendedor?.nivel.rotulo ?? ''}'),
          ),
          const Divider(),
          if(_verificandoSuporte)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            )
          else
            SwitchListTile(
              title: const Text('Login por biometria / reconhecimento facial'),
              subtitle: Text(_suportado
                  ? 'Use a digital ou o reconhecimento facial do aparelho para entrar mais rápido'
                  : 'Este aparelho não possui suporte a biometria'),
              value: vendedor?.loginBiometricoAtivo ?? false,
              onChanged: _suportado
                  ? (valor) => context.read<AutenticacaoProvedor>().alternarLoginBiometrico(valor)
                  : null,
            ),
        ],
      ),
    );
  }
}