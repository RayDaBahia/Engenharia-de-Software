import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Componentes/widget_opcoes_imagem.dart';

class WidgetCaptura extends StatefulWidget {
  final Questao questao;
  final String? bancoId;
  final bool isFormulario;

  const WidgetCaptura({
    Key? key,
    required this.questao,
    this.bancoId,
    this.isFormulario = false,
  }) : super(key: key);

  @override
  State<WidgetCaptura> createState() => _WidgetCapturaState();
}

class _WidgetCapturaState extends State<WidgetCaptura> {
  late TextEditingController _perguntaController;

  @override
  void initState() {
    super.initState();
    _perguntaController = TextEditingController(
      text: widget.questao.textoQuestao,
    );
    widget.questao.tipoQuestao = QuestaoTipo.Captura;
  }

  void _handleImageSelected(Uint8List? image) {
    setState(() {
      widget.questao.imagemLocal = image;
      if (image == null && widget.questao.imagemUrl != null) {
        widget.questao.imagemUrl = null;
      }
    });
  }

  Widget _buildImageResponseArea() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              'Resposta por imagem',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (widget.questao.imagemLocal != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Image.memory(
          widget.questao.imagemLocal!,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      );
    } else if (widget.questao.imagemUrl != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Image.network(
          widget.questao.imagemUrl!,
          width: double.infinity,
          fit: BoxFit.contain,
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
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: false);

    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!widget.isFormulario)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () async {
                      await Provider.of<BancoList>(
                        context,
                        listen: false,
                      ).removerQuestao(widget.bancoId, widget.questao);

                    if (mounted) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Questão excluída com sucesso!')),
    );
  });
}
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

            _buildImagePreview(),

            TextField(
              controller: _perguntaController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Digite a pergunta',
              ),
              onChanged: (value) {
                widget.questao.textoQuestao = value;
                bancoList.adicionarQuestaoNaLista(widget.questao);
              },
              readOnly: widget.isFormulario,
            ),

            const SizedBox(height: 20),

            // Área de resposta (sempre desabilitada no modelo)
            _buildImageResponseArea(),
          ],
        ),
      ),
    );
  }

  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating, // Faz ele "flutuar" acima da UI
        margin: const EdgeInsets.all(16), // Margem nas bordas
        duration: const Duration(seconds: 3), // Tempo que ele fica visível
      ),
    );
  }

  @override
  void dispose() {
    _perguntaController.dispose();
    super.dispose();
  }
}
