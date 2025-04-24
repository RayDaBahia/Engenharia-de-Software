import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetRankingForm extends StatefulWidget {
  final Questao questao;

  const WidgetRankingForm({super.key, required this.questao});

  @override
  State<WidgetRankingForm> createState() => _WidgetRankingFormState();
}

class _WidgetRankingFormState extends State<WidgetRankingForm> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _controleAlternativas = [];
  final List<String> _classificacoesSelecionadas = [];

  /// Agora as opções vêm diretamente do Map de ranking da questão:
  late List<String> _opcoesDeClassificacao;

  @override
  void initState() {
    super.initState();

    // Garante que ranking não seja nulo
    widget.questao.ranking ??= {};

    // Extrai as opções (as chaves do Map) uma única vez
    _opcoesDeClassificacao = widget.questao.ranking!.keys.toList();

    _perguntaController =
        TextEditingController(text: widget.questao.textoQuestao);
    _initializeOptionControllers();
  }

  void _initializeOptionControllers() {
    _controleAlternativas.clear();
    _classificacoesSelecionadas.clear();

    // Para cada par (nivel → alternativa) no Map, cria um TextController
    widget.questao.ranking!.forEach((nivel, alternativa) {
      _controleAlternativas.add(TextEditingController(text: alternativa));
      _classificacoesSelecionadas.add(nivel);
    });
  }

  void _atualizarQuestao() {
    final bancoList = Provider.of<BancoList>(context, listen: false);
    widget.questao.textoQuestao = _perguntaController.text;

    // Reconstrói o Map ranking a partir das listas atuais
    widget.questao.ranking = Map.fromIterables(
      _classificacoesSelecionadas,
      _controleAlternativas.map((c) => c.text),
    );

    bancoList.adicionarQuestaoNaLista(widget.questao);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Pergunta
              Text(
                _perguntaController.text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Lista de alternativas + dropdown de classificação
              Column(
                children: List.generate(_controleAlternativas.length, (i) {
                  return Row(
                    children: [
                      // Alternativa
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _controleAlternativas[i],
                          decoration:
                              InputDecoration(labelText: 'Opção ${i + 1}'),
                          onChanged: (_) => _atualizarQuestao(),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Dropdown de classificação, puxando opções do Map
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _classificacoesSelecionadas[i],
                          decoration:     const InputDecoration(labelText: 'Classificação'),
                         items: _opcoesDeClassificacao   .map((nivel) => DropdownMenuItem(
                                    value: nivel,
                                    child: Text(nivel),
                                  ))
                              .toList(),

                          onChanged: (novoNivel) {
                            setState(() {
                          int velho=  _classificacoesSelecionadas.indexWhere( (nivelNovo) => nivelNovo == novoNivel);
                              if(velho != -1){
                                _classificacoesSelecionadas[velho] = _classificacoesSelecionadas[i];
                              }
                              _classificacoesSelecionadas[i] = novoNivel!;
                            });
                            _atualizarQuestao();
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
