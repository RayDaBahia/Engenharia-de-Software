import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'auth_list.dart'; 

class QuestaoList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthList? _authList;

  QuestaoList([this._authList]);

  // Método para adicionar uma questão a um banco 
  Future<void> addQuestao(String bancoId, Questao questao) async {
    final user = _authList?.usuario; // Obtém o usuário logado
    if (user != null) {
       // Adiciona a questão 
      await _firestore
          .collection('usuarios') // Coleção dos usuários
          .doc(user.id) // ID do usuário logado
          .collection('bancos') // Subcoleção 'bancos'
          .doc(bancoId) // ID do banco específico
          .collection('questoes') // Subcoleção 'questoes' 
          .add(questao.toMap());

      notifyListeners(); 
    }
  }
}
