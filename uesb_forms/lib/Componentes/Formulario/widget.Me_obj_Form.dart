import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class WidgetMeObjForm extends StatefulWidget {
  final Questao questao;

  const WidgetMeObjForm({super.key, required this.questao});

  @override
  _WidgetMeObjFormState createState() => _WidgetMeObjFormState();
}

class _WidgetMeObjFormState extends State<WidgetMeObjForm> {
  // Armazena as opções selecionadas (em um caso de múltipla escolha)
  late List<int> selectedOptions;

  @override
  void initState() {
    super.initState();
    // Inicializa com nenhuma opção selecionada
    selectedOptions = [];
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
    bool isMultipleChoice = widget.questao.tipoQuestao == QuestaoTipo.MultiPlaEscolha; // Verifique o tipo da questão

    return SizedBox(
      width: 300,
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                              groupValue: selectedOptions.isEmpty ? -1 : selectedOptions.first,
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
