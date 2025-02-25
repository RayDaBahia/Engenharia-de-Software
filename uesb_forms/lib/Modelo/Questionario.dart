import 'package:uesb_forms/Modelo/questao.dart';

class Questionario {
  String _id;
  String _nome;
  String _descricao;
  bool _publicado;
  bool _visivel;  // Renomeado para visivel
  bool _ativo;
  DateTime? _prazo;
  DateTime? _dataPublicacao;
  List<String> _entrevistadores;
  String? _link;

  bool _aplicado;
  String? _liderId; // Agora armazenamos o ID do líder
  String?_senha;
  String _tipoAplicacao;
  int _meta;

  Questionario({
    required String id,
    required String nome,
    required String tipoAplicacao,
    String descricao = '',
    bool publicado = false,
    bool visivel = false, // Inicializado como false
    bool ativo = false,
    DateTime? prazo,
    DateTime? dataPublicacao,
    List<String> entrevistadores = const [],
    String? link,
    bool aplicado = false,
    String? liderId, // Mudado para liderId
    String? senha,
    int meta = 0,
  })  : _id = id,
        _nome = nome,
        _tipoAplicacao = tipoAplicacao,
        _descricao = descricao,
        _publicado = publicado,
        _visivel = visivel, // Atribuição do novo campo
        _ativo = ativo,
        _prazo = prazo,
        _dataPublicacao = dataPublicacao,
        _entrevistadores = entrevistadores,
        _link = link,
     
        _aplicado = aplicado,
        _liderId = liderId, // Recebe o ID do líder
        _senha = senha,
        _meta = meta;

  // Métodos Getters
  String get id => _id;
  String get nome => _nome;
  String get descricao => _descricao;
  bool get publicado => _publicado;
  bool get visivel => _visivel; // Getter para o novo campo
  bool get ativo => _ativo;
  DateTime? get prazo => _prazo;
  DateTime? get dataPublicacao => _dataPublicacao;
  List<String> get entrevistadores => _entrevistadores;
  String? get link => _link;
  bool get aplicado => _aplicado;
  String? get liderId => _liderId; // Getter para o ID do líder
  String? get senha => _senha;
  String get tipoAplicacao => _tipoAplicacao;
  int get meta => _meta;

  // Métodos Setters
  set id(String value) => _id = value;
  set nome(String value) => _nome = value;
  set descricao(String value) => _descricao = value;
  set publicado(bool value) => _publicado = value;
  set visivel(bool value) => _visivel = value; // Setter para o novo campo
  set ativo(bool value) => _ativo = value;
  set prazo(DateTime? value) => _prazo = value;
  set dataPublicacao(DateTime? value) => _dataPublicacao = value;
  set entrevistadores(List<String> value) => _entrevistadores = value;
  set link(String? value) => _link = value;

  set aplicado(bool value) => _aplicado = value;
  set liderId(String? value) => _liderId = value; // Setter para o ID do líder
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
      'visivel': _visivel, // Adicionar no Map
      'ativo': _ativo,
      'prazo': _prazo?.toIso8601String(),
      'dataPublicacao': _dataPublicacao?.toIso8601String(),
      'entrevistadores': _entrevistadores,
      'link': _link,
      'aplicado': _aplicado,
      'liderId': _liderId, // Adiciona o campo do ID do líder
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
      visivel: map['visivel'] ?? false, // Adicionar ao converter
      ativo: map['ativo'] ?? false,
      prazo: map['prazo'] != null ? DateTime.parse(map['prazo']) : null,
      dataPublicacao: map['dataPublicacao'] != null
          ? DateTime.parse(map['dataPublicacao'])
          : null,
      entrevistadores: List<String>.from(map['entrevistadores'] ?? []),
      link: map['link'],
      aplicado: map['aplicado'] ?? false,
      liderId: map['liderId'], // Agora pega o ID do líder
      senha: map['senha'] ?? '',
      meta: map['meta'] ?? 0,
    );
  }
}
