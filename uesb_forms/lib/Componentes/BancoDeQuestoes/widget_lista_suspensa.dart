import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Componentes/widget_opcoes_imagem.dart';

class WidgetListaSuspensa extends StatefulWidget {
  final Questao questao;
  final String? bancoId;
  final bool isFormulario;

  const WidgetListaSuspensa({
    super.key,
    required this.questao,
    this.bancoId,
    this.isFormulario = false,
  });

  @override
  State<WidgetListaSuspensa> createState() => _WidgetListaSuspensaState();
}

class _WidgetListaSuspensaState extends State<WidgetListaSuspensa> {
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

  void _handleImageSelected(Uint8List? image) {
    setState(() {
      widget.questao.imagemLocal = image;
      if (image == null && widget.questao.imagemUrl != null) {
        widget.questao.imagemUrl = null;
      }
    });
  }

  Widget _buildImagePreview() {
    if (widget.questao.imagemLocal != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Image.memory(
          widget.questao.imagemLocal!,
          height: 500,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.questao.imagemUrl != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Image.network(
          widget.questao.imagemUrl!,
          height: 500,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 50);
          },
        ),
      );
    }
    return const SizedBox.shrink();
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
    final bancoList = Provider.of<BancoList>(context, listen: true);

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
              if (!widget.isFormulario) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        bancoList.removerQuestao(
                            widget.bancoId, widget.questao);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.copy_sharp)),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: WidgetOpcoesImagem(
                                onImageSelected: _handleImageSelected,
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.image),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              _buildImagePreview(),
              TextField(
                controller: _perguntaController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Digite sua pergunta aqui',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
                onChanged: (value) {
                  widget.questao.textoQuestao = value;
                  bancoList.adicionarQuestaoNaLista(widget.questao);
                },
                readOnly: widget.isFormulario,
              ),
              const SizedBox(height: 16),
              if (!widget.isFormulario) dropDown(),
              const SizedBox(height: 16),
              Column(
                children: List.generate(
                  _optionControllers.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _optionControllers[index],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                            ),
                            onChanged: (value) {
                              widget.questao.opcoes![index] = value;
                              bancoList.adicionarQuestaoNaLista(widget.questao);
                            },
                            enabled: !widget.isFormulario,
                          ),
                        ),
                        if (!widget.isFormulario) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _optionControllers.removeAt(index);
                                widget.questao.opcoes!.removeAt(index);
                                bancoList
                                    .adicionarQuestaoNaLista(widget.questao);
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (!widget.isFormulario) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _optionControllers.add(TextEditingController(text: ''));
                      widget.questao.opcoes!.add("");
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text("Adicionar outra opção"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget dropDown() {
    return DropdownButton<String>(
      isExpanded: true,
      hint: const Text('Selecione uma opção'),
      items: widget.questao.opcoes!.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          if (newValue != null) {
            int index = widget.questao.opcoes!.indexOf(newValue);
            if (index != -1) {
              widget.questao.opcoes![index] = newValue;
            }
          }
        });
      },
    );
  }
}
