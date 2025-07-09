import 'package:flutter/material.dart';
import 'package:uesb_forms/Componentes/Formulario/Dinamizar/widget.Me_obj_Dinamica.dart';
import 'package:uesb_forms/Componentes/Formulario/widget.ListaSuspensa_Form.dart';
import 'package:uesb_forms/Componentes/Formulario/widget.RespostaNumerica_Form.dart';
import 'package:uesb_forms/Componentes/Formulario/widgete.Ranking_Form.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';


class QuestaoDinamicaWidget extends StatelessWidget {
  final Questao questao;
  final String? bancoId;

  const QuestaoDinamicaWidget({super.key, required this.questao, this.bancoId});

  @override
  Widget build(BuildContext context) {
    switch (questao.tipoQuestao) {
      // Agrupando os cases para tipos de questão com o mesmo comportamento
   
      case QuestaoTipo.Objetiva:
        return WidgetMeObjDinamica(
          questao: questao,
        );

   

      default:
        return const Text('Tipo de questão não suportado');
    }
  }
}
