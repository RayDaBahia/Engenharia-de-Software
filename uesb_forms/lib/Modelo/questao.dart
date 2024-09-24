import 'package:uesb_forms/Modelo/questao_tipo.dart';

class Questao {

  
  String id;
  String textoQuestao;
  QuestaoTipo tipoQuestao; // "Linha Única", "Múltiplas Linhas", "Número", "Data", "Imagem", "Múltipla Escolha", etc.
  
  // Campos para "Linha Única" e "Múltiplas Linhas"
  String? resposta=''; // Para armazenar resposta de texto

  // Campos para "Número"
  int? respostaNumerica; // Para Questaos numéricas

  // Campos para "Data"
  DateTime? respostaData; // Para Questaos de data

  // Campos para "Upload de Imagem"
  int? maxArquivos; // Número máximo de arquivos
  double? tamanhoMaximoArquivo; // Tamanho máximo dos arquivos

  // Campos para "Múltipla Escolha" e "Objetiva"
  List<String>? opcoes; // Opções de múltipla escolha ou objetiva
  List<String>? opcoesSelecionadas; // Respostas selecionadas em múltipla escolha
  String? opcaoSelecionada; // Resposta selecionada em objetiva

  // Campos para "Ranking"
  List<String>? opcoesRanking; // Opções para ranking
  List<int>? ordemRanking; // Ordem das opções no ranking

  // Campos para "Resposta Única" (Lista suspensa)
  String? respostaDropdown; // Resposta selecionada da lista suspensa
  
  // Campos para "E-mail"
  String? respostaEmail; // E-mail com validação

  Questao({
    required this.id,
    required this.textoQuestao,
    required this.tipoQuestao,
    this.resposta,
    this.respostaNumerica,
    this.respostaData,
    this.maxArquivos,
    this.tamanhoMaximoArquivo,
    this.opcoes,
    this.opcoesSelecionadas,
    this.opcaoSelecionada,
    this.opcoesRanking,
    this.ordemRanking,
    this.respostaDropdown,
    this.respostaEmail,
  });

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'textoQuestao': textoQuestao,
      'tipoQuestao': tipoQuestao.name,
      'resposta': resposta,
      'respostaNumerica': respostaNumerica,
      'respostaData': respostaData?.toIso8601String(),
      'maxArquivos': maxArquivos,
      'tamanhoMaximoArquivo': tamanhoMaximoArquivo,
      'opcoes': opcoes,
      'opcoesSelecionadas': opcoesSelecionadas,
      'opcaoSelecionada': opcaoSelecionada,
      'opcoesRanking': opcoesRanking,
      'ordemRanking': ordemRanking,
      'respostaDropdown': respostaDropdown,
      'respostaEmail': respostaEmail,
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
      respostaNumerica: map['respostaNumerica'],
      respostaData: map['respostaData'] != null ? DateTime.parse(map['respostaData']) : null,
      maxArquivos: map['maxArquivos'],
      tamanhoMaximoArquivo: map['tamanhoMaximoArquivo'],
      opcoes: List<String>.from(map['opcoes'] ?? []),
      opcoesSelecionadas: List<String>.from(map['opcoesSelecionadas'] ?? []),
      opcaoSelecionada: map['opcaoSelecionada'],
      opcoesRanking: List<String>.from(map['opcoesRanking'] ?? []),
      ordemRanking: List<int>.from(map['ordemRanking'] ?? []),
      respostaDropdown: map['respostaDropdown'],
      respostaEmail: map['respostaEmail'],
    );
  }
}
