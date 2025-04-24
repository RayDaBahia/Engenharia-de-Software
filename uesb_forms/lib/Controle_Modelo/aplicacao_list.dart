import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/AplicacaoQuestionario.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Modelo/questao.dart'; // importando modelo de questão
import 'auth_list.dart';



class AplicacaoList with ChangeNotifier {
  
  List<Aplicacaoquestionario> _aplicacoes = [];
  Aplicacaoquestionario aplicacaoAtual= Aplicacaoquestionario(
    idAplicacao: "0",
    idQuestionario: "0",
    respostas: [],
  );


  List<Aplicacaoquestionario> get aplicacoes => _aplicacoes;


  Future<void> persistirNoFirebase() async{
    await FirebaseFirestore.instance.collection("aplicacoes").add(
      aplicacaoAtual.toMapAplicacao(),
    );
  }

  void adicionarResposta( String idQuestao, dynamic resposta, String ? idEntrevistador, String? idEntrevistado) {
    
      aplicacaoAtual.idEntrevistado = idEntrevistado;
      aplicacaoAtual.idEntrevistador = idEntrevistador;
      aplicacaoAtual.respostas.add({"idQuestao": idQuestao, "resposta": resposta});
      notifyListeners();
    
  }

  void buscarAplicacoes() async {
    final snapshot = await FirebaseFirestore.instance.collection("aplicacoes").get();
    _aplicacoes = snapshot.docs.map((doc) {
      return Aplicacaoquestionario.fromMapAplicacao(doc.data());
    }).toList();
    notifyListeners();
  }

}


