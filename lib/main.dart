import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/constants/rotas_app.dart';
import 'core/themes/tema_app.dart';
import 'providers/autenticacao_provedor.dart';
import 'providers/produto_provedor.dart';
import 'providers/cliente_provedor.dart';
import 'providers/venda_provedor.dart';
import 'telas/splash/tela_splash.dart';
import 'telas/autenticacao/tela_login.dart';
import 'telas/autenticacao/tela_cadastro_vendedor.dart';
import 'telas/autenticacao/tela_recuperar_senha.dart';
import 'telas/inicio/tela_inicial.dart';
import 'telas/inicio/tela_configuracoes.dart';
import 'telas/produtos/tela_produtos.dart';
import 'telas/produtos/tela_formulario_produto.dart';
import 'telas/clientes/tela_cliente.dart';
import 'telas/clientes/tela_formulario_cliente.dart';
import 'telas/vendas/tela_vendas.dart';
import 'models/produto_modelo.dart';
import 'models/cliente_modelo.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const GameRootApp());
}

class GameRootApp extends StatelessWidget{
  const GameRootApp({super.key});

  @override
  Widget build(BuildContext context){
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AutenticacaoProvedor()),
        ChangeNotifierProvider(create: (_) => ProdutoProvedor()),
        ChangeNotifierProvider(create: (_) => ClienteProvedor()),
        ChangeNotifierProvider(create: (_) => VendaProvedor()),
      ],
      child: MaterialApp(
        title: 'GameRoot',
        debugShowCheckedModeBanner: false,
        theme: TemaApp.temaClaro,
        initialRoute: RotasApp.splash,
        onGenerateRoute: (configuracao){
          switch(configuracao.name){
            case RotasApp.splash:
              return MaterialPageRoute(builder: (_) => const TelaSplash());
            case RotasApp.login:
              return MaterialPageRoute(builder: (_) => const TelaLogin());
            case RotasApp.cadastroVendedor:
              return MaterialPageRoute(
                  builder: (_) => const TelaCadastroVendedor());
            case RotasApp.recuperarSenha:
              return MaterialPageRoute(
                  builder: (_) => const TelaRecuperarSenha());
            case RotasApp.inicial:
              return MaterialPageRoute(builder: (_) => const TelaInicial());
            case RotasApp.configuracoes:
              return MaterialPageRoute(
                  builder: (_) => const TelaConfiguracoes());
            case RotasApp.produtos:
              return MaterialPageRoute(builder: (_) => const TelaProdutos());
            case RotasApp.formularioProduto:
              return MaterialPageRoute(
                builder: (_) => TelaFormularioProduto(
                    produtoParaEditar:
                        configuracao.arguments as ProdutoModelo?),
              );
            case RotasApp.clientes:
              return MaterialPageRoute(builder: (_) => const TelaClientes());
            case RotasApp.formularioClientes:
              return MaterialPageRoute(
                builder: (_) => TelaFormularioCliente(
                    clienteParaEditar:
                        configuracao.arguments as ClienteModelo?),
              );
            case RotasApp.vendas:
              return MaterialPageRoute(builder: (_) => const TelaVendas());
            default:
              return MaterialPageRoute(builder: (_) => const TelaSplash());
          }
        },
      ),
    );
  }
}