import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'auth_list.dart';


class QuestionarioList extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthList? _authList;

  // Estado geral de questionários
  List<Questionario> _questionariosLider = [];
  List<Questionario> _filteredQuestionarios = [];
  String _filtroSelecionado = '';


  // Dados temporários capturados nas etapas
  List<Questao> listaQuestoes = [];
  String? meta;
  String? nome;
  String? preenchidoPor;
  String? descricao;
  

  QuestionarioList([this._authList]) {

    _carregarQuestionariosLider();
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {

 
  }

  // Salvando os dados temporários diretamente na memória

void setDadosTemporarios({
  String? meta,
  String? nome,
  String? descricao,
  String? preenchido,
  List<Questao>? listaDeQuestoes,
}) {
  this.meta = meta ?? this.meta;
  this.nome = nome ?? this.nome;
  this.preenchidoPor = preenchido ?? this.preenchidoPor;
  this. descricao= descricao?? this.descricao;

  if (listaDeQuestoes != null) {
    this.listaQuestoes = listaDeQuestoes;
  }


  notifyListeners(); // Notifica as mudanças para as telas que utilizam esses dados
}

  

  // Adicionar questionário finalizado
  Future<void> adicionarQuestionario({
    required String senha,
    required List<String> entrevistadores,
    required DateTime prazo,
    required bool publicado,
  }) async {
    try {
      // Uso direto dos dados temporários
      String nome = this.nome ?? 'Sem nome';
      String meta = this.meta ?? '0';
      String preenchidoPor = this.preenchidoPor ?? '';
      String descricao= this.descricao??'Sem descricao';
      List<Questao> listaDeQuestoes = this.listaQuestoes;

      final dataPublicacao = DateTime.now();
      final docRef = _firestore.collection('questionarios').doc(_authList!.usuario!.id);

      final questionario = Questionario(
        id: docRef.id,
        nome: nome,
        descricao: descricao,
        publicado: publicado,
        visivel: true,
        ativo: true,
        prazo: prazo,
        dataPublicacao: dataPublicacao,
        entrevistadores: entrevistadores,
        link: '',
        aplicado: false,
        liderId: _authList?.usuario?.id ?? '',
        senha: senha,
        tipoAplicacao: preenchidoPor,
        meta: int.tryParse(meta) ?? 0,
      );

      await docRef.set(questionario.toMap());
      _questionariosLider.add(questionario);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar questionário: $e');
    }
  }

Future<void>  _carregarQuestionariosLider() async {

  try{
       QuerySnapshot snapshot = await _firestore
        .collection('questionarios')
        .where('liderId', isEqualTo: _authList!.usuario!.id)
        .get();
        _questionariosLider= snapshot.docs.map((doc) {
      return Questionario.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

  }catch (e){

  }

}


  
}