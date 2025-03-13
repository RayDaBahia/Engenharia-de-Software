import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'auth_list.dart';

class QuestionarioList extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthList? _authList;

  List<Questionario> questionariosLider = [];
  List<Questao> listaQuestoes = [];
  String? meta;
  String? nome;
  String? preenchidoPor;
  String? descricao;
  int tamQuestoesLista = 0;

  QuestionarioList([this._authList]) {
    _carregarQuestionariosLider();
  }

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
    this.descricao = descricao ?? this.descricao;
    if (listaDeQuestoes != null) {
      this.listaQuestoes = listaDeQuestoes;
    }
    notifyListeners();
  }

  void adicionarListaQuestoesSelecionadas(List<Questao> questoes) {
    listaQuestoes.addAll(questoes);
    notifyListeners();
  }

  Future<void> adicionarQuestionario({
    required String senha,
    required List<String> entrevistadores,
    required DateTime prazo,
    required bool publicado,
  }) async {
    try {
      String nome = this.nome ?? 'Sem nome';
      String meta = this.meta ?? '0';
      String preenchidoPor = this.preenchidoPor ?? '';
      String descricao = this.descricao ?? 'Sem descrição';
      final dataPublicacao = DateTime.now();
      final docRef = _firestore.collection('questionarios').doc();

      final questionario = Questionario(
        id: docRef.id,
        nome: nome,
        descricao: descricao,
        publicado: publicado,
        visivel: true,
        ativo: false,
        prazo: prazo,
        dataPublicacao: dataPublicacao,
        entrevistadores: entrevistadores,
        link: '',
        aplicado: false,
        liderId: _authList?.usuario?.id ?? '',
        senha: senha ?? '',
        tipoAplicacao: preenchidoPor,
        meta: int.tryParse(meta) ?? 0,
        liderNome: _authList?.usuario?.nome ?? '',
      );

      _persistirQuestoes(listaQuestoes, questionario.id);
      await docRef.set(questionario.toMap());
      questionariosLider.add(questionario);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar questionário: $e');
    }
  }

  Future<void> _persistirQuestoes(List<Questao> questoes, String id) async {
    final docRef = _firestore.collection('questionarios').doc(id).collection('questoes');
    for (int i = tamQuestoesLista; i < listaQuestoes.length; i++) {
      await docRef.add(questoes[i].toMap());
    }
  }

  Future<void> excluirQuestionario(String id) async {
    try {
      await _firestore.collection('questionarios').doc(id).delete();
      questionariosLider.removeWhere((q) => q.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao excluir questionário: $e');
    }
  }

  Future<void> duplicarQuestionario(Questionario questionario) async {
    try {
      final novoDocRef = _firestore.collection('questionarios').doc();
      final novoQuestionario = questionario.copyWith(id: novoDocRef.id);

      await novoDocRef.set(novoQuestionario.toMap());
      questionariosLider.add(novoQuestionario);
      notifyListeners();

      final questoesSnapshot = await _firestore.collection('questionarios').doc(questionario.id).collection('questoes').get();
      for (var doc in questoesSnapshot.docs) {
        await novoDocRef.collection('questoes').add(doc.data());
      }
    } catch (e) {
      debugPrint('Erro ao duplicar questionário: $e');
    }
  }

  Future<void> _carregarQuestionariosLider() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('questionarios')
          .where('liderId', isEqualTo: _authList!.usuario!.id)
          .get();
      questionariosLider = snapshot.docs.map((doc) {
        return Questionario.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar questionários: $e');
    }
  }

  void limparQuestoesSelecionadas() {
    listaQuestoes.clear();
    notifyListeners();
  }

  Future<void> ativarQuestionario(String id) async {
  try {
    await _firestore.collection('questionarios').doc(id).update({'ativo': true});
    final index = questionariosLider.indexWhere((q) => q.id == id);
    if (index != -1) {
      questionariosLider[index] = questionariosLider[index].copyWith(ativo: true);
      notifyListeners();
    }
  } catch (e) {
    debugPrint('Erro ao ativar questionário: $e');
  }
}

Future<void> desativarQuestionario(String id) async {
  try {
    await _firestore.collection('questionarios').doc(id).update({'ativo': false});
    final index = questionariosLider.indexWhere((q) => q.id == id);
    if (index != -1) {
      questionariosLider[index] = questionariosLider[index].copyWith(ativo: false);
      notifyListeners();
    }
  } catch (e) {
    debugPrint('Erro ao desativar questionário: $e');
  }
}

Future<void> publicarQuestionario(String id) async {
  try {
    await _firestore.collection('questionarios').doc(id).update({'publicado': true});
    final index = questionariosLider.indexWhere((q) => q.id == id);
    if (index != -1) {
      questionariosLider[index] = questionariosLider[index].copyWith(publicado: true);
      notifyListeners();
    }
  } catch (e) {
    debugPrint('Erro ao publicar questionário: $e');
  }
}




}
