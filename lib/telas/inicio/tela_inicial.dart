import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/cores_app.dart';
import '../../core/constants/rotas_app.dart';
import '../../providers/autenticacao_provedor.dart';

class TelaInicial extends StatelessWidget{
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context){
    final vendedor = context.watch<AutenticacaoProvedor>().vendedorLogado;

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${vendedor?.nome.split(' ').first ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(RotasApp.configuracoes),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _CartaoMenu(
              icone: Icons.people_alt_outlined,
              titulo: 'Clientes',
              onTap: () => Navigator.of(context).pushNamed(RotasApp.clientes),
            ),
            _CartaoMenu(
              icone: Icons.videogame_asset_outlined,
              titulo: 'Produtos',
              habilitado: vendedor?.podeGerenciarProdutos ?? false,
              onTap: () => Navigator.of(context).pushNamed(RotasApp.produtos),
            ),
            _CartaoMenu(
              icone: Icons.point_of_sale_outlined,
              titulo: 'Vendas',
              onTap: () => Navigator.of(context).pushNamed(RotasApp.vendas),
            ),
            _CartaoMenu(
              icone: Icons.logout,
              titulo: 'Sair',
              onTap: () async{
                await context.read<AutenticacaoProvedor>().sair();
                if(context.mounted)
                  Navigator.of(context).pushNamedAndRemoveUntil(RotasApp.login, (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoMenu extends StatelessWidget{
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;
  final bool habilitado;

  const _CartaoMenu({
    required this.icone,
    required this.titulo,
    required this.onTap,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context){
    return Opacity(
      opacity: habilitado ? 1 : 0.4,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: habilitado
              ? onTap
              : () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Apenas vendedores nível A podem acessar')),
                  ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 38, color: CoresApp.roxoPrimario),
              const SizedBox(height: 10),
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}