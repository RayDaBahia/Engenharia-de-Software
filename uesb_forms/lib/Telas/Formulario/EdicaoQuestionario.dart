import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Telas/Formulario/TelaDinamizarQuestao.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class EdicaoQuestionario extends StatefulWidget {
  // Permita receber pela rota  de modo opcional questionario  que será utilizado para a edição do questionário.
  const EdicaoQuestionario({super.key});

  @override
  _EdicaoQuestionarioState createState() => _EdicaoQuestionarioState();
}

class _EdicaoQuestionarioState extends State<EdicaoQuestionario> {
  late List<Questao> _questoesSelecionadas = [];
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _metaController = TextEditingController();
  String? _preenchidoPor;
  bool isEdicaoQuestionario = false;
  Questionario? questionario;
  bool expandido = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Recupera os argumentos da navegação e atualiza o estado uma única vez
      questionario =
          ModalRoute.of(context)?.settings.arguments as Questionario?;
      if (questionario != null) {
        isEdicaoQuestionario = true;
        _nomeController.text = questionario!.nome;
        _descricaoController.text = questionario!.descricao;
        _metaController.text = questionario!.meta.toString();

        // Usando o Provider para carregar as questões
        Provider.of<QuestionarioList>(
          context,
          listen: false,
        ).buscarQuestoes(questionario!.id);

        Provider.of<QuestionarioList>(
          context,
          listen: false,
        ).salvarOrdemQuestoes(questionario!.id);
      }
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  void _adicionarMaisQuestoes(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamed(Rotas.MEUS_BANCOS, arguments: {'isFormulario': true});
  }

