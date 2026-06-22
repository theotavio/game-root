import 'item_venda_modelo.dart';

class VendaModelo{
  final String id;
  final String clienteId;
  final String nomeCliente;
  final String vendedorId;
  final List<ItemVendaModelo> itens;
  final double latitude;
  final double longitude;
  final String? enderecoAproximado;
  final DateTime realizadaEm;

  VendaModelo({
    required this.id,
    required this.clienteId,
    required this.nomeCliente,
    required this.vendedorId,
    required this.itens,
    required this.latitude,
    required this.longitude,
    this.enderecoAproximado,
    DateTime? realizadaEm,
  }) : realizadaEm = realizadaEm ?? DateTime.now();

  double get valorTotalVenda => itens.fold(0, (soma, item) => soma + item.valorTotal);

  Map<String, dynamic> paraMapa() => {
    'id': id,
    'clienteId': clienteId,
    'nomeCliente': nomeCliente,
    'vendedorId': vendedorId,
    'itens': itens.map((i) => i.paraMapa()).toList(),
    'latitude': latitude,
    'longitude': longitude,
    'enderecoAproximado': enderecoAproximado,
    'valorTotalVenda': valorTotalVenda,
    'realizadaEm': realizadaEm.toIso8601String(),
  };
}