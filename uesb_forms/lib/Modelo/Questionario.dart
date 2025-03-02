import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class Questionario {
  @HiveField(0)
  String _id;
  @HiveField(1)
  String _nome;
  @HiveField(2)
  String _descricao;
  @HiveField(3)
  bool _publicado;
  @HiveField(4)
  bool _visivel;
  @HiveField(5)
  bool _ativo;
  @HiveField(6)
  DateTime? _prazo;
  @HiveField(7)
  DateTime? _dataPublicacao;
  @HiveField(8)
  List<String> _entrevistadores;
  @HiveField(9)
  String? _link;
  @HiveField(10)
  bool _aplicado;
  @HiveField(11)
  String? _liderId;
  @HiveField(12)
  String? _senha;
  @HiveField(13)
  String _tipoAplicacao;
  @HiveField(14)
  int _meta;

  // Tornando todos os parâmetros opcionais com valores padrão
  Questionario({
    String id = '',
    String nome = '',
    String tipoAplicacao = '',
    String descricao = '',
    bool publicado = false,
    bool visivel = false,
    bool ativo = false,
    DateTime? prazo,
    DateTime? dataPublicacao,
    List<String> entrevistadores = const [],
    String? link,
    bool aplicado = false,
    String? liderId,
    String? senha,
    int meta = 0,
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
        _meta = meta;

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
      prazo: map['prazo'] != null ? DateTime.parse(map['prazo']) : null,
      dataPublicacao: map['dataPublicacao'] != null
          ? DateTime.parse(map['dataPublicacao'])
          : null,
      entrevistadores: List<String>.from(map['entrevistadores'] ?? []),
      link: map['link'],
      aplicado: map['aplicado'] ?? false,
      liderId: map['liderId'],
      senha: map['senha'] ?? '',
      meta: map['meta'] ?? 0,
    );
  }
}
