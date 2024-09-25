//////////////// ARQUIVO NÃO ESTÁ SENDO USADO POR ENQUANTO ////////////////////////
library;



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'auth_list.dart'; 

class QuestaoList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthList? _authList;

  QuestaoList([this._authList]);

  // Método para adicionar uma questão a um banco 
  Future<void> adicionarQuestao(String bancoId, Questao questao) async {
    final user = _authList?.usuario; 
    if (user != null) {
        
      await _firestore
          .collection('usuarios') 
          .doc(user.id) 
          .collection('bancos') 
          .doc(bancoId) 
          .collection('questoes')  
          .add(questao.toMap());

      notifyListeners(); 
    }
  }
}
