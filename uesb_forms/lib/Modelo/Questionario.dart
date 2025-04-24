import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Questionario {

  String _id;

  String _nome;

  String _descricao;

  bool _publicado;

  bool _visivel;
  
  bool _ativo;
 
  DateTime? _prazo; // O campo prazo agora é opcional (nullable)

  DateTime? _dataPublicacao; // O campo dataPublicacao agora é opcional (nullable)
 
  List<String> _entrevistadores;

  String? _link;
 
  bool _aplicado;
  
  String? _liderId;
  
  String? _senha;
  
  String _tipoAplicacao;

  int _meta;
 
  String? _liderNome; // Novo campo para o nome do líder

  DateTime _dataCriacao; // Novo campo para a data de criação

  // Tornando todos os parâmetros opcionais com valores padrão
  Questionario({
    String id = '',
    String nome = '',
    String tipoAplicacao = '',
    String descricao = '',
    bool publicado = false,
    bool visivel = false,
    bool ativo = false,
    DateTime? prazo, // Agora o prazo é opcional
    DateTime? dataPublicacao, // Agora o dataPublicacao é opcional
    List<String> entrevistadores = const [],
    String? link,
    bool aplicado = false,
    String? liderId,
    String? senha,
    int meta = 0,
    String? liderNome, // Novo campo no construtor
    DateTime? dataCriacao, // Novo campo no construtor
  })  : _id = id,
        _nome = nome,
        _tipoAplicacao = tipoAplicacao,
        _descricao = descricao,
        _publicado = publicado,
        _visivel = visivel,
        _ativo = ativo,
        _prazo = prazo,
        _dataPublicacao = dataPublicacao,
        _entrevistadores = entrevistadores,
        _link = link,
        _aplicado = aplicado,
        _liderId = liderId,
        _senha = senha,
        _meta = meta,
        _liderNome = liderNome,
        _dataCriacao = dataCriacao ?? DateTime.now(); // Define dataCriacao como agora se não for fornecida

  // Método para copiar o objeto com novos valores
  Questionario copyWith({
    String? id,
    String? nome,
    String? tipoAplicacao,
    String? descricao,
    bool? publicado,
    bool? visivel,
    bool? ativo,
    DateTime? prazo,
    DateTime? dataPublicacao,
    List<String>? entrevistadores,
    String? link,
    bool? aplicado,
    String? liderId,
    String? senha,
    int? meta,
    String? liderNome,
    DateTime? dataCriacao,
  }) {
    return Questionario(
      id: id ?? _id,
      nome: nome ?? _nome,
      tipoAplicacao: tipoAplicacao ?? _tipoAplicacao,
      descricao: descricao ?? _descricao,
      publicado: publicado ?? _publicado,
      visivel: visivel ?? _visivel,
      ativo: ativo ?? _ativo,
      prazo: prazo ?? _prazo,
      dataPublicacao: dataPublicacao ?? _dataPublicacao,
      entrevistadores: entrevistadores ?? _entrevistadores,
      link: link ?? _link,
      aplicado: aplicado ?? _aplicado,
      liderId: liderId ?? _liderId,
      senha: senha ?? _senha,
      meta: meta ?? _meta,
      liderNome: liderNome ?? _liderNome,
      dataCriacao: dataCriacao ?? _dataCriacao,
    );
  }

  // Métodos Getters e Setters
  String get id => _id;
  String get nome => _nome;
  String get descricao => _descricao;
  bool get publicado => _publicado;
  bool get visivel => _visivel;
  bool get ativo => _ativo;
  DateTime? get prazo => _prazo;
  DateTime? get dataPublicacao => _dataPublicacao;
  List<String> get entrevistadores => _entrevistadores;
  String? get link => _link;
  bool get aplicado => _aplicado;
  String? get liderId => _liderId;
  String? get senha => _senha;
  String get tipoAplicacao => _tipoAplicacao;
  int get meta => _meta;
  String? get liderNome => _liderNome;
  DateTime get dataCriacao => _dataCriacao; // Getter para dataCriacao

  set id(String value) => _id = value;
  set nome(String value) => _nome = value;
  set descricao(String value) => _descricao = value;
  set publicado(bool value) => _publicado = value;
  set visivel(bool value) => _visivel = value;
  set ativo(bool value) => _ativo = value;
  set prazo(DateTime? value) => _prazo = value;
  set dataPublicacao(DateTime? value) => _dataPublicacao = value;
  set entrevistadores(List<String> value) => _entrevistadores = value;
  set link(String? value) => _link = value;
  set aplicado(bool value) => _aplicado = value;
  set liderId(String? value) => _liderId = value;
  set senha(String? value) => _senha = value;
  set tipoAplicacao(String value) => _tipoAplicacao = value;
  set meta(int value) => _meta = value;
  set liderNome(String? value) => _liderNome = value;
  set dataCriacao(DateTime value) => _dataCriacao = value; // Setter para dataCriacao

  // Método para converter para Map
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'nome': _nome,
      'descricao': _descricao,
      'publicado': _publicado,
      'visivel': _visivel,
      'ativo': _ativo,
      'prazo': _prazo?.toIso8601String(),
      'dataPublicacao': _dataPublicacao?.toIso8601String(),
      'entrevistadores': _entrevistadores,
      'link': _link,
      'aplicado': _aplicado,
      'liderId': _liderId,
      'senha': _senha,
      'tipoAplicacao': _tipoAplicacao,
      'meta': _meta,
      'liderNome': _liderNome,
      'dataCriacao': _dataCriacao.toIso8601String(), // Adicionando a data de criação ao Map
    };
  }

  // Método para converter de Map para objeto Questionario
 factory Questionario.fromMap(Map<String, dynamic> map, String documentId) {
  return Questionario(
    id: documentId,
    nome: map['nome'] ?? '',
    tipoAplicacao: map['tipoAplicacao'] ?? '',
    descricao: map['descricao'] ?? '',
    publicado: map['publicado'] ?? false,
    visivel: map['visivel'] ?? false,
    ativo: map['ativo'] ?? false,
    prazo: map['prazo'] != null
        ? (map['prazo'] is Timestamp ? map['prazo'].toDate() : DateTime.parse(map['prazo']))
        : null,
    dataPublicacao: map['dataPublicacao'] != null
        ? (map['dataPublicacao'] is Timestamp ? map['dataPublicacao'].toDate() : DateTime.parse(map['dataPublicacao']))
        : null,
    entrevistadores: List<String>.from(map['entrevistadores'] ?? []),
    link: map['link'],
    aplicado: map['aplicado'] ?? false,
    liderId: map['liderId'],
    senha: map['senha'] ?? '',
    meta: map['meta'] ?? 0,
    liderNome: map['liderNome'],
    dataCriacao: map['dataCriacao'] != null
        ? (map['dataCriacao'] is Timestamp ? map['dataCriacao'].toDate() : DateTime.parse(map['dataCriacao']))
        : DateTime.now(), // Definir data de criação como agora se não existir
  );
}

  }

