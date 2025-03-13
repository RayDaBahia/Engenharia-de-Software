import 'package:hive/hive.dart';
import 'Questionario.dart';

class QuestionarioAdapter extends TypeAdapter<Questionario> {
  @override
  final int typeId = 0; // Mesmo typeId definido na anotação @HiveType

  @override
  Questionario read(BinaryReader reader) {
    return Questionario(
      id: reader.readString(),
      nome: reader.readString(),
      descricao: reader.readString(),
      publicado: reader.readBool(),
      visivel: reader.readBool(),
      ativo: reader.readBool(),
      prazo: reader.readBool() ? DateTime.parse(reader.readString()) : null,
      dataPublicacao:
          reader.readBool() ? DateTime.parse(reader.readString()) : null,
      entrevistadores: List<String>.from(reader.readList()),
      link: reader.readBool() ? reader.readString() : null,
      aplicado: reader.readBool(),
      liderId: reader.readBool() ? reader.readString() : null,
      senha: reader.readBool() ? reader.readString() : null,
      tipoAplicacao: reader.readString(),
      meta: reader.readInt(),
      liderNome: reader.readBool() ? reader.readString() : null, // Novo campo
    );
  }

  @override
  void write(BinaryWriter writer, Questionario obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.nome);
    writer.writeString(obj.descricao);
    writer.writeBool(obj.publicado);
    writer.writeBool(obj.visivel);
    writer.writeBool(obj.ativo);

    writer.writeBool(obj.prazo != null);
    if (obj.prazo != null) writer.writeString(obj.prazo!.toIso8601String());

    writer.writeBool(obj.dataPublicacao != null);
    if (obj.dataPublicacao != null) {
      writer.writeString(obj.dataPublicacao!.toIso8601String());
    }

    writer.writeList(obj.entrevistadores);

    writer.writeBool(obj.link != null);
    if (obj.link != null) writer.writeString(obj.link!);

    writer.writeBool(obj.aplicado);

    writer.writeBool(obj.liderId != null);
    if (obj.liderId != null) writer.writeString(obj.liderId!);

    writer.writeBool(obj.senha != null);
    if (obj.senha != null) writer.writeString(obj.senha!);

    writer.writeString(obj.tipoAplicacao);
    writer.writeInt(obj.meta);

    writer.writeBool(obj.liderNome != null);
    if (obj.liderNome != null) writer.writeString(obj.liderNome!); // Novo campo
  }
}
