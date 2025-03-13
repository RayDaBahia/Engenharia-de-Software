import 'package:hive/hive.dart';
import 'questao.dart'; // Importe sua classe Questao
import 'questao_tipo.dart'; // Importe seu enum QuestaoTipo

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
      opcoes: (fields[5] as List?)?.cast<String>(),
      direcionamento: (fields[6] as Map?)?.cast<String, String?>(),
      obrigatoria: fields[7] as bool,
      bancoId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Questao obj) {
    writer
      ..writeByte(7) // Número de campos (removido resposta e respostaData)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.textoQuestao)
      ..writeByte(2)
      ..write(obj.tipoQuestao.index) // Salve o índice do enum
      ..writeByte(3)
      ..write(obj.opcoes)
      ..writeByte(4)
      ..write(obj.direcionamento)
      ..writeByte(5)
      ..write(obj.obrigatoria)
      ..writeByte(6)
      ..write(obj.bancoId);
  }
}

class QuestaoTipoAdapter extends TypeAdapter<QuestaoTipo> {
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
