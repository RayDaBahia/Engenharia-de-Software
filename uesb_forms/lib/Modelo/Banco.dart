class Banco {
  final String? id;
  final String nome;
  final String descricao;

  Banco({
    this.id,
    required this.nome,
    required this.descricao,
  });

  // Converte um objeto Banco em um Map (útil para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
    };
  }

  // Converte um Map para um objeto Banco
  factory Banco.fromMap(Map<String, dynamic> map) {
    return Banco(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
    );
  }
}