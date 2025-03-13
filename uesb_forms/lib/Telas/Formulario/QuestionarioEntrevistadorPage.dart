import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/Formulario/FormularioCard.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_list.dart';

class QuestionariosEntrevistadorPage extends StatelessWidget {
  const QuestionariosEntrevistadorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final questionariosEntrevistador =
        Provider.of<QuestionarioList>(context, listen: true)
            .questionariosLider;

    return questionariosEntrevistador.isEmpty
        ? const Center(
            child: Text(
              'Você ainda não possui questionários como Entrevistador',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: questionariosEntrevistador.length,
              itemBuilder: (ctx, index) {
                final questionario = questionariosEntrevistador[index];

                return FutureBuilder<int>(
                  future: Provider.of<RespostasList>(context, listen: false)
                      .contarRespostas(questionario.id),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final respostas = snapshot.data ?? 0;

                    return FormularioCard(
                      questionario: questionario,
                      numRespostas: respostas,
                      isLider: false,
                    );
                  },
                );
              },
            ),
          );
  }
}
