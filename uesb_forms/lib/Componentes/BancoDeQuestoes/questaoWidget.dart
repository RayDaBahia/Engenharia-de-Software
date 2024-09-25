import 'package:flutter/material.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_data.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_linha_unica_orEmail.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_lista_suspensa.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_mE_obj.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_resposta_numerica.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class QuestaoWidget extends StatelessWidget {
  final Questao questao;
  final String? bancoId;

  const QuestaoWidget({super.key, required this.questao, this.bancoId});

  @override
  Widget build(BuildContext context) {
    switch (questao.tipoQuestao) {
      case QuestaoTipo.MultiPlaEscolha || QuestaoTipo.Objetiva:
        return WidgetMultiplaEscolha(
          questao: questao,
          bancoId: bancoId,
        );

      case QuestaoTipo.LinhaUnica || QuestaoTipo.Email:
        return WidgetLinhaUnicaOremail(
          questao: questao,
          idBanco: bancoId,
        );

      case QuestaoTipo.Numerica:
        return WidgetRespostaNumerica(questao: questao);

      case QuestaoTipo.Data:
        return WidgetData(questao: questao);

      case QuestaoTipo.ListaSuspensa:
        return WidgetListaSuspensa(questao: questao);

      default:
        return const Text('Tipo de questão não suportado');
    }
  }
}
