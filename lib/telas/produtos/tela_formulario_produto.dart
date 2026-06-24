import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produto_modelo.dart';
import '../../core/utils/validadores.dart';
import '../../providers/produto_provedor.dart';
import '../../services/igdb_servico.dart';
import '../../widgets/campo_texto_personalizado.dart';
import '../../widgets/botao_personalizado.dart';

class TelaFormularioProduto extends StatefulWidget {
  final ProdutoModelo? produtoParaEditar;
  const TelaFormularioProduto({super.key, this.produtoParaEditar});

  @override
  State<TelaFormularioProduto> createState() => _TelaFormularioProdutoState();
}

class _TelaFormularioProdutoState extends State<TelaFormularioProduto> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeControlador;
  late final TextEditingController _descricaoControlador;
  late final TextEditingController _quantidadeControlador;
  late final TextEditingController _valorControlador;
  late final TextEditingController _plataformaControlador;
  String? _urlFotoSelecionada;
  bool _buscandoCapas = false;
  List<Map<String, String>> _resultadosIgdb = [];
  bool _salvando = false;

  bool get _editando => widget.produtoParaEditar != null;

  @override
  void initState() {
    super.initState();
    final p = widget.produtoParaEditar;
    _nomeControlador = TextEditingController(text: p?.nome ?? '');
    _descricaoControlador = TextEditingController(text: p?.descricao ?? '');
    _quantidadeControlador =
        TextEditingController(text: p?.quantidadeEstoque.toString() ?? '');
    _valorControlador =
        TextEditingController(text: p?.valorUnitario.toString() ?? '');
    _plataformaControlador = TextEditingController(text: p?.plataforma ?? '');
    _urlFotoSelecionada = p?.urlFoto;
  }

  Future<void> _buscarNaIgdb() async {
    if (_nomeControlador.text.trim().isEmpty) return;
    setState(() => _buscandoCapas = true);
    try {
      final resultados =
          await IgdbServico().buscarJogosPorNome(_nomeControlador.text.trim());
      setState(() => _resultadosIgdb = resultados);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao buscar na IGDB: $e')));
      }
    } finally {
      setState(() => _buscandoCapas = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    final provedor = context.read<ProdutoProvedor>();
    try {
      if (_editando) {
        final atualizado = widget.produtoParaEditar!.copiarCom(
          nome: _nomeControlador.text.trim(),
          descricao: _descricaoControlador.text.trim(),
          urlFoto: _urlFotoSelecionada,
          quantidadeEstoque: int.parse(_quantidadeControlador.text),
          valorUnitario:
              double.parse(_valorControlador.text.replaceAll(',', '.')),
          plataforma: _plataformaControlador.text.trim(),
        );
        await provedor.atualizarProduto(atualizado);
      } else {
        await provedor.criarProduto(
          nome: _nomeControlador.text.trim(),
          descricao: _descricaoControlador.text.trim(),
          urlFoto: _urlFotoSelecionada,
          quantidadeEstoque: int.parse(_quantidadeControlador.text),
          valorUnitario:
              double.parse(_valorControlador.text.replaceAll(',', '.')),
          plataforma: _plataformaControlador.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar produto' : 'Novo produto')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_urlFotoSelecionada != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(_urlFotoSelecionada!, height: 140),
                  ),
                ),
              const SizedBox(height: 12),
              CampoTextoPersonalizado(
                controlador: _nomeControlador,
                rotulo: 'Nome do jogo',
                validador: (v) =>
                    Validadores.validarCampoObrigatorio(v, mensagem: 'Informe o nome'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _buscandoCapas ? null : _buscarNaIgdb,
                  icon: _buscandoCapas
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.image_search),
                  label: const Text('Buscar capa na IGDB'),
                ),
              ),
              if (_resultadosIgdb.isNotEmpty)
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _resultadosIgdb.length,
                    itemBuilder: (_, i) {
                      final item = _resultadosIgdb[i];
                      final selecionada = _urlFotoSelecionada == item['urlCapa'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _urlFotoSelecionada = item['urlCapa']),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: selecionada
                                ? Border.all(color: Colors.purple, width: 2)
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(item['urlCapa']!,
                                width: 80, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              CampoTextoPersonalizado(
                  controlador: _descricaoControlador,
                  rotulo: 'Descrição',
                  linhas: 3),
              const SizedBox(height: 12),
              CampoTextoPersonalizado(
                  controlador: _plataformaControlador,
                  rotulo: 'Plataforma (ex: PS5, Xbox, PC, Físico)'),
              const SizedBox(height: 12),
              CampoTextoPersonalizado(
                controlador: _quantidadeControlador,
                rotulo: 'Quantidade em estoque',
                tipoTeclado: TextInputType.number,
                validador: (v) =>
                    Validadores.validarNumero(v, mensagem: 'Informe a quantidade'),
              ),
              const SizedBox(height: 12),
              CampoTextoPersonalizado(
                controlador: _valorControlador,
                rotulo: 'Valor unitário (R\$)',
                tipoTeclado:
                    const TextInputType.numberWithOptions(decimal: true),
                validador: (v) =>
                    Validadores.validarNumero(v, mensagem: 'Informe o valor'),
              ),
              const SizedBox(height: 24),
              BotaoPersonalizado(
                texto: _editando ? 'Salvar alterações' : 'Cadastrar produto',
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