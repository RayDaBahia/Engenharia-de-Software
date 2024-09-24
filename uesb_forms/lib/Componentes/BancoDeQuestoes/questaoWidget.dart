import 'package:flutter/material.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_linha_unica.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_multipla_escolha.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class QuestaoWidget extends StatelessWidget {
  final Questao questao;
  final String ? bancoId;

  QuestaoWidget({required this.questao, this.bancoId });

  @override
  Widget build(BuildContext context) {
    switch (questao.tipoQuestao) {
      case QuestaoTipo.MultiPlaEscolha:
        return WidgetMultiplaEscolha(questao: questao, bancoId: bancoId,);

      case QuestaoTipo.LinhaUnica:
        return WidgetLinhaUnica(questao: questao, idBanco:  bancoId,);

      default:
        return Text('Tipo de questão não suportado');
    }
  }
}
