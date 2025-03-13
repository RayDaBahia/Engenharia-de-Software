import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/Resposta.dart';


  // Carregar as respostas de uma questão específica do Firestore
 class RespostasList with ChangeNotifier {
  List<Resposta> _respostas = [];

  List<Resposta> get respostas => _respostas;

  // Carregar as respostas de um questionário específico
  Future<void> carregarRespostas(String questionarioId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('questionarios')  // Coleção de questionários
          .doc(questionarioId)  // ID do questionário
          .collection('respostas')  // Subcoleção de respostas
          .get();

      _respostas = snapshot.docs.map((doc) {
        return Resposta.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      notifyListeners(); // Notificar a UI que os dados mudaram
    } catch (e) {
      print('Erro ao carregar respostas: $e');
    }
  }


  // Carregar as respostas de uma questão específica de um questionário
  Future<void> carregarRespostasPorQuestao(String questionarioId, String questaoId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('questionarios')  // Coleção de questionários
          .doc(questionarioId)  // ID do questionário
          .collection('respostas')  // Subcoleção de respostas
          .where('questaoId', isEqualTo: questaoId) // Filtro para a questão específica
          .get();

      _respostas = snapshot.docs.map((doc) {
        return Resposta.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      notifyListeners(); // Notificar a UI que os dados mudaram
    } catch (e) {
      print('Erro ao carregar respostas: $e');
    }
  }


  // Adicionar uma nova resposta a um questionário específico
  Future<void> adicionarResposta(String questionarioId, Resposta resposta) async {
    try {
      await FirebaseFirestore.instance
          .collection('questionarios')  // Coleção de questionários
          .doc(questionarioId)  // ID do questionário
          .collection('respostas')  // Subcoleção de respostas
          .doc(resposta.id)  // ID da resposta
          .set(resposta.toMap());

      _respostas.add(resposta); // Atualiza a lista local
      notifyListeners(); // Notificar a UI sobre a alteração
    } catch (e) {
      print('Erro ao adicionar resposta: $e');
    }
  }

  // Função para atualizar uma resposta (caso necessário)
  Future<void> atualizarResposta(String questionarioId, Resposta resposta) async {
    try {
      await FirebaseFirestore.instance
          .collection('questionarios')  // Coleção de questionários
          .doc(questionarioId)  // ID do questionário
          .collection('respostas')  // Subcoleção de respostas
          .doc(resposta.id)  // ID da resposta
          .update(resposta.toMap());

      int index = _respostas.indexWhere((r) => r.id == resposta.id);
      if (index != -1) {
        _respostas[index] = resposta; // Atualiza a resposta na lista local
      }

      notifyListeners(); // Notificar a UI sobre a alteração
    } catch (e) {
      print('Erro ao atualizar resposta: $e');
    }
  }

  // Função para excluir uma resposta (caso necessário)
  Future<void> excluirResposta(String questionarioId, String respostaId) async {
    try {
      await FirebaseFirestore.instance
          .collection('questionarios')  // Coleção de questionários
          .doc(questionarioId)  // ID do questionário
          .collection('respostas')  // Subcoleção de respostas
          .doc(respostaId)  // ID da resposta
          .delete();

      _respostas.removeWhere((resposta) => resposta.id == respostaId); // Remove da lista local
      notifyListeners(); // Notificar a UI sobre a alteração
    } catch (e) {
      print('Erro ao excluir resposta: $e');
    }
  }
    Future<int> contarRespostas(String questionarioId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('questionarios')
          .doc(questionarioId)
          .collection('respostas')
          .get();

      return snapshot.size; // Retorna o número total de respostas
    } catch (e) {
      print('Erro ao contar respostas: $e');
      return 0; // Retorna 0 em caso de erro
    }
  }
}
 
