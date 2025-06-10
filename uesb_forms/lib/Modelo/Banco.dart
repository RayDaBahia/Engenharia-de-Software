class Banco {
  String? id; // O ID é opcional
   String nome; // Nome do banco (obrigatório)
   String descricao; // Descrição do banco (obrigatório)
      
  Banco({
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
  factory Banco.fromMap(Map<String, dynamic> map) {
    return Banco(
      id: map['id'], // ID opcional, pode ser nulo
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
    );
  }
}
