import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class WidgetMeObjDinamica extends StatefulWidget {
  final Questao questao;

  const WidgetMeObjDinamica({super.key, required this.questao});

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
    // Inicializa com nenhuma opção selecionada
    selectedOptions = [];

    // ERRO AQUI
    _questoesSelecionadas =
        Provider.of<QuestionarioList>(context, listen: true).listaQuestoes;

    selectedDropdownValues =
        List.filled(_questoesSelecionadas.length, null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Recupera os argumentos da navegação e atualiza o estado uma única vez
      questionario =
          ModalRoute.of(context)?.settings.arguments as Questionario?;
      if (questionario != null) {
        // Usando o Provider para carregar as questões
        Provider.of<QuestionarioList>(context, listen: false)
            .buscarQuestoes(questionario!.id);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Função para alterar o estado de uma opção
  void _onOptionChanged(int value, bool selected) {
    setState(() {
      if (selected) {
        selectedOptions.add(value);
      } else {
        selectedOptions.remove(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMultipleChoice = widget.questao.tipoQuestao ==
        QuestaoTipo.MultiPlaEscolha; // Verifique o tipo da questão

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
                      isMultipleChoice
                          ? Checkbox(
                              value: selectedOptions.contains(index),
                              onChanged: (bool? selected) {
                                _onOptionChanged(index, selected ?? false);
                              },
                            )
                          : Radio<int>(
                              value: index,
                              groupValue: selectedOptions.isEmpty
                                  ? -1
                                  : selectedOptions.first,
                              onChanged: (int? value) {
                                setState(() {
                                  selectedOptions =
                                      value != null ? [value] : [];
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
                        value: selectedDropdownValues[index],
                        hint: const Text("Escolha"),
                        items: List.generate(
                          5,
                          (i) => DropdownMenuItem<int>(
                            value: i + 1,
                            child: Text('Questão ${i + 1}'),
                          ),
                        ),
                        onChanged: (int? value) {
                          setState(() {
                            selectedDropdownValues[index] = value;
                          });
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
