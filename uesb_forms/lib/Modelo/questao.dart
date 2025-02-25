import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class Questao {
  String? id;
  String textoQuestao;
  QuestaoTipo tipoQuestao;
  String? resposta;
  DateTime? respostaData;
  List<String>? opcoes;

  // Novas propriedades para o ranking
  List<String>? opcoesRanking;
  List<String>? ordemRanking;
  Map<String, String>? respostaRanking;

  // Direcionamento de respostas (opção escolhida → ID da próxima questão)
  Map<String, String?>? direcionamento;

  // Indica se a questão é obrigatória
  bool obrigatoria;

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
    this.direcionamento,
    this.obrigatoria = false, // Por padrão, a questão não é obrigatória
  });

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'textoQuestao': textoQuestao,
      'tipoQuestao': tipoQuestao.name,
      'resposta': resposta,
      'respostaData': respostaData?.toIso8601String(),
      'opcoes': opcoes ?? [],
      'opcoesRanking': opcoesRanking ?? [],
      'ordemRanking': ordemRanking ?? [],
      'respostaRanking': respostaRanking ?? {},
      'direcionamento': direcionamento ?? {},
      'obrigatoria': obrigatoria,
    };
  }

  // Criar instância a partir de um Map
  factory Questao.fromMap(Map<String, dynamic> map) {
    return Questao(
      id: map['id'],
      textoQuestao: map['textoQuestao'] ?? '',
      tipoQuestao: QuestaoTipo.values.firstWhere(
        (tipo) => tipo.name == map['tipoQuestao'],
        orElse: () => QuestaoTipo.LinhaUnica, // Define um valor padrão se não encontrar
      ),
      resposta: map['resposta'],
      respostaData: map['respostaData'] != null
          ? DateTime.tryParse(map['respostaData'])
          : null,
      opcoes: map['opcoes'] != null ? List<String>.from(map['opcoes']) : [],
      opcoesRanking: map['opcoesRanking'] != null ? List<String>.from(map['opcoesRanking']) : [],
      ordemRanking: map['ordemRanking'] != null ? List<String>.from(map['ordemRanking']) : [],
      respostaRanking: map['respostaRanking'] != null ? Map<String, String>.from(map['respostaRanking']) : {},
      direcionamento: map['direcionamento'] != null
          ? Map<String, String?>.from(map['direcionamento'])
          : {},
      obrigatoria: map['obrigatoria'] ?? false,
    );
  }

  // Método copyWith para criar uma nova instância com valores atualizados
  Questao copyWith({
    String? id,
    String? textoQuestao,
    QuestaoTipo? tipoQuestao,
    String? resposta,
    DateTime? respostaData,
    List<String>? opcoes,
    List<String>? opcoesRanking,
    List<String>? ordemRanking,
    Map<String, String>? respostaRanking,
    Map<String, String?>? direcionamento,
    bool? obrigatoria,
  }) {
    return Questao(
      id: id ?? this.id,
      textoQuestao: textoQuestao ?? this.textoQuestao,
      tipoQuestao: tipoQuestao ?? this.tipoQuestao,
      resposta: resposta ?? this.resposta,
      respostaData: respostaData ?? this.respostaData,
      opcoes: opcoes ?? this.opcoes,
      opcoesRanking: opcoesRanking ?? this.opcoesRanking,
      ordemRanking: ordemRanking ?? this.ordemRanking,
      respostaRanking: respostaRanking ?? this.respostaRanking,
      direcionamento: direcionamento ?? this.direcionamento,
      obrigatoria: obrigatoria ?? this.obrigatoria,
    );
  }
}
