import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_provider.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class WidgetLinhaUnicaOremailForm extends StatefulWidget {
  final Questao questao;
  final bool isFormulario;

  const WidgetLinhaUnicaOremailForm({
    super.key,
    required this.questao,
    this.isFormulario = true,
  });

  @override
  State<WidgetLinhaUnicaOremailForm> createState() =>
      _WidgetLinhaUnicaOremailFormState();
}

class _WidgetLinhaUnicaOremailFormState
    extends State<WidgetLinhaUnicaOremailForm> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Busca a resposta existente no Provider
    final respostaProvider =
        Provider.of<RespostaProvider>(context, listen: false);
    final respostaSalva =
        respostaProvider.obterResposta(widget.questao.id ?? '');

    _controller = TextEditingController(
      text: respostaSalva?.toString() ?? '',
    );

    // Listener para atualizar o Provider quando o texto mudar
    _controller.addListener(_atualizarResposta);
  }

  void _atualizarResposta() {
    if (widget.questao.id != null) {
      Provider.of<RespostaProvider>(context, listen: false)
          .adicionarResposta(widget.questao.id!, _controller.text);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_atualizarResposta);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Adicionado: Exibe imagem se houver URL
            if (widget.questao.imagemUrl != null)
              Padding(
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
              ),

            Text(widget.questao.textoQuestao),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: widget.questao.tipoQuestao == QuestaoTipo.LinhaUnica
                    ? 'Resposta'
                    : 'Digite seu e-mail',
              ),
              maxLines: 1,
              maxLength: (MediaQuery.of(context).size.width / 11).floor(),
            ),
          ],
        ),
      ),
    );
  }
}
