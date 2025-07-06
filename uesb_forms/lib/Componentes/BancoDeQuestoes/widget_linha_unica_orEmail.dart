import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Componentes/widget_opcoes_imagem.dart';

class WidgetLinhaUnicaOremail extends StatefulWidget {
  final String? idBanco;
  final Questao questao;
  final bool isFormulario; // Indica se está no modo de preenchimento

  const WidgetLinhaUnicaOremail({
    Key? key,
    required this.questao,
    this.idBanco,
    this.isFormulario = false, // Padrão: modo edição
  }) : super(key: key);

  @override
  State<WidgetLinhaUnicaOremail> createState() =>
      _WidgetLinhaUnicaOremailState();
}

class _WidgetLinhaUnicaOremailState extends State<WidgetLinhaUnicaOremail> {
  late TextEditingController controlePergunta;
  late TextEditingController controleResposta;

  @override
  void initState() {
    super.initState();
    controlePergunta = TextEditingController(text: widget.questao.textoQuestao);
    controleResposta = TextEditingController(text: '');
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
      return Image.memory(
        widget.questao.imagemLocal!,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    }
    // Se tem URL remota
    else if (widget.questao.imagemUrl != null) {
      return Image.network(
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
          return const Icon(Icons.broken_image);
        },
      );
    }
    return Container(); // Nenhuma imagem
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: false);

    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!widget.isFormulario) ...[
                  IconButton(
                    onPressed: () {
                      bancoList.removerQuestao(widget.idBanco, widget.questao);
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
              ],
            ),
            if (widget.questao.imagemLocal != null ||
                widget.questao.imagemUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildImagePreview(),
              ),
            TextField(
              controller: controlePergunta,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: 'Digite a pergunta',
              ),
              onChanged: (value) {
                widget.questao.textoQuestao = value;
                bancoList.adicionarQuestaoNaLista(widget.questao);
              },
              readOnly: widget.isFormulario, // Só edita se não for formulário
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controleResposta,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: widget.questao.tipoQuestao == QuestaoTipo.LinhaUnica
                    ? 'Resposta'
                    : 'Digite seu e-mail',
              ),
              enabled: widget.isFormulario, // Só habilita no formulário
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controlePergunta.dispose();
    controleResposta.dispose();
    super.dispose();
  }
}
