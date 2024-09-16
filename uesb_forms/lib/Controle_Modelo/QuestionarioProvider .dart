import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class QuestionarioProvider extends ChangeNotifier {
  List<Questao> _questoes = [];

  // Retornar lista de questões
  List<Questao> get questoes => _questoes;

  // Adicionar ou atualizar questão
  void adicionarOuAtualizarQuestao(Questao novaQuestao) {
    final index = _questoes.indexWhere((questao) => questao.id== novaQuestao.id);

    if (index >= 0) {
      // Atualizar se já existe
      _questoes[index] = novaQuestao;
    } else {
      // Adicionar se não existe
      _questoes.add(novaQuestao);
    }
    notifyListeners();
  }

  // Remover questão
  void removerQuestao(String id) {
    _questoes.removeWhere((questao) => questao.id== id);
    notifyListeners();
  }
}
