import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetRankingForm extends StatefulWidget {
  final Questao questao;

  const WidgetRankingForm({super.key, required this.questao});

  @override
  State<WidgetRankingForm> createState() => _WidgetRankingFormState();
}

class _WidgetRankingFormState extends State<WidgetRankingForm> {
  late List<String> opcoesRanking;
  late List<String> ordemRanking;
  late List<String> classificacoesSelecionadas;
  late Map<String, String> respostasTemporarias;

  @override
  void initState() {
    super.initState();

    opcoesRanking = widget.questao.opcoesRanking ?? [];
    ordemRanking = widget.questao.ordemRanking ?? [];

    if (ordemRanking.isEmpty && opcoesRanking.isNotEmpty) {
      ordemRanking = List.generate(opcoesRanking.length, (index) => (index + 1).toString());
    }

    if (widget.questao.respostaRanking == null) {
      widget.questao.respostaRanking = {};
    }

    respostasTemporarias = Map.from(widget.questao.respostaRanking!);
    classificacoesSelecionadas = respostasTemporarias.values.toList();
  }

  void _atualizarQuestao() {
    widget.questao.opcoesRanking = opcoesRanking;
    widget.questao.ordemRanking = ordemRanking;
    widget.questao.respostaRanking = Map.from(respostasTemporarias);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 5,
        shadowColor: Colors.black,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.questao.textoQuestao,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (opcoesRanking.isNotEmpty) ...[
                const Text(
                  'Opções de Ranking:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                ...opcoesRanking.asMap().entries.map((entry) {
                  int index = entry.key;
                  String opcao = entry.value;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(opcao),
                      DropdownButton<String>(
                        key: ValueKey(opcao),
                        value: respostasTemporarias[opcao],
                        hint: const Text('Classifique'),
                        onChanged: (String? newValue) {
                          setState(() {
                            if (newValue != null && !respostasTemporarias.containsValue(newValue)) {
                              if (respostasTemporarias[opcao] != null) {
                                classificacoesSelecionadas.remove(respostasTemporarias[opcao]);
                              }
                              classificacoesSelecionadas.add(newValue);
                              respostasTemporarias[opcao] = newValue;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Esse número já foi selecionado!')),
                              );
                            }
                          });
                          _atualizarQuestao();
                        },
                        items: List.generate(opcoesRanking.length, (i) {
                          String value = (i + 1).toString();
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).where((item) {
                          // Garante que o item selecionado esteja sempre na lista
                          return !respostasTemporarias.containsValue(item.value) || item.value == respostasTemporarias[opcao];
                        }).toList(),
                      ),
                    ],
                  );
                }).toList(),
              ],
              ElevatedButton(
                onPressed: () {
                  _atualizarQuestao();
                },
                child: const Text('Salvar Ranking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}