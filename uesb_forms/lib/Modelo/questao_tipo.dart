import 'package:hive/hive.dart';


@HiveType(typeId: 1) // Use um typeId diferente de 0
enum QuestaoTipo {
  @HiveField(0)
  LinhaUnica,
  @HiveField(1)
  MultiPlaEscolha,
  @HiveField(2)
  Numerica,
  @HiveField(3)
  Data,
  @HiveField(4)
  Objetiva,
  @HiveField(5)
  Email,
  @HiveField(6)
  ListaSuspensa,
  @HiveField(7)
  Ranking,
  @HiveField(8)
  MultiplasLinhas,
}