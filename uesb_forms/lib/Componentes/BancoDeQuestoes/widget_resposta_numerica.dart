import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Componentes/widget_opcoes_imagem.dart';

class WidgetRespostaNumerica extends StatefulWidget {
  final Questao questao;
  final String? bancoId;
  final bool isFormulario;

  const WidgetRespostaNumerica({
    super.key,
    required this.questao,
    this.bancoId,
    this.isFormulario = false,
  });

  @override
  State<WidgetRespostaNumerica> createState() => _WidgetRespostaNumericaState();
}

class _WidgetRespostaNumericaState extends State<WidgetRespostaNumerica> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _perguntaController =
        TextEditingController(text: widget.questao.textoQuestao);
    _initializeOptionControllers();
  }

  void _handleImageSelected(Uint8List? image) {
    setState(() {
      widget.questao.imagemLocal = image;
      if (image == null && widget.questao.imagemUrl != null) {
        widget.questao.imagemUrl = null;
      }
    });
  }

  void _initializeOptionControllers() {
    _optionControllers.clear();
    for (var resposta in widget.questao.opcoes!) {
      _optionControllers.add(TextEditingController(text: resposta));
    }
  }

  Widget _buildImagePreview() {
    if (widget.questao.imagemLocal != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Image.memory(
          widget.questao.imagemLocal!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.questao.imagemUrl != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Image.network(
          widget.questao.imagemUrl!,
          height: 180,
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
            return Container(
              height: 180,
              color: Colors.grey[200],
              child:
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            );
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
    final bancoList = Provider.of<BancoList>(context, listen: false);

    return SizedBox(
      width: 300,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isFormulario)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        bancoList.removerQuestao(
                            widget.bancoId, widget.questao);
                      },
                      icon: const Icon(Icons.delete_outline, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.content_copy, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: WidgetOpcoesImagem(
                                onImageSelected: _handleImageSelected,
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.image_outlined, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              if (!widget.isFormulario) const SizedBox(height: 12),
              _buildImagePreview(),
              const SizedBox(height: 16),
              TextField(
                controller: _perguntaController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelText: 'Digite sua pergunta aqui',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(fontSize: 15),
                onChanged: (value) {
                  widget.questao.textoQuestao = value;
                  bancoList.adicionarQuestaoNaLista(widget.questao);
                },
                readOnly: widget.isFormulario,
              ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(
                  _optionControllers.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[400]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[400]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            style: const TextStyle(fontSize: 15),
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
                            icon: const Icon(Icons.close, size: 22),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (!widget.isFormulario) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _optionControllers.add(TextEditingController(text: ''));
                        widget.questao.opcoes!.add('');
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 6),
                        Text("Adicionar opção"),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
