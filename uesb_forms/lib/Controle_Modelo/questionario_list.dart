import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'auth_list.dart';

class QuestionarioList extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthList? _authList;

  List<Questionario> _questionarios = [];
  List<Questionario> _filteredQuestionarios = [];
  String _filtroSelecionado = '';
  List<Questao> listaQuestoes = [];

  // Novos campos para armazenar os dados iniciais do questionário
  String? meta;
  String? nome;
  String? preenchidoPor;

  List<Questionario> get questionarios => _filteredQuestionarios;

  QuestionarioList([this._authList]) {
    _fetchQuestionarios();
  }
Future<void> _fetchQuestionarios() async {
  final snapshot = await _firestore.collection('questionarios').get();
  _questionarios = snapshot.docs
      .map((doc) => Questionario.fromMap(doc.data(), doc.id))
      .toList();
  aplicarFiltro();
}


  // Método para atualizar os dados iniciais do questionário, agora com a lista de questões
  void setDadosIniciais({
    String? meta,
    String? nome,
    String? preenchido,
    List<Questao>? listaDeQuestoes, // Adiciona a lista de questões como parâmetro
  }) {
    this.meta = meta;
    this.nome = nome;
    this.preenchidoPor = preenchido;

    if (listaDeQuestoes != null) {
      this.listaQuestoes = listaDeQuestoes; // Atualiza a lista de questões
    }

    notifyListeners();
  }

  List<Questionario> getQuestionariosDoLider() {
    return _questionarios
        .where((q) => q.liderId == _authList?.usuario?.id)
        .toList();
  }

  List<Questionario> getQuestionariosDoEntrevistador() {
    return _questionarios
        .where((q) => q.entrevistadores.contains(_authList?.usuario?.id))
        .toList();
  }

  void aplicarFiltro() {
    switch (_filtroSelecionado) {
      case 'Líder':
        _filteredQuestionarios = _questionarios
            .where((q) => q.liderId == _authList?.usuario?.id)
            .toList();
        break;
      case 'Entrevistador':
        _filteredQuestionarios = _questionarios
            .where((q) => q.entrevistadores.contains(_authList?.usuario?.id))
            .toList();
        break;
      case 'Aplicado':
        _filteredQuestionarios = _questionarios.where((q) => q.aplicado).toList();
        break;
      case 'Publicado':
        _filteredQuestionarios =
            _questionarios.where((q) => q.publicado).toList();
        break;
      case 'Em construção':
        _filteredQuestionarios =
            _questionarios.where((q) => !q.publicado && !q.aplicado).toList();
        break;
      case 'Publicado Visível':
        _filteredQuestionarios =
            _questionarios.where((q) => q.publicado && q.visivel).toList();
        break;
      case 'Publicado Não Visível':
        _filteredQuestionarios =
            _questionarios.where((q) => q.publicado && !q.visivel).toList();
        break;
      default:
        _filteredQuestionarios = List.from(_questionarios);
    }
    notifyListeners();
  }
Future<void> adicionarQuestionario({
  required String senha,
  required List<String> entrevistadores,
  required DateTime prazo,
  required bool publicado,
}) async {
  try {
    final dataPublicacao = DateTime.now();

    final questionario = Questionario(
      id: '',
      nome: nome ?? '',
      descricao:  '',
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
      tipoAplicacao:preenchidoPor?? '',
      meta: int.parse(meta ?? '0'),
    );

    final docRef = await _firestore.collection('questionarios').add(questionario.toMap());
    questionario.id = docRef.id;

    _questionarios.add(questionario);
    notifyListeners();
  } catch (e) {
    throw Exception('Erro ao adicionar questionário: $e');
  }
}


  List<Questionario> obterQuestionariosFiltrados() {
    return _filteredQuestionarios;
  }

  void selecionarFiltro(String filtro) {
    _filtroSelecionado = filtro;
    aplicarFiltro();
  }
}
