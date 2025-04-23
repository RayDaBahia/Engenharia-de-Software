import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Componentes/widget_opcoes_imagem.dart';

class WidgetRanking extends StatefulWidget {
  final Questao questao;
  final String? bancoId;
  final bool isFormulario; // Novo parâmetro para modo formulário

  const WidgetRanking({
    super.key,
    required this.questao,
    this.bancoId,
    this.isFormulario = false, // Padrão: modo edição
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
      // Armazena a imagem localmente na questão
      widget.questao.imagemLocal = image;
      // Se estava usando uma imagem remota e substituiu por nenhuma, marca para remoção
      if (image == null && widget.questao.imagemUrl != null) {
        widget.questao.imagemUrl = null;
      }
    });
    _atualizarQuestao();
  }

  Widget _buildImagePreview() {
    // Prioridade para imagem local (se estiver sendo editada)
    if (widget.questao.imagemLocal != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Image.memory(
          widget.questao.imagemLocal!,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    // Se tem URL remota
    else if (widget.questao.imagemUrl != null) {
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
    return const SizedBox.shrink(); // Nenhuma imagem
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
              // Botões de ação (só no modo edição)
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

              // Exibição da imagem
              _buildImagePreview(),

              // Campo de pergunta
              TextField(
                controller: _perguntaController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Digite sua pergunta aqui',
                ),
                onChanged: (value) {
                  widget.questao.textoQuestao = value;
                  _atualizarQuestao();
                },
                readOnly: widget.isFormulario, // Só edita no modo edição
              ),

              const SizedBox(height: 20),

              // Opções de ranking
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Coluna de alternativas
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
                                    labelText: 'Opção ${index + 1}',
                                  ),
                                  onChanged: (value) => _atualizarQuestao(),
                                  readOnly: widget.isFormulario,
                                ),
                              ),
                              if (!widget
                                  .isFormulario) // Só mostra botão de remover no modo edição
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _controleAlternativas.removeAt(index);
                                      widget.questao.opcoes?.removeAt(index);
                                      _atualizarQuestao();
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                        if (!widget
                            .isFormulario) // Só mostra botão de adicionar no modo edição
                          ElevatedButton(
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Coluna de níveis (classificação)
                  if (!widget.isFormulario) // Só mostra no modo edição
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(
                            _controleNiveis.length,
                            (index) => TextField(
                              controller: _controleNiveis[index],
                              decoration: const InputDecoration(
                                labelText: 'Classificação',
                              ),
                              onChanged: (value) => _atualizarQuestao(),
                            ),
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
