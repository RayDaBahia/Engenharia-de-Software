import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetRanking extends StatefulWidget {
  final Questao questao;
  final String? bancoId;

  const WidgetRanking({super.key, required this.questao, this.bancoId});

  @override
  State<WidgetRanking> createState() => _WidgetRankingState();
}

class _WidgetRankingState extends State<WidgetRanking> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _controleAlternativas = [];
  final List<TextEditingController> _controleNiveis = [];

  @override
  void initState() {
    super.initState();
    _perguntaController = TextEditingController(text: widget.questao.textoQuestao);
    _initializeOptionControllers(); // Inicialize controladores
  }

  @override
  void dispose() {
    _perguntaController.dispose();
    for (var controllerP in _controleAlternativas) {
      controllerP.dispose();
    }
    for (var controllerN in _controleNiveis) {
      controllerN.dispose();
    }
    super.dispose();
  }

  void _initializeOptionControllers() {
    _controleAlternativas.clear();
    _controleNiveis.clear(); // Limpe também os níveis

    // Verifique se perguntasRanking não é nulo
    if (widget.questao.opcoesRanking != null) {
      for (var alternativa in widget.questao.opcoesRanking!) {
        _controleAlternativas.add(TextEditingController(text: alternativa));
      }
    }

    // Verifique se opcoesRanking não é nulo
    if (widget.questao.ordemRanking != null) {
      for (var niveis in widget.questao.ordemRanking!) {
        _controleNiveis.add(TextEditingController(text: niveis));
      }
    }
  }

  @override
 @override
Widget build(BuildContext context) {
  final bancoList = Provider.of<BancoList>(context, listen: false);

  return SizedBox(
    width: 300,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _perguntaController,
              maxLines: null,
              decoration: InputDecoration(labelText: 'Digite sua pergunta aqui'),
              onChanged: (value) {
                widget.questao.textoQuestao = value;
                bancoList.adicionarQuestaoNaLista(widget.questao);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinha as colunas
              children: [
                // coluna de alternativas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...List.generate(
                        _controleAlternativas.length,
                        (index) => Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controleAlternativas[index],
                                decoration: InputDecoration(
                                  labelText: 'opção ${index + 1}',
                                ),
                                onChanged: (value) {
                                  widget.questao.opcoesRanking![index] = value;
                                  bancoList.adicionarQuestaoNaLista(widget.questao);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _controleAlternativas.add(TextEditingController(text: ''));
                                widget.questao.opcoesRanking!.add(''); // Adicione um valor padrão
                              });
                            },
                            child: const Text("Adicionar outra opção"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20), // Espaço entre colunas

                // coluna de níveis
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...List.generate(
                        _controleNiveis.length,
                        (index) => Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controleNiveis[index],
                                decoration: InputDecoration(
                                  labelText: 'Classificação ',
                                ),
                                onChanged: (value) {
                                  widget.questao..ordemRanking![index] = value;
                                  bancoList.adicionarQuestaoNaLista(widget.questao);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _controleNiveis.add(TextEditingController(text: ''));
                                widget.questao.ordemRanking!.add(''); // Adicione um valor padrão
                              });
                            },
                            child: const Text("Adicionar Nível"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}


