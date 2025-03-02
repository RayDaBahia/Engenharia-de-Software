import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
    if (_authList?.usuario == null) {
      await Future.delayed(const Duration(milliseconds: 500)); // Aguarda provider atualizar
    }

    try {
      final snapshot = await _firestore.collection('questionarios').get();
      _questionarios = snapshot.docs
          .map((doc) => Questionario.fromMap(doc.data(), doc.id))
          .toList();
      aplicarFiltro();
    } catch (e) {
      debugPrint('Erro ao buscar questionários: $e');
    }
  }

void setDadosIniciais({
  String? meta,
  String? nome,
  String? preenchido,
  List<Questao>? listaDeQuestoes,
}) async {
  this.meta = meta;
  this.nome = nome;
  this.preenchidoPor = preenchido;

  if (listaDeQuestoes != null) {
    this.listaQuestoes = listaDeQuestoes;
  }

  // Salvar dados no Hive
  var box = await Hive.openBox('questionarioBox');
  await box.put('meta', meta);
  await box.put('nome', nome);
  await box.put('preenchidoPor', preenchido);
  await box.put('listaQuestoes', listaDeQuestoes);

  notifyListeners();
}


  List<Questionario> getQuestionariosDoLider() {
    return _questionarios.where((q) => q.liderId == _authList?.usuario?.id).toList();
  }

  List<Questionario> getQuestionariosDoEntrevistador() {
    return _questionarios.where((q) => q.entrevistadores.contains(_authList?.usuario?.id)).toList();
  }

  void aplicarFiltro() {
    final filtros = {
      'Líder': () => _questionarios.where((q) => q.liderId == _authList?.usuario?.id).toList(),
      'Entrevistador': () => _questionarios.where((q) => q.entrevistadores.contains(_authList?.usuario?.id)).toList(),
      'Aplicado': () => _questionarios.where((q) => q.aplicado).toList(),
      'Publicado': () => _questionarios.where((q) => q.publicado).toList(),
      'Em construção': () => _questionarios.where((q) => !q.publicado && !q.aplicado).toList(),
      'Publicado Visível': () => _questionarios.where((q) => q.publicado && q.visivel).toList(),
      'Publicado Não Visível': () => _questionarios.where((q) => q.publicado && !q.visivel).toList(),
    };

    _filteredQuestionarios = filtros[_filtroSelecionado]?.call() ?? List.from(_questionarios);
    notifyListeners();
  }

 Future<void> adicionarQuestionario({
  required String senha,
  required List<String> entrevistadores,
  required DateTime prazo,
  required bool publicado,
}) async {
  try {
    // Recuperando os dados salvos no Hive
    var box = await Hive.openBox('questionarioBox');
    String? nome = box.get('nome');
    String? meta = box.get('meta');
    String? preenchidoPor = box.get('preenchidoPor');
    List<Questao>? listaDeQuestoes = List<Questao>.from(box.get('listaQuestoes', defaultValue: []));

    final dataPublicacao = DateTime.now();
    final docRef = _firestore.collection('questionarios').doc();

    final questionario = Questionario(
      id: docRef.id,
      nome: nome?.isNotEmpty == true ? nome! : 'Sem nome',
      descricao: '',
      publicado: publicado,
      visivel: true,
      ativo: true,
      prazo: prazo != null ? prazo : null,
      dataPublicacao: dataPublicacao != null ? dataPublicacao : null,
      entrevistadores: entrevistadores,
      link: '',
      aplicado: false,
      liderId: _authList?.usuario?.id ?? '',
      senha: senha.isNotEmpty ? senha : null,
      tipoAplicacao: preenchidoPor ?? '',
      meta: int.tryParse(meta ?? '0') ?? 0,
    );

    await docRef.set(questionario.toMap());

    _questionarios.add(questionario);
    aplicarFiltro();

    notifyListeners();
  } catch (e) {
    debugPrint('Erro ao adicionar questionário: $e');
  }
}

  List<Questionario> obterQuestionariosFiltrados() {
    return _filteredQuestionarios;
  }

  void selecionarFiltro(String filtro) {
    _filtroSelecionado = filtro;
    aplicarFiltro();
  }
  @override
void dispose() {
  Hive.close(); // Fecha todas as caixas do Hive ao descartar o Provider
  super.dispose();
}

}
