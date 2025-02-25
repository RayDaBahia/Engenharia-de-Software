class Resposta {
  final String questionarioId;
  final String questionId;
  final String usuarioId;
  final dynamic resposta; // Pode ser String, int, ou outro tipo dependendo do tipo de resposta

  Resposta({
    required this.questionarioId,
    required this.questionId,
    required this.usuarioId,
    required this.resposta,
  });

  // Método para converter o objeto Resposta para Map, que é necessário para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'questionario_id': questionarioId,
      'question_id': questionId,
      'usuario_id': usuarioId,
      'resposta': resposta,
    };
  }

  // Método para criar uma Resposta a partir de Map (útil para recuperar dados do Firestore)
  factory Resposta.fromMap(Map<String, dynamic> map) {
    return Resposta(
      questionarioId: map['questionario_id'],
      questionId: map['question_id'],
      usuarioId: map['usuario_id'],
      resposta: map['resposta'],
    );
  }
}
