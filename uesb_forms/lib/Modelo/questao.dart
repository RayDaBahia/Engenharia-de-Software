import 'package:uesb_forms/Modelo/questao_tipo.dart';

class Questao {
  String? id;
  String textoQuestao;
  QuestaoTipo tipoQuestao; 
  String? resposta = ''; 
  DateTime? respostaData; 
  List<String>? opcoes;
  
  // Novas propriedades para o ranking
  List<String>? opcoesRanking;   // Lista das opções de ranking
  List<String>? ordemRanking;    // Lista da ordem de classificação
  Map<String, String>? respostaRanking; // Mapa das respostas

  Questao({
    required this.textoQuestao,
    required this.tipoQuestao,
    this.id,
    this.resposta,
    this.respostaData,
    this.opcoes,
    this.opcoesRanking,
    this.ordemRanking,
    this.respostaRanking,
  });

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'textoQuestao': textoQuestao,
      'tipoQuestao': tipoQuestao.name,
      'resposta': resposta,
      'respostaData': respostaData?.toIso8601String(),
      'opcoes': opcoes,
      'opcoesRanking': opcoesRanking,
      'ordemRanking': ordemRanking,
      'respostaRanking': respostaRanking,
    };
  }

  // Criar instância a partir de um Map
  factory Questao.fromMap(Map<String, dynamic> map) {
    return Questao(
      id: map['id'],
      textoQuestao: map['textoQuestao'],
      tipoQuestao: QuestaoTipo.values.firstWhere(
        (tipo) => tipo.name == map['tipoQuestao'],
      ),
      resposta: map['resposta'],
      respostaData: map['respostaData'] != null
          ? DateTime.parse(map['respostaData'])
          : null,
      opcoes: map['opcoes'] == null ? null : List<String>.from(map['opcoes']),
      opcoesRanking: map['opcoesRanking'] == null ? null : List<String>.from(map['opcoesRanking']),
      ordemRanking: map['ordemRanking'] == null ? null : List<String>.from(map['ordemRanking']),
      respostaRanking: map['respostaRanking'] == null ? null : Map<String, String>.from(map['respostaRanking']),
    );
  }
}
