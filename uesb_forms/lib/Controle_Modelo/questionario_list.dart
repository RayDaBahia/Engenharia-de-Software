import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/grupo.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'auth_list.dart';

class QuestionarioList extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthList? _authList;

  List<Questionario> questionariosEntrevistador = [];
  List<Questionario> questionariosLider = [];
  List<Questionario> questionariosDeGrupos = [];
  List<Questao> listaQuestoes = [];
  List<Grupo> grupos = [];
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

  Future<List<Questionario>> buscarQuestionariosPorGrupo(String grupoId) async {
    List<Questionario> questionariosGrupo = [];

    try {
      final snapshot = await _firestore
          .collection('questionarios')
          .where('grupos', arrayContains: grupoId) // <- Aqui está a correção
          .get();

      questionariosGrupo = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Questionario.fromMap(data, doc.id);
      }).toList();
          // Aqui chama a verificação de encerramento para cada questionário

    await Future.wait( questionariosGrupo.map((q) => verificaEncerramento(q)));
      questionariosDeGrupos=questionariosGrupo;
      notifyListeners();

      debugPrint(
          'Questionários encontrados para o grupo $grupoId: ${questionariosGrupo.length}');
    } catch (e) {
      debugPrint('Erro ao buscar questionários por grupo: $e');
    }

    return questionariosDeGrupos;
  }

  void excluirQuestaoSelecionada(int index, [String? questionarioId]) async {
  if (index >= 0 && index < listaQuestoes.length) {
    String? questaoId = listaQuestoes[index].id; // Pegando o ID da questão
    listaQuestoes.removeAt(index);
    notifyListeners();
    debugPrint(
        'Questão removida localmente. Restantes: ${listaQuestoes.length}');

    if (questaoId != null && questionarioId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('questionarios')
            .doc(questionarioId)
            .collection('questoes')
            .doc(questaoId)
            .delete();
        debugPrint('Questão excluída do Firestore com sucesso.');
      } catch (e) {
        debugPrint('Erro ao excluir questão do Firestore: $e');
      }
    }
  } else {
    debugPrint('Erro: Índice fora do alcance.');
  }
}
void _iniciarVerificacaoDePrazo() {
  _timer = Timer.periodic(Duration(minutes: 10), (timer) async {
    // Une todas as listas de questionarios relevantes:
    final todosQuestionarios = {
      ...questionariosLider,
      ...questionariosEntrevistador,
      ...questionariosDeGrupos,
      // Se tiver outros, adicione aqui, como por exemplo:
      // ...questionariosDeGrupos,
    }.toList();

    await _verificarEAtualizarPrazo(todosQuestionarios);
  });
}

Future<void> _verificarEAtualizarPrazo(List<Questionario> questionarios) async {
  final now = DateTime.now();

  for (var questionario in questionarios) {
    if (questionario.prazo != null &&
        questionario.prazo!.isBefore(now) &&
        questionario.ativo) {
      try {
        await _firestore
            .collection('questionarios')
            .doc(questionario.id)
            .update({
          'ativo': false,
        });

        questionario.ativo = false;

        notifyListeners();
        debugPrint('Questionário ${questionario.id} atualizado para inativo.');
      } catch (e) {
        debugPrint('Erro ao atualizar status do questionário: $e');
      }
    }
  }
}


