import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Componentes/widget_opcoes_imagem.dart';

class WidgetMultiplaEscolha extends StatefulWidget {
  final Questao questao;
  final String? bancoId;

  const WidgetMultiplaEscolha({super.key, required this.questao, this.bancoId});

  @override
  State<WidgetMultiplaEscolha> createState() => _WidgetMultiplaEscolhaState();
}

class _WidgetMultiplaEscolhaState extends State<WidgetMultiplaEscolha> {
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
      // Armazena a imagem localmente na questão
      widget.questao.imagemLocal = image;
      // Se estava usando uma imagem remota, marca para remoção
      if (image == null && widget.questao.imagemUrl != null) {
        widget.questao.imagemUrl = null;
      }
    });
  }

  Widget _buildImagePreview() {
    // Prioridade para imagem local (se estiver sendo editada)
    if (widget.questao.imagemLocal != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Image.memory(
          widget.questao.imagemLocal!,
          height: 500,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    // Se tem URL remota
    else if (widget.questao.imagemUrl != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
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
    return const SizedBox.shrink(); // Nenhuma imagem
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
        color: Colors.white,
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
                      bancoList.removerQuestao(widget.bancoId, widget.questao);
                    },
                    icon: const Icon(Icons.delete),
                  ),
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

              // Exibição da imagem (local ou remota)
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
                      IconButton(
                        onPressed: () {},
                        icon: widget.questao.tipoQuestao ==
                                QuestaoTipo.MultiPlaEscolha
                            ? const Icon(Icons.check_box)
                            : const Icon(Icons.check_circle),
                      ),
                      Expanded(
                        child: TextField(
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
}
