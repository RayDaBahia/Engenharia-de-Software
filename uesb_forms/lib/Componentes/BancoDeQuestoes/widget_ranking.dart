import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Componentes/widget_opcoes_imagem.dart';

class WidgetRanking extends StatefulWidget {
  final Questao questao;
  final String? bancoId;
  final bool isFormulario;

  const WidgetRanking({
    super.key,
    required this.questao,
    this.bancoId,
    this.isFormulario = false,
  });

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
    _atualizarQuestao();
  }

  Widget _buildImagePreview() {
    if (widget.questao.imagemLocal != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Image.memory(
          widget.questao.imagemLocal!,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.questao.imagemUrl != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Image.network(
          widget.questao.imagemUrl!,
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
    for (var controller in _controleAlternativas) {
      controller.dispose();
    }
    for (var controller in _controleNiveis) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeOptionControllers() {
    _controleAlternativas.clear();
    _controleNiveis.clear();

    if (widget.questao.opcoes != null) {
      for (var alternativa in widget.questao.opcoes!) {
        _controleAlternativas.add(TextEditingController(text: alternativa));
      }
    }
  }

  void _atualizarQuestao() {
    widget.questao.opcoes = _controleAlternativas.map((c) => c.text).toList();
    final bancoList = Provider.of<BancoList>(context, listen: false);
    bancoList.adicionarQuestaoNaLista(widget.questao);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 5,
        shadowColor: Colors.black,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isFormulario)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Provider.of<BancoList>(context, listen: false)
                            .removerQuestao(widget.bancoId, widget.questao);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: WidgetOpcoesImagem(
                              onImageSelected: _handleImageSelected,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.image),
                    ),
                  ],
                ),
              _buildImagePreview(),
              TextField(
                controller: _perguntaController,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Digite sua pergunta aqui',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  widget.questao.textoQuestao = value;
                  _atualizarQuestao();
                },
                readOnly: widget.isFormulario,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(
                          _controleAlternativas.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: 12), // Espaço entre opções
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controleAlternativas[index],
                                    decoration: InputDecoration(
                                      labelText: 'Opção ${index + 1}',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                    ),
                                    onChanged: (value) => _atualizarQuestao(),
                                    readOnly: widget.isFormulario,
                                  ),
                                ),
                                if (!widget.isFormulario)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _controleAlternativas.removeAt(index);
                                          widget.questao.opcoes
                                              ?.removeAt(index);
                                          _atualizarQuestao();
                                        });
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (!widget.isFormulario)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _controleAlternativas
                                      .add(TextEditingController(text: ''));
                                  widget.questao.opcoes?.add('');
                                });
                                _atualizarQuestao();
                              },
                              child: const Text("Adicionar outra opção"),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!widget.isFormulario) ...[
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(
                            _controleNiveis.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextField(
                                controller: _controleNiveis[index],
                                decoration: InputDecoration(
                                  labelText: 'Classificação',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                                onChanged: (value) => _atualizarQuestao(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
