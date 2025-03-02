import 'package:hive/hive.dart';
import 'questao.dart'; // Importe sua classe Questao
import 'questao_tipo.dart'; //importe seu enum QuestaoTipo

class QuestaoAdapter extends TypeAdapter<Questao> {
  @override
  final typeId = 1; // Use o mesmo typeId da sua classe Questao

  @override
  Questao read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Questao(
      id: fields[0] as String?,
      textoQuestao: fields[1] as String,
      tipoQuestao: QuestaoTipo.values[fields[2] as int],
      resposta: fields[3] as String?,
      respostaData: fields[4] as DateTime?,
      opcoes: (fields[5] as List?)?.cast<String>(),
      opcoesRanking: (fields[6] as List?)?.cast<String>(),
      ordemRanking: (fields[7] as List?)?.cast<String>(),
      respostaRanking: (fields[8] as Map?)?.cast<String, String>(),
      direcionamento: (fields[9] as Map?)?.cast<String, String?>(),
      obrigatoria: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Questao obj) {
    writer
      ..writeByte(11) // Número de campos
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.textoQuestao)
      ..writeByte(2)
      ..write(obj.tipoQuestao.index) // Salve o índice do enum
      ..writeByte(3)
      ..write(obj.resposta)
      ..writeByte(4)
      ..write(obj.respostaData)
      ..writeByte(5)
      ..write(obj.opcoes)
      ..writeByte(6)
      ..write(obj.opcoesRanking)
      ..writeByte(7)
      ..write(obj.ordemRanking)
      ..writeByte(8)
      ..write(obj.respostaRanking)
      ..writeByte(9)
      ..write(obj.direcionamento)
      ..writeByte(10)
      ..write(obj.obrigatoria);
  }
}

class QuestaoTipoAdapter extends TypeAdapter<QuestaoTipo>{
  @override
  final typeId = 2;

  @override
  QuestaoTipo read(BinaryReader reader) {
    return QuestaoTipo.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, QuestaoTipo obj) {
    writer.writeInt(obj.index);
  }

}