  @override
  Widget build(BuildContext context) {
    _questoesSelecionadas = Provider.of<QuestionarioList>(context, listen: true)
        .listaQuestoes
        .where((q) {
          return q.textoQuestao.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
        })
        .toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _questoesSelecionadas.clear();
            Provider.of<QuestionarioList>(
              context,
              listen: false,
            ).limparQuestoes();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Edição ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_nomeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'É necessário definir um título para o questionário',
                      ),
                    ),
                  );
                  return;
                }

                if (!isEdicaoQuestionario) {
                  Provider.of<QuestionarioList>(
                    context,
                    listen: false,
                  ).setDadosTemporarios(
                    listaDeQuestoes: _questoesSelecionadas,
                    nome: _nomeController.text.isEmpty
                        ? 'Sem título'
                        : _nomeController.text,
                    descricao: _descricaoController.text.isEmpty
                        ? 'Sem descrição'
                        : _descricaoController.text,
                    meta: _metaController.text.isEmpty
                        ? '0'
                        : _metaController.text,
                  );
                  Navigator.pushNamed(context, Rotas.CONFIGURAR_ACESSO_FORMS);
                } else {
                  questionario!.nome = _nomeController.text;
                  questionario!.descricao = _descricaoController.text;
                  questionario!.meta = int.parse(_metaController.text);
                  Provider.of<QuestionarioList>(
                    context,
                    listen: false,
                  ).listaQuestoes = List.from(
                    _questoesSelecionadas,
                  );

                  await Provider.of<QuestionarioList>(
                    context,
                    listen: false,
                  ).atualizarQuestionario(questionario!);

                  _questoesSelecionadas.clear();

                  showSuccessMessage(
                    context,
                    "Questionário atualizado com sucesso",
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              ),
              child: isEdicaoQuestionario
                  ? const Text(
                      'Concluir',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 1, 21, 37),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Text(
                      'Próximo',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 1, 21, 37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CampoTexto(
                    controller: _nomeController,
                    label: "Título",
                    maxLength: 60,
                  ),
                  const SizedBox(height: 5),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // 👈 alinha à esquerda
                      children: [
                        CampoNumero(controller: _metaController, label: "Meta"),
                        const SizedBox(height: 12),
                        Text(
                          'Descrição',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _descricaoController,
                          maxLines:
                              null, // Permite que o campo de descrição cresça conforme necessário
                          maxLength: 150, // Limite de 150 caracteres
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ), // mesmo raio nos dois
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            hintText: 'Adicione uma descrição ao questionário',
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                          onChanged: (text) {
                            setState(
                              () {},
                            ); // Atualiza a UI para o contador de caracteres
                          },
                        ),
                        const SizedBox(height: 10),
                        // CAMPO DE PESQUISA
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (query) =>
                                setState(() => _searchQuery = query),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // mesmo raio nos dois
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              labelText: 'Pesquisar questão por título',
                              prefixIcon: const Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _questoesSelecionadas.isEmpty
                  ? const Center(child: Text("Nenhuma questão selecionada"))
                  : ListView.builder(
                      itemCount: _questoesSelecionadas.length,
                      itemBuilder: (context, index) {
                        final questao = _questoesSelecionadas[index];
                        return ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Coluna da esquerda (texto e widget)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Questão ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    QuestaoWidgetForm(questao: questao),
                                  ],
                                ),
                              ),
                              // Coluna da direita (ícones e dropdown)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 30),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: questionario == null
                                        ? () async {
                                            setState(() {
                                              Provider.of<QuestionarioList>(
                                                context,
                                                listen: false,
                                              ).excluirQuestaoSelecionada(
                                                index,
                                              );
                                            });

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Questão excluída com sucesso',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        : () async {
                                            setState(() {
                                              Provider.of<QuestionarioList>(
                                                context,
                                                listen: false,
                                              ).excluirQuestaoSelecionada(
                                                index,
                                                questionario!.id,
                                              );
                                            });

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Questão excluída com sucesso',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                  ),

                                  // Para cima
                                  IconButton(
                                    tooltip:
                                        "Permite levar a questão para posição acima",
                                    icon: const Icon(
                                      Icons.arrow_upward,
                                      color: Colors.blue,
                                    ),
                                    // Botão "Para Cima" (↑)
                                    onPressed: () async {
                                      if (index > 0) {
                                        final provider =
                                            Provider.of<QuestionarioList>(
                                              context,
                                              listen: false,
                                            );
                                        provider.moverQuestaoAcima(
                                          index,
                                        ); // Método novo no Provider
                                        if (questionario != null) {
                                          await provider.salvarOrdemQuestoes(
                                            questionario!.id,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  // Para baixo
                                  IconButton(
                                    tooltip:
                                        "Permite levar a questão para posição abaixo",
                                    icon: const Icon(
                                      Icons.arrow_downward,
                                      color: Colors.blue,
                                    ),
                                    // Botão "Para Baixo" (↓)
                                    onPressed: () async {
                                      if (index <
                                          _questoesSelecionadas.length - 1) {
                                        final provider =
                                            Provider.of<QuestionarioList>(
                                              context,
                                              listen: false,
                                            );
                                        provider.moverQuestaoAbaixo(
                                          index,
                                        ); // Método novo no Provider
                                        if (questionario != null) {
                                          await provider.salvarOrdemQuestoes(
                                            questionario!.id,
                                          );
                                        }
                                      }
                                    },
                                  ),

                                  if ([QuestaoTipo.Objetiva]
                                      .map((e) => e.toString())
                                      .contains(
                                        questao.tipoQuestao.toString(),
                                      )) ...[
                                    IconButton(
                                      icon: const Icon(
                                        Icons.sync,
                                        color: Color.fromARGB(255, 42, 0, 57),
                                      ),
                                      tooltip:
                                          "Permite definir a próxima pergunta com base na alternativa",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                Teladinamizarquestao(
                                                  questaoSelecionada: questao,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          subtitle: CheckboxListTile(
                            title: const Text("Questão obrigatória"),
                            value: questao.obrigatoria,
                            onChanged: (bool? value) {
                              setState(() {
                                questao.obrigatoria = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarMaisQuestoes(context),
        backgroundColor: const Color.fromARGB(255, 21, 3, 44),
        child: const Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
      ),
    );
  }
}

void showSuccessMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating, // Faz ele "flutuar" acima da UI
      margin: const EdgeInsets.all(16), // Margem nas bordas
      duration: const Duration(seconds: 3), // Tempo que ele fica visível
    ),
  );
}

class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int? maxLength;

  const CampoTexto({
    super.key,
    required this.label,
    required this.controller,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: controller, maxLength: maxLength),
      ],
    );
  }
}

class CampoNumero extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const CampoNumero({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        // const SizedBox(height: 2),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}
