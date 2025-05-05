import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class RespostaProvider extends ChangeNotifier {
  final Map<String, dynamic> _respostas = {};

  // MANTÉM TUDO EXISTENTE (não quebra nada)
  void adicionarResposta(String questaoId, dynamic resposta) {
    _respostas[questaoId] = resposta;
    notifyListeners();
  }

  void removerResposta(String questaoId) {
    _respostas.remove(questaoId);
    notifyListeners();
  }

  dynamic obterResposta(String questaoId) => _respostas[questaoId];

  Map<String, dynamic> get todasRespostas => Map.from(_respostas);

  void limparRespostas() {
    _respostas.clear();
    notifyListeners();
  }

  String? obterRespostaParaNavegacao(
      String questaoId, List<String>? alternativas) {
    final resposta = _respostas[questaoId];

    if (alternativas == null || resposta == null) return null;

    // Converte índice para texto (apenas para navegação)
    if (resposta is int && resposta >= 0 && resposta < alternativas.length) {
      return alternativas[resposta];
    }

    // Já está no formato texto ou não é conversível
    return resposta.toString();
  }
}