Future<bool> verificaEncerramento(Questionario questionario) async {
  final agora = DateTime.now();

  final prazoPassado = questionario.prazo != null && questionario.prazo!.isBefore(agora);

  // Busca total de aplicações no Firestore
  final snapshot = await _firestore
      .collection('aplicacoes')
      
        .where("idQuestionario", isEqualTo: questionario.id)
      .get();

  final totalAplicacoes = snapshot.docs.length;
  final metaAtingida = questionario.meta > 0 && totalAplicacoes >= questionario.meta;

  final encerrado = prazoPassado || metaAtingida;

  if (encerrado && !questionario.encerrado) {
    // Atualiza as flags localmente
    questionario.encerrado = true;
    questionario.ativo = false;

    // Atualiza o Firestore
    await _firestore.collection('questionarios').doc(questionario.id).update({
      'encerrado': true,
      'ativo': false,
    });
  }

  return encerrado;
}


  void removerGrupoDaLista(String grupoId) {
    final tamanhoAntes = grupos.length;
    grupos.removeWhere((g) => g.id == grupoId);
    final tamanhoDepois = grupos.length;

    if (tamanhoDepois < tamanhoAntes) {
      notifyListeners();
      debugPrint('Grupo $grupoId removido da lista local.');
    } else {
      debugPrint('Grupo $grupoId não encontrado na lista local.');
    }
  }

  void setDadosTemporarios({
    String? meta,
    String? nome,
    String? descricao,
    String? preenchido,
    List<Questao>? listaDeQuestoes,
    List<Grupo>? listaDeGrupos,
  }) {
    this.meta = meta ?? this.meta;
    this.nome = nome ?? this.nome;
    this.preenchidoPor = preenchido ?? this.preenchidoPor;
    this.descricao = descricao ?? this.descricao;

    if (listaDeQuestoes != null) {
      this.listaQuestoes = listaDeQuestoes;
    }

    if (listaDeGrupos != null) {
      this.grupos = listaDeGrupos;
    }

    notifyListeners();
  }

  void adicionarListaQuestoesSelecionadas(List<Questao> questoes) {
    final Set<String> questoesExistentes =
        listaQuestoes.map(_gerarHash).toSet();

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
    final sortedKeys = mapa.keys.toList()
      ..sort(); // Ordena para garantir consistência
    return sortedKeys.map((key) => '$key:${mapa[key] ?? ""}').join(",");
  }

  void limparQuestoes() {
    listaQuestoes.clear();
    notifyListeners();
  }

  Future<void> adicionarQuestionario({
    required String senha,
    required List<String> entrevistadores,
    DateTime? prazo, // Mudado para opcional
    required bool publicado,
    DateTime? dataPublicacao, // Parâmetro opcional
    required List<String> gruposIds,
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
          prazo: prazo, // Pode ser null
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
          grupos: gruposIds);

      // Persistir questões e adicionar o questionário
      await _persistirQuestoes(listaQuestoes, questionario.id);
      await docRef.set(questionario.toMap());
      questionariosLider.add(questionario);
      limparTudo();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar questionário: $e');
    }
  }

  Future<void> _persistirQuestoes(List<Questao> questoes, String id) async {
    final docRef =
        _firestore.collection('questionarios').doc(id).collection('questoes');

    for (var questao in questoes) {
      if (questao.id != null && questao.id!.isNotEmpty) {
        // Atualiza se a questão já tem um ID
        await docRef
            .doc(questao.id)
            .set(questao.toMap(), SetOptions(merge: true));
            
      debugPrint('Questao add com sucesso!');
      } else {
        // Adiciona uma nova questão se não tiver um ID
        final newDoc = await docRef.add(questao.toMap());
        questao.id = newDoc.id; // Atualiza o ID da questão localmente
      }
    }
  }

  void limparTudo() {
    listaQuestoes.clear();
    grupos.clear();
    meta = null;
    nome = null;
    preenchidoPor = null;
    descricao = null;
    notifyListeners();
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

      final questoesSnapshot = await _firestore
          .collection('questionarios')
          .doc(questionario.id)
          .collection('questoes')
          .get();
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
          await Future.wait( questionariosLider.map((q) => verificaEncerramento(q)));

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
          .where('entrevistadores', arrayContains: _authList!.usuario!.email)
          .get();

      questionariosEntrevistador = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Questionario.fromMap(data, doc.id);
      }).toList();
    await Future.wait( questionariosEntrevistador.map((q) => verificaEncerramento(q)));
      debugPrint(
          'Questionários do entrevistador carregados: ${questionariosEntrevistador.length}');
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
      await _firestore
          .collection('questionarios')
          .doc(id)
          .update({'ativo': true});
      final index = questionariosLider.indexWhere((q) => q.id == id);
      if (index != -1) {
        questionariosLider[index] =
            questionariosLider[index].copyWith(ativo: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao ativar questionário: $e');
    }
  }

  Future<void> desativarQuestionario(String id) async {
    try {
      await _firestore
          .collection('questionarios')
          .doc(id)
          .update({'ativo': false});
      final index = questionariosLider.indexWhere((q) => q.id == id);
      if (index != -1) {
        questionariosLider[index] =
            questionariosLider[index].copyWith(ativo: false);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao desativar questionário: $e');
    }
  }

  Future<void> publicarQuestionario(String id) async {
    try {
      DateTime dataPublicacao = DateTime.now();

      await _firestore.collection('questionarios').doc(id).update({
        'publicado': true,
        'dataPublicacao': Timestamp.fromDate(dataPublicacao)
      });
      final index = questionariosLider.indexWhere((q) => q.id == id);
      if (index != -1) {
        questionariosLider[index] = questionariosLider[index].copyWith(
          publicado: true,
          dataPublicacao:
              dataPublicacao, // Atualiza a data de publicação localmente
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

      listaQuestoes = questoes
        ..sort((a, b) => (a.ordem ?? 0).compareTo(b.ordem ?? 0));

      tamQuestoesLista = questoes.length;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar questões: $e');
    }
  }

  void moverQuestaoAcima(int index) {
  if (index <= 0) return;
  
  final questao = listaQuestoes[index];
  listaQuestoes.removeAt(index);
  listaQuestoes.insert(index - 1, questao);
  
  notifyListeners(); // Importante!
}

void moverQuestaoAbaixo(int index) {
  if (index >= listaQuestoes.length - 1) return;
  
  final questao = listaQuestoes[index];
  listaQuestoes.removeAt(index);
  listaQuestoes.insert(index + 1, questao);
  
  notifyListeners(); // Importante!
}

  Future<void> salvarOrdemQuestoes(String questionarioId) async {
    final batch = _firestore.batch();

    for (int i = 0; i < listaQuestoes.length; i++) {
      final questao = listaQuestoes[i];
      questao.ordem = i;

      if (questao.id != null && questao.id!.isNotEmpty) {
        final docRef = _firestore
            .collection('questionarios')
            .doc(questionarioId)
            .collection('questoes')
            .doc(questao.id);
        batch.update(docRef, {'ordem': i});
      }
    }

    await batch.commit();
    notifyListeners();
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
        'grupos': questionario.grupos,
      });

    debugPrint('📄 tam questao ${ listaQuestoes.length}');
  
     await _persistirQuestoes(listaQuestoes, questionario.id);

     limparTudo();

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
