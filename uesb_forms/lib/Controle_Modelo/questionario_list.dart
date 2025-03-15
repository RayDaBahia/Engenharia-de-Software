import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'auth_list.dart';

class QuestionarioList extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthList? _authList;

  List<Questionario> questionariosEntrevistador = [];
  List<Questionario> questionariosLider = [];
  List<Questao> listaQuestoes = [];
  String? meta;
  String? nome;
  String? preenchidoPor;
  String? descricao;
  int tamQuestoesLista = 0;
  // Inicia o timer para verificar o prazo a cada 10 minutos
  Timer? _timer;


  QuestionarioList([this._authList]) {
    _carregarQuestionariosLider();
    _iniciarVerificacaoDePrazo();
  }


  void _iniciarVerificacaoDePrazo() {
    _timer = Timer.periodic(Duration(minutes: 10), (timer) {
      _verificarEAtualizarPrazo();
    });
  }


 Future<void> _verificarEAtualizarPrazo() async {
    final now = DateTime.now();
    
    for (var questionario in questionariosLider) {
      if (questionario.prazo != null && questionario.prazo!.isBefore(now) && !questionario.ativo) {
        // Se o prazo passou e o questionário não está ativo, atualize o status
        try {
          await _firestore.collection('questionarios').doc(questionario.id).update({
            'ativo': false,  // Define como inativo quando o prazo passou
          });

          // Atualize a lista localmente
          questionario.ativo = false;

          notifyListeners();
          debugPrint('Questionário ${questionario.id} atualizado para inativo.');
        } catch (e) {
          debugPrint('Erro ao atualizar status do questionário: $e');
        }
      }
    }
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
  final Set<String> questoesExistentes = listaQuestoes.map(_gerarHash).toSet();

  List<Questao> questoesParaAdicionar = questoes.where((questao) {
    return !questoesExistentes.contains(_gerarHash(questao));
  }).toList();

  if (questoesParaAdicionar.isNotEmpty) {
    listaQuestoes.addAll(questoesParaAdicionar);
    notifyListeners();
  }
}

// Gera um hash único para cada questão
String _gerarHash(Questao questao) {
  return '${questao.textoQuestao}|'
         '${questao.tipoQuestao.index}|'
         '${questao.opcoes?.join(",") ?? ""}|'
         '${_mapaParaString(questao.direcionamento)}|'
         '${questao.obrigatoria}|'
         '${questao.bancoId ?? ""}';
}

// Converte um mapa para uma string ordenada
String _mapaParaString(Map<String, String?>? mapa) {
  if (mapa == null) return "";
  final sortedKeys = mapa.keys.toList()..sort(); // Ordena para garantir consistência
  return sortedKeys.map((key) => '$key:${mapa[key] ?? ""}').join(",");
}


  void limparQuestoes() {
    listaQuestoes.clear();
    notifyListeners();
  }

  Future<void> adicionarQuestionario({
    required String senha,
    required List<String> entrevistadores,
    DateTime? prazo,  // Mudado para opcional
    required bool publicado,
    DateTime? dataPublicacao, // Parâmetro opcional
  }) async {
    try {
      // Valores default
      String nome = this.nome ?? 'Sem nome';
      String meta = this.meta ?? '0';
      String preenchidoPor = this.preenchidoPor ?? '';
      String descricao = this.descricao ?? 'Sem descrição';

      if (publicado) {
        dataPublicacao = DateTime.now();
      }

      // Criando a referência para o Firestore
      final docRef = _firestore.collection('questionarios').doc();
      DateTime dataCriacao = DateTime.now();

      // Criando o objeto Questionario
      final questionario = Questionario(
        id: docRef.id,
        nome: nome,
        descricao: descricao,
        publicado: publicado,
        visivel: true,
        ativo: false,
        prazo: prazo,  // Pode ser null
        dataPublicacao: dataPublicacao, // Pode ser null
        entrevistadores: entrevistadores,
        link: '',
        aplicado: false,
        liderId: _authList?.usuario?.id ?? '',
        senha: senha.isEmpty ? '' : senha,
        tipoAplicacao: preenchidoPor,
        meta: int.tryParse(meta) ?? 0,
        liderNome: _authList?.usuario?.nome ?? '',
        dataCriacao: dataCriacao,
      );

      // Persistir questões e adicionar o questionário
      await _persistirQuestoes(listaQuestoes, questionario.id);
      await docRef.set(questionario.toMap());
      questionariosLider.add(questionario);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar questionário: $e');
    }
  }
