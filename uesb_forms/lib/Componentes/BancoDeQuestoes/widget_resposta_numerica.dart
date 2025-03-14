import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Componentes/WidgetOpcoesImagem.dart';

class WidgetRespostaNumerica extends StatefulWidget {
  final Questao questao;
  final String? bancoId;

  const WidgetRespostaNumerica(
      {super.key, required this.questao, this.bancoId});

  @override
  State<WidgetRespostaNumerica> createState() => _WidgetMultiplaEscolhaState();
}

class _WidgetMultiplaEscolhaState extends State<WidgetRespostaNumerica> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _optionControllers = [];
  Uint8List? selectedImage;

  @override
  void initState() {
    super.initState();
    _perguntaController =
        TextEditingController(text: widget.questao.textoQuestao);
    _initializeOptionControllers();
  }

  void _handleImageSelected(Uint8List? image) {
    setState(() {
      selectedImage = image; // Atualiza a imagem selecionada
    });
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

    return SizedBox(
      width: 300,
      child: Card(
        elevation: 5,
        shadowColor: Colors.black,
        color: Colors.white, // Cor de fundo do card
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
                      icon: const Icon(Icons.delete)),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.copy_sharp)),
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: WidgetOpcoesImagem(
                                onImageSelected: (image) {
                                  _handleImageSelected(
                                      image); // Atualiza a imagem selecionada
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.image)),
                  // Exibir a imagem selecionada, se houver
                  if (selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Image.memory(
                        selectedImage!,
                        height: 500,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
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
              const SizedBox(height: 20),
              Column(
                children: List.generate(
                  _optionControllers.length,
                  (index) => Row(
                    children: [
                      Expanded(
                        child: TextField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: TextInputType.number,
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Opção ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            widget.questao.opcoes![index] = value;
                            bancoList.adicionarQuestaoNaLista(widget.questao);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _optionControllers.removeAt(index);

                            widget.questao.opcoes!.removeAt(index);

                            bancoList.adicionarQuestaoNaLista(widget.questao);
                          });
                        },
                        icon: const Icon(Icons.close),
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
                        widget.questao.opcoes!.add('');
                      });
                    },
                    child: const Text("Adicionar outra opção"),
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
