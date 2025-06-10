class Grupo {
  String idLider;
  String? id;
  String nome;
  String? descricao;
  List<String>? idEntrevistadores;
  List<String>? idQuestionarios;
  DateTime dataCriacao; // Agora é público

  Grupo({
    this.id,
    required this.nome,
    required this.idLider,
    this.descricao,
    this.idEntrevistadores,
    this.idQuestionarios,
    DateTime? dataCriacao,
  }) : dataCriacao = dataCriacao ?? DateTime.now(); // define data atual se não for passada

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'idEntrevistadores': idEntrevistadores,
      'idQuestionarios': idQuestionarios,
      'dataCriacao': dataCriacao.toIso8601String(),
      'idLider': idLider
    };
  }

  factory Grupo.fromMap(Map<String, dynamic> map, String id) {
    return Grupo(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'],
      idEntrevistadores: (map['idEntrevistadores'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      idQuestionarios: (map['idQuestionarios'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      dataCriacao: DateTime.parse(map['dataCriacao']),
      idLider: map['idLider']
    );
  }
}
