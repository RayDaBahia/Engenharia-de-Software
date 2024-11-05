import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Componentes/WidgetOpcoesImagem.dart';

class WidgetListaSuspensa extends StatefulWidget {
  final Questao questao;
  final String? bancoId;

  const WidgetListaSuspensa({super.key, required this.questao, this.bancoId});

  @override
  State<WidgetListaSuspensa> createState() => _WidgetListaSuspensaState();
}

class _WidgetListaSuspensaState extends State<WidgetListaSuspensa> {
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

  void _handleImageSelected(Uint8List? image) {
    setState(() {
      selectedImage = image; // Atualiza a imagem selecionada
    });
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
                ],
              ),
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
                          decoration: const InputDecoration(
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
                        icon: const Icon(Icons.close),
                      ),
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
                        icon: const Icon(Icons.image),
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

  Widget dropDown() {
    return DropdownButton<String>(
      hint: const Text(
          'Selecione uma opção'), // Texto exibido quando nada está selecionado
      items: widget.questao.opcoes!.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged:
          null, // Define o onChanged como null para desativar a interação
    );
  }
}
