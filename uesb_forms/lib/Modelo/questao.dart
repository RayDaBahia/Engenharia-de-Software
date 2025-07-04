import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'questao_tipo.dart'; // Importação da enumeração QuestaoTipo

@HiveType(typeId: 0)
class Questao {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String textoQuestao;

  @HiveField(2)
  QuestaoTipo tipoQuestao;

  @HiveField(5)
  List<String>? opcoes;

  @HiveField(6)
  Map<String, String?>? direcionamento;

  @HiveField(7)
  bool obrigatoria;

  @HiveField(8)
  String? bancoId;

  @HiveField(9)
  String? imagemUrl;

  @HiveField(10)
  Uint8List? imagemLocal;

  @HiveField(11)
  Map<String, String>? ranking; // <- Adicionado aqui

  @HiveField(12) // Próximo índice disponível
  int? ordem; // <- NOVO campo

  Questao({
    required this.textoQuestao,
    required this.tipoQuestao,
    this.id,
    this.opcoes,
    this.direcionamento,
    this.obrigatoria = false,
    this.bancoId,
    this.imagemUrl,
    this.imagemLocal,
    this.ranking, // <- Adicionado aqui
    this.ordem = 0, // <- inicialização padrão
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'textoQuestao': textoQuestao,
      'tipoQuestao': tipoQuestao.name,
      'opcoes': opcoes ?? [],
      'direcionamento': direcionamento ?? {},
      'obrigatoria': obrigatoria,
      'bancoId': bancoId,
      'imagemUrl': imagemUrl,
      'ranking': ranking ?? {}, // <- Adicionado aqui
      'ordem': ordem, // <- novo campo no Firestore
    };
  }

  factory Questao.fromMap(Map<String, dynamic> map) {
    return Questao(
      id: map['id'],
      textoQuestao: map['textoQuestao'] ?? '',
      tipoQuestao: QuestaoTipo.values.firstWhere(
        (tipo) => tipo.name == map['tipoQuestao'],
        orElse: () => QuestaoTipo.LinhaUnica,
      ),
      opcoes: map['opcoes'] != null ? List<String>.from(map['opcoes']) : [],
      direcionamento: map['direcionamento'] != null
          ? Map<String, String?>.from(map['direcionamento'])
          : {},
      obrigatoria: map['obrigatoria'] ?? false,
      bancoId: map['bancoId'],
      imagemUrl: map['imagemUrl'],
      ranking: map['ranking'] != null
          ? Map<String, String>.from(map['ranking'])
          : null,
      ordem: map['ordem'] ?? 0, // <- leitura segura
    );
  }
}
