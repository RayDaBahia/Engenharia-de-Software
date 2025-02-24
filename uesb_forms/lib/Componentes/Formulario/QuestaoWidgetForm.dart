import 'package:flutter/material.dart';
import 'package:uesb_forms/Componentes/Formulario/widget.Data_Form.dart';
import 'package:uesb_forms/Componentes/Formulario/widget.Linha_unica_Form.dart';
import 'package:uesb_forms/Componentes/Formulario/widget.ListaSuspensa_Form.dart';
import 'package:uesb_forms/Componentes/Formulario/widget.MultiplasLinhas_Form.dart';
import 'package:uesb_forms/Componentes/Formulario/widget.RespostaNumerica_Form.dart';
import 'package:uesb_forms/Componentes/Formulario/widget.mE_obj_Form.dart';
import 'package:uesb_forms/Componentes/Formulario/widgete.Ranking_Form.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';


class QuestaoWidgetForm extends StatelessWidget {
  final Questao questao;
  final String? bancoId;

  const QuestaoWidgetForm({super.key, required this.questao, this.bancoId});

  @override
  Widget build(BuildContext context) {
    switch (questao.tipoQuestao) {
      // Agrupando os cases para tipos de questão com o mesmo comportamento
      case QuestaoTipo.MultiPlaEscolha:
      case QuestaoTipo.Objetiva:
        return WidgetMeObjForm(
          questao: questao,
        );

      case QuestaoTipo.LinhaUnica:
      case QuestaoTipo.Email:
        return WidgetLinhaUnicaOremailForm(
          questao: questao,
          idBanco: bancoId,
        );

      case QuestaoTipo.Numerica:
        return WidgetRespostaNumericaForm(questao: questao);

      case QuestaoTipo.Data:
        return WidgetDataForm(questao: questao);

      case QuestaoTipo.ListaSuspensa:
        return WidgetListaSuspensaForm(questao: questao);

      case QuestaoTipo.Ranking:
        return WidgetRankingForm(questao: questao);

      case QuestaoTipo.MultiplasLinhas:
        return WidgetMultiplaslinhasForm(questao: questao);

      default:
        return const Text('Tipo de questão não suportado');
    }
  }
}
