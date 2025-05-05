class Aplicacaoquestionario {


  String idAplicacao;
  String idQuestionario;
  String? idEntrevistador;
  String? idEntrevistado;

  //Lista de respostas, onde cada resposta é um mapa com o id da questão e a resposta dada
  // Exemplo: [{"idQuestao": "1", "resposta": "Sim"}, {"idQuestao": "2", "resposta": "Não"}]
  List<Map<String, dynamic>> respostas;


  Aplicacaoquestionario({
    required this.idAplicacao,
    required this.idQuestionario,
    required this.respostas,
     this.idEntrevistador,
     this.idEntrevistado,
 
  });



  Map<String, dynamic> toMapAplicacao(){
    return {
      'idAplicacao': idAplicacao,
      'idQuestionario': idQuestionario,
      'idEntrevistador': idEntrevistador,
      'respostas': respostas,
      'idEntrevistado': idEntrevistado,

    };
  }

  factory Aplicacaoquestionario.fromMapAplicacao(Map<String, dynamic> map) {
    return Aplicacaoquestionario(
      idAplicacao: map['idAplicacao'],
      idQuestionario: map['idQuestionario'],
      idEntrevistador: map['idEntrevistador'],
      respostas: List<Map<String, dynamic>>.from(map['respostas']),
      idEntrevistado: map['idEntrevistado'],

    );
  }


}





