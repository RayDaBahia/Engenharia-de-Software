class banco {
  String? id; // O ID é opcional
  final String nome; // Nome do banco (obrigatório)
  final String descricao; // Descrição do banco (obrigatório)

  banco({
    this.id, // Atribuição opcional
    required this.nome, // Nome obrigatório
    required this.descricao, // Descrição obrigatória
  });

  // Converte um objeto Banco em um Map (útil para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
    };
  }

  // Converte um Map para um objeto Banco
  factory banco.fromMap(Map<String, dynamic> map) {
    return banco(
      id: map['id'], // ID opcional, pode ser nulo
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
    );
  }
}
