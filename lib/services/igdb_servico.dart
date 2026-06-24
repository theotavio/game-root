import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/utils/chaves_secretas.dart';

class IgdbServico{
  String? _tokenAcesso;
  DateTime? _expiraEm;

  Future<String> _obterToken() async{
    if(_tokenAcesso != null && _expiraEm != null && DateTime.now().isBefore(_expiraEm!))
      return _tokenAcesso!;
    
    final resposta = await http.post(Uri.parse(
        'https://id.twitch.tv/oauth2/token'
        '?client_id=${ChavesSecretas.igdbClientId}'
        '&client_secret=${ChavesSecretas.igdbClientSecret}'
        '&grant_type=client_credentials'));
    if(resposta.statusCode != 200)
      throw Exception('Falha ao autenticar na IGDB: ${resposta.body}');

    final dados = jsonDecode(resposta.body);
    _tokenAcesso = dados['access_token'];
    _expiraEm = DateTime.now().add(Duration(seconds: dados['expires_in'] - 60));
    return _tokenAcesso!;
  }

  Future<List<Map<String, String>>> buscarJogosPorNome(String nome) async{
    final token = await _obterToken();
    final resposta = await http.post(
      Uri.parse('https://api.igdb.com/v4/games'),
      headers: {
        'Client-ID': ChavesSecretas.igdbClientId,
        'Authorization': 'Bearer $token',
        'Content-Type': 'text/plain',
      },
      body: 'search "$nome"; fields name,cover.image_id; limit 10;',
    );

    if(resposta.statusCode != 200)
      throw Exception('Erro ao consultar IGDB: ${resposta.body}');
    final List<dynamic> lista = jsonDecode(resposta.body);

    return lista.where((jogo) => jogo['cover'] != null).map<Map<String, String>>((jogo){
      final imageId = jogo['cover']['image_id'];

      return{
        'nome': jogo['name'] as String,
        'urlCapa':
            'https://images.igdb.com/igdb/image/upload/t_cover_big/$imageId.jpg',
      };
    }).toList();
  }
}