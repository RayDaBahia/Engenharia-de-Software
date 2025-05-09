import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/aplicacao_list.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Telas/Formulario/Dados.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class FormularioLider extends StatelessWidget {
  final Questionario questionario;
  final VoidCallback onAplicar; // Callback para aplicar
  final VoidCallback onTestar; // Callback para testar

  const FormularioLider({
    super.key,
    required this.questionario,
    required this.onAplicar,
    required this.onTestar,
  });

  @override
  Widget build(BuildContext context) {
    final questionarioProvider =
        Provider.of<QuestionarioList>(context, listen: true);

    final Provider_aplicacao =
        Provider.of<AplicacaoList>(context, listen: false);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 103, 52, 139)
                    ],
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
              Positioned(
                left: 10,
                top: 5,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) async {
                    switch (value) {
                      case 'publicar':
                        await questionarioProvider
                            .publicarQuestionario(questionario.id);
                        break;
                      case 'ativar':
                        await questionarioProvider
                            .ativarQuestionario(questionario.id);
                        break;
                      case 'desativar':
                        await questionarioProvider
                            .desativarQuestionario(questionario.id);
                        break;
                      case 'editar':
                        Navigator.of(context).pushNamed(
                            Rotas.EDICAO_FORMULARIO_TELA,
                            arguments: questionario);
                        break;
                      case 'editar configurações':
                        Navigator.of(context).pushNamed(
                            Rotas.CONFIGURAR_ACESSO_FORMS,
                            arguments: questionario);
                        break;
                      case 'testar':
                        onTestar();
                        break;
                      case 'aplicar':
                        onAplicar();
                        break;
                      case 'Dados':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                Dados(questionario: questionario),
                          ),
                        );

                        break;
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Ação "$value" realizada com sucesso!')),
                      );
                    }
                  },
                  itemBuilder: (context) {
                    List<PopupMenuEntry<String>> opcoes = [];

                    // Adiciona opções de teste e aplicar (sempre visíveis)
                    opcoes.add(const PopupMenuItem(
                      value: 'testar',
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow, color: Colors.black),
                          SizedBox(width: 8),
                          Text('Testar questionário'),
                        ],
                      ),
                    ));

                    opcoes.add(const PopupMenuItem(
                      value: 'aplicar',
                      child: Row(
                        children: [
                          Icon(Icons.assignment, color: Colors.black),
                          SizedBox(width: 8),
                          Text('Aplicar questionário'),
                        ],
                      ),
                    ));

                    if (!questionario.publicado) {
                      opcoes.add(const PopupMenuItem(
                          value: 'publicar', child: Text('Publicar')));
                      opcoes.add(const PopupMenuItem(
                          value: 'editar', child: Text('Editar')));
                      opcoes.add(const PopupMenuItem(
                          value: 'editar configurações',
                          child: Text('Editar configurações')));
                    }
                    if (questionario.publicado) {
                      if (!questionario.ativo) {
                        opcoes.add(const PopupMenuItem(
                            value: 'ativar', child: Text('Ativar')));
                        opcoes.add(const PopupMenuItem(
                          value: 'Dados',
                          child: Row(
                            children: [
                              Icon(Icons.bar_chart),
                              SizedBox(
                                width: 8,
                              ),
                              Text('Dados')
                            ],
                          ),
                        ));
                      } else {
                        opcoes.add(const PopupMenuItem(
                            value: 'desativar', child: Text('Desativar')));
                        opcoes.add(const PopupMenuItem(
                          value: 'Dados',
                          child: Row(
                            children: [
                              Icon(Icons.bar_chart),
                              SizedBox(
                                width: 8,
                              ),
                              Text('Dados no excel')
                            ],
                          ),
                        ));
                      }
                    }

                    return opcoes;
                  },
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
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Líder: ${questionario.liderNome}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy,
                          color: Color.fromARGB(255, 69, 12, 126)),
                      onPressed: () async {
                        await questionarioProvider
                            .duplicarQuestionario(questionario);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Questionário duplicado com sucesso!')),
                          );
                        }
                      },
                    ),
                    if (!questionario.ativo)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await questionarioProvider
                              .excluirQuestionario(questionario.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Questionário excluído com sucesso!')),
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