Future<void> _persistirQuestoes(List<Questao> questoes, String id) async {
  final docRef = _firestore.collection('questionarios').doc(id).collection('questoes');


  for (var questao in questoes) {
    if (questao.id != null && questao.id!.isNotEmpty) {
      // Atualiza se a questão já tem um ID
      await docRef.doc(questao.id).set(questao.toMap(), SetOptions(merge: true));
    } else {
      // Adiciona uma nova questão se não tiver um ID
      final newDoc = await docRef.add(questao.toMap());
      questao.id = newDoc.id; // Atualiza o ID da questão localmente
    }
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
    if (_authList?.usuario?.id == null) {
      debugPrint('Usuário não autenticado. Não carregando questionários.');
      return;
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('questionarios')
          .where('liderId', isEqualTo: _authList!.usuario!.id)
          .get();

      questionariosLider = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Questionario.fromMap(data, doc.id);
      }).toList();

      debugPrint('Questionários carregados: ${questionariosLider.length}');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar questionários: $e');
    }
  }

Future<void> carregarQuestionariosEntrevistador() async {
  if (_authList?.usuario?.id == null) {
    debugPrint('Usuário não autenticado. Não carregando questionários.');
    return;
  }

  try {
    QuerySnapshot snapshot = await _firestore
        .collection('questionarios')
        .where('entrevistadores', arrayContains: _authList!.usuario!.id)
        .get();

    questionariosEntrevistador = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Questionario.fromMap(data, doc.id);
    }).toList();

    debugPrint('Questionários do entrevistador carregados: ${questionariosEntrevistador.length}');
    notifyListeners();
  } catch (e) {
    debugPrint('Erro ao carregar questionários do entrevistador: $e');
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
      DateTime dataPublicacao = DateTime.now();

      await _firestore.collection('questionarios').doc(id).update({'publicado': true, 'dataPublicacao': Timestamp.fromDate(dataPublicacao)});
      final index = questionariosLider.indexWhere((q) => q.id == id);
      if (index != -1) {
        questionariosLider[index] = questionariosLider[index].copyWith(
          publicado: true,
          dataPublicacao: dataPublicacao, // Atualiza a data de publicação localmente
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao publicar questionário: $e');
    }


    
  }

  Future buscarQuestoes(String questionarioId) async {
  try {
    final querySnapshot = await _firestore
        .collection('questionarios')
        .doc(questionarioId)
        .collection('questoes')
        .get();

    List<Questao> questoes = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Questao.fromMap(data);
    }).toList();

    listaQuestoes = questoes;
    tamQuestoesLista = questoes.length;
     notifyListeners();

   
  } catch (e) {
    debugPrint('Erro ao buscar questões: $e');
  }
}


Future<void> atualizarQuestionario(Questionario questionario) async {
  try {
    await _firestore.collection('questionarios').doc(questionario.id).update({
      'nome': questionario.nome,
      'descricao': questionario.descricao,
      'publicado': questionario.publicado,
      'visivel': questionario.visivel,
      'ativo': questionario.ativo,
      'prazo': questionario.prazo, // Pode ser null
      'dataPublicacao': questionario.dataPublicacao, // Pode ser null
      'entrevistadores': questionario.entrevistadores,
      'link': questionario.link,
      'aplicado': questionario.aplicado,
      'liderId': questionario.liderId,
      'senha': questionario.senha,
      'tipoAplicacao': questionario.tipoAplicacao,
      'meta': questionario.meta,
      'liderNome': questionario.liderNome,
      'dataCriacao': questionario.dataCriacao,
    });

    _persistirQuestoes(listaQuestoes, questionario.id);

    notifyListeners();
    

    debugPrint('Questionário atualizado com sucesso!');
  } catch (e) {
    debugPrint('Erro ao atualizar questionário: $e');
  }
}

@override
  void dispose() {
    _timer?.cancel();
    super.dispose();

  }



}
