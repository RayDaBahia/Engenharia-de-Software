import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class WidgetListaSuspensa extends StatefulWidget {
  final Questao questao;
  final String? bancoId;

  const WidgetListaSuspensa({Key? key, required this.questao, this.bancoId})
      : super(key: key);

  @override
  State<WidgetListaSuspensa> createState() => _WidgetMultiplaEscolhaState();
}

class _WidgetMultiplaEscolhaState extends State<WidgetListaSuspensa> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _perguntaController =
        TextEditingController(text: widget.questao.textoQuestao);
    _initializeOptionControllers();
  }

  void _initializeOptionControllers() {
    _optionControllers.clear();
    for (var resposta in widget.questao.opcoes!) {
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
    final bancoList = Provider.of<BancoList>(context, listen: false);

    return Container(
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        bancoList.removerQuestao(
                            widget.bancoId, widget.questao);
                      },
                      icon: Icon(Icons.delete)),
                  IconButton(onPressed: () {
                 
                  }, icon: Icon(Icons.copy_sharp)),
                ],
              ),
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
                  widget.questao.textoQuestao = value;
                  bancoList.adicionarQuestaoNaLista(widget.questao);
                },
              ),
              dropDown(),
              const SizedBox(height: 20),
              Column(
                children: List.generate(
                  _optionControllers.length,
                  (index) => Row(
                    children: [
                    Text('${index + 1}.'),

                      Expanded(
                        child: TextField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            widget.questao.opcoes![index] = value;
                            bancoList.adicionarQuestaoNaLista(widget.questao);
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _optionControllers.removeAt(index);

                            widget.questao.opcoes!.removeAt(index);

                            bancoList.adicionarQuestaoNaLista(widget.questao);
                          });
                        },
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _optionControllers.add(TextEditingController(text: ''));
                        widget.questao.opcoes!.add("");
                      });
                    },
                    child: Text("Adicionar outra opção"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


Widget dropDown() {
  return DropdownButton<String>(
    hint: Text('Selecione uma opção'), // Texto exibido quando nada está selecionado
    items: widget.questao.opcoes!.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );
    }).toList(),
    onChanged: null, // Define o onChanged como null para desativar a interação
  );
}


}