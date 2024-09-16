import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/QuestionarioProvider%20.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetMultiplaEscolha extends StatefulWidget {
  final Questao questao;

  const WidgetMultiplaEscolha({Key? key, required this.questao}) : super(key: key);

  @override
  State<WidgetMultiplaEscolha> createState() => _WidgetMultiplaEscolhaState();
}

class _WidgetMultiplaEscolhaState extends State<WidgetMultiplaEscolha> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _perguntaController = TextEditingController(text: widget.questao.titulo);
    _initializeOptionControllers();
  }

  void _initializeOptionControllers() {
    _optionControllers.clear();
    for (var resposta in widget.questao.respostas) {
      _optionControllers.add(TextEditingController(text: resposta));
    }
  }

  @override
  void dispose() {
    _perguntaController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionarioProvider = Provider.of<QuestionarioProvider>(context, listen: false);

    return Container(
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _perguntaController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Digite sua pergunta aqui',
                ),
                onChanged: (value) {
                  widget.questao.titulo = value;
                  questionarioProvider.adicionarOuAtualizarQuestao(widget.questao);
                },
              ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(
                  _optionControllers.length,
                  (index) => Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Opção ${index + 1}',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            widget.questao.respostas[index] = value;
                            questionarioProvider.adicionarOuAtualizarQuestao(widget.questao);
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _optionControllers.removeAt(index);
                            widget.questao.respostas.removeAt(index);
                            questionarioProvider.adicionarOuAtualizarQuestao(widget.questao);
                          });
                        },
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _optionControllers.add(TextEditingController(text: ''));
                        widget.questao.respostas.add('');
                      });
                    },
                    child: Text("Adicionar outra opção"),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      questionarioProvider.removerQuestao(widget.questao.id);
                    },
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
