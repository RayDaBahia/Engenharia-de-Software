import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo de Resposta Genérica
class Resposta {
  final String id;  // ID único da resposta
  final String questaoId;  // ID da questão à qual a resposta está vinculada
  final String usuarioId;  // ID do usuário que respondeu
  final dynamic resposta;  // A resposta em si (pode ser String, List, etc.)
  final DateTime dataResposta;  // Data e hora da resposta

  // Construtor
  Resposta({
    required this.id,
    required this.questaoId,
    required this.usuarioId,
    required this.resposta,
    required this.dataResposta,
  });

  // Método para converter de Map para Objeto (para salvar no Firestore, por exemplo)
  factory Resposta.fromMap(Map<String, dynamic> map) {
    return Resposta(
      id: map['id'],
      questaoId: map['questaoId'],
      usuarioId: map['usuarioId'],
      resposta: map['resposta'],
      dataResposta: (map['dataResposta'] as Timestamp).toDate(),
    );
  }

  // Método para converter o objeto para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questaoId': questaoId,
      'usuarioId': usuarioId,
      'resposta': resposta,
      'dataResposta': Timestamp.fromDate(dataResposta),
    };
  }
}
