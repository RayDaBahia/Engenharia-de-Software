import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/questao.dart';

abstract class QuestaoWidget extends StatefulWidget {
  final Questao questao;

  QuestaoWidget({required this.questao});

  @override
  Widget build(BuildContext context);
}
