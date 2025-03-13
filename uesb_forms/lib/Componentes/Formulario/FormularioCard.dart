import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';

class FormularioCard extends StatelessWidget {
  final Questionario questionario;
  final int numRespostas;
  final bool isLider;

  const FormularioCard({
    super.key,
    required this.questionario,
    required this.numRespostas,
    required this.isLider,
  });

  @override
  Widget build(BuildContext context) {
    final questionarioProvider = Provider.of<QuestionarioList>(context, listen: false);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 40,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 103, 52, 139)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              if (questionario.senha != null && questionario.senha!.isNotEmpty)
                const Positioned(
                  right: 10,
                  top: 10,
                  child: Icon(Icons.lock, color: Colors.white, size: 20),
                ),
              if (isLider)
                Positioned(
                  left: 10,
                  top: 10,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) async {
                      if (value == 'publicar') {
                        await questionarioProvider.publicarQuestionario(questionario.id);
                      } else if (value == 'ativar') {
                        await questionarioProvider.ativarQuestionario(questionario.id);
                      } else if (value == 'desativar') {
                        await questionarioProvider.desativarQuestionario(questionario.id);
                      } 
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ação "$value" realizada com sucesso!')),
                        );
                      }
                    },
                    itemBuilder: (context) {
                      List<PopupMenuEntry<String>> opcoes = [];
                      if (!questionario.publicado) {
                        opcoes.add(const PopupMenuItem(value: 'publicar', child: Text('Publicar')));
                      }
                      else{
                      if (!questionario.ativo) {
                        opcoes.add(const PopupMenuItem(value: 'ativar', child: Text('Ativar')));
                      } else {
                        opcoes.add(const PopupMenuItem(value: 'desativar', child: Text('Desativar')));
                       
                      }
                    }
                        return opcoes;
                    }
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  questionario.nome,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Líder: ${questionario.liderNome}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  "Respostas: $numRespostas / ${questionario.meta}",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color.fromARGB(255, 69, 12, 126)),
                      onPressed: () async {
                        await questionarioProvider.duplicarQuestionario(questionario);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Questionário duplicado com sucesso!')),
                          );
                        }
                      },
                    ),
                    if (!questionario.ativo)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await questionarioProvider.excluirQuestionario(questionario.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Questionário excluído com sucesso!')),
                            );
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
