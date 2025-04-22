import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WidgetMeObjDinamica extends StatefulWidget {
  final Questao questao;

  WidgetMeObjDinamica({super.key, required this.questao});

  @override
  WidgetMeObjDinamicaState createState() => WidgetMeObjDinamicaState();
}

class WidgetMeObjDinamicaState extends State<WidgetMeObjDinamica> {
  // Armazena as opções selecionadas (em um caso de múltipla escolha)
  late List<Questao> _questoesSelecionadas = [];
  Questionario? questionario;

  late List<int> selectedOptions;
  List<int?> selectedDropdownValues = [];

  @override
  void initState() {
    super.initState();
    selectedOptions = [];

    // Inicializa a lista com nulls para cada opção da questão
    selectedDropdownValues =
        List<int?>.filled(widget.questao.opcoes?.length ?? 0, null);

    // Carregar as questões selecionadas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      questionario =
          ModalRoute.of(context)?.settings.arguments as Questionario?;
      if (questionario != null) {
        Provider.of<QuestionarioList>(context, listen: false)
            .buscarQuestoes(questionario!.id);
      }
      // Verificar se já existe um direcionamento salvo
      _verificarDirecionamento();
    });
  }

  // Função para verificar e recuperar direcionamento salvo
  Future<void> _verificarDirecionamento() async {
    if (widget.questao.id != null) {
      // Recupera a questão do Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('questoes')
          .doc(widget.questao.id)
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        var direcionamento = data['direcionamento'];

        // Se já existir direcionamento, atualiza os valores selecionados
        if (direcionamento != null) {
          setState(() {
            widget.questao.direcionamento =
                Map<String, String>.from(direcionamento);

            // Atualizar os dropdowns com os direcionamentos
            for (int i = 0; i < widget.questao.opcoes!.length; i++) {
              String alternativa = widget.questao.opcoes![i];
              if (widget.questao.direcionamento!.containsKey(alternativa)) {
                String? idQuestaoSelecionada =
                    widget.questao.direcionamento![alternativa];

                // Recuperar o índice da questão selecionada na lista
                int index = _questoesSelecionadas.indexWhere(
                  (questao) => questao.id == idQuestaoSelecionada,
                );

                // Se o índice for válido, atualiza o valor selecionado
                int idx = _questoesSelecionadas
                    .indexWhere((q) => q.id == idQuestaoSelecionada);
                if (idx != -1) {
                  selectedDropdownValues[i] = idx; // mantém zero‑based
                }
              }
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _questoesSelecionadas =
        Provider.of<QuestionarioList>(context, listen: true).listaQuestoes;

    final questaoMap = widget.questao.toMap();

    return SizedBox(
      width: 500,
      child: Card(
        elevation: 5,
        shadowColor: Colors.black,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.questao.textoQuestao != null)
                Text(
                  widget.questao.textoQuestao!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(
                  widget.questao.opcoes?.length ?? 0,
                  (index) => Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: selectedOptions.isEmpty
                            ? -1
                            : selectedOptions.first,
                        onChanged: (int? value) {
                          setState(() {
                            selectedOptions = value != null ? [value] : [];
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          widget.questao.opcoes![index],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        // só atribui se for um índice válido
                        value: selectedDropdownValues[index] != null &&
                                selectedDropdownValues[index]! <
                                    _questoesSelecionadas.length
                            ? selectedDropdownValues[index]
                            : null,
                        hint: const Text("Escolha"),
                        items: [
                          for (int i = 0; i < _questoesSelecionadas.length; i++)
                            if (_questoesSelecionadas[i].id !=
                                widget.questao.id)
                              DropdownMenuItem<int>(
                                value: i, // ZERO‑BASED
                                child: Text(
                                    'Questão ${i + 1}'), // texto continua 1‑based
                              ),
                        ],
                        onChanged: (int? value) async {
                          setState(() {
                            selectedDropdownValues[index] = value;
                            // usa value como índice
                            String alternativa = widget.questao.opcoes![index];
                            String? idQuestaoSelecionada = value != null
                                ? _questoesSelecionadas[value].id // sem -1 aqui
                                : null;

                            widget.questao.direcionamento ??= {};
                            widget.questao.direcionamento![alternativa] =
                                idQuestaoSelecionada;
                          });

                          // Salva no Firestore
                          if (widget.questao.id != null) {
                            await FirebaseFirestore.instance
                                .collection('questoes')
                                .doc(widget.questao.id)
                                .set(widget.questao.toMap());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Direcionamento salvo')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
