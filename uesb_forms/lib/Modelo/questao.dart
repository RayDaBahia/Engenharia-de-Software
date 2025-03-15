import 'package:hive/hive.dart';
import 'questao_tipo.dart'; // Importação da enumeração QuestaoTipo

@HiveType(typeId: 0) // O typeId deve ser único
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

  //  Funcionará da seguinte forma:  { 'opcao1': 'idQuestao1', 'opcao2': 'idQuestao2' }
  // pega o id da questão que será direcionada a partir da opção selecionada
  // quando tiver nessa questão objetiva ao responder ela deverá receber por parametro uma função do tipo calback a ser chamada 
  // na tela de exibição do fomulário para ser respondido. Essa função definirá o id da próxima questão a ser exibida que deverá ser 
  // buscada na lista que a tela de exibição do formulário 
  // caso não tenha direcionamento a questão seguinte será a próxima da lista
  
  //  deverá ser criada uma coleção chamada de aplicação  que terá o id do formulario, lider, entrevistador e um map com o id da questão e a resposta

  // crie um aplicação list para gerenciar isso e todos os outros métodos que forem necessários


  Map<String, String?>? direcionamento;

  @HiveField(7)
  bool obrigatoria;

  @HiveField(8)
  String? bancoId;

  Questao({
    required this.textoQuestao,
    required this.tipoQuestao,
    this.id,
    this.opcoes,
    this.direcionamento,
    this.obrigatoria = false,
    this.bancoId,
  });

  // Método toMap para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'textoQuestao': textoQuestao,
      'tipoQuestao': tipoQuestao.name,
      'opcoes': opcoes ?? [],
      'direcionamento': direcionamento ?? {},
      'obrigatoria': obrigatoria,
      'bancoId': bancoId,
    };
  }

  // Método fromMap para Firestore
  factory Questao.fromMap(Map<String, dynamic> map) {
    return Questao(
      id: map['id'],
      textoQuestao: map['textoQuestao'] ?? '',
      tipoQuestao: QuestaoTipo.values.firstWhere(
        (tipo) => tipo.name == map['tipoQuestao'],
        orElse: () => QuestaoTipo.LinhaUnica, // Valor padrão
      ),
      opcoes: map['opcoes'] != null ? List<String>.from(map['opcoes']) : [],
      direcionamento: map['direcionamento'] != null
          ? Map<String, String?>.from(map['direcionamento'])
          : {},
      obrigatoria: map['obrigatoria'] ?? false,
      bancoId: map['bancoId'],
    );
  }
}
