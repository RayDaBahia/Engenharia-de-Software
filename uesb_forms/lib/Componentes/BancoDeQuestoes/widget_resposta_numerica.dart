import 'dart:typed_data';
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
  late TextEditingController _respostaController;

  @override
  void initState() {
    super.initState();
    _perguntaController =
        TextEditingController(text: widget.questao.textoQuestao);
    _respostaController = TextEditingController(); // Não salva a resposta
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
        padding: const EdgeInsets.only(bottom: 10),
        child: Image.memory(
          widget.questao.imagemLocal!,
          height: 500,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.questao.imagemUrl != null) {
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
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _perguntaController.dispose();
    _respostaController.dispose();
    super.dispose();
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
                      await bancoList.removerQuestao(widget.bancoId, widget.questao);
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
              readOnly: widget.isFormulario,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _respostaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: widget.isFormulario, // Habilita só no modo formulário
              decoration: InputDecoration(
                labelText: 'Resposta numérica',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
