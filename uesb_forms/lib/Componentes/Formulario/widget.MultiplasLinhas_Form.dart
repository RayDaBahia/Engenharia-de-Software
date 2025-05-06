import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_provider.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetMultiplaslinhasForm extends StatefulWidget {
  final Questao questao;

  const WidgetMultiplaslinhasForm({super.key, required this.questao});

  @override
  _WidgetMultiplaslinhasFormState createState() =>
      _WidgetMultiplaslinhasFormState();
}

class _WidgetMultiplaslinhasFormState extends State<WidgetMultiplaslinhasForm> {
  late TextEditingController _controleResposta;

  @override
  void initState() {
    super.initState();
    // Busca resposta existente no Provider
    final respostaProvider =
        Provider.of<RespostaProvider>(context, listen: false);
    _controleResposta = TextEditingController(
      text:
          respostaProvider.obterResposta(widget.questao.id ?? '')?.toString() ??
              '',
    );
  }

  @override
  void dispose() {
    _controleResposta.dispose();
    super.dispose();
  }

  void _salvarResposta() {
    if (widget.questao.id != null) {
      Provider.of<RespostaProvider>(context, listen: false)
          .adicionarResposta(widget.questao.id!, _controleResposta.text);
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // Título (mantido igual)
            Text(
              widget.questao.textoQuestao,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Campo de texto (mantido igual)
            TextField(
              controller: _controleResposta,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Digite sua resposta',
              ),
              maxLines: null,
              onChanged: (value) => _salvarResposta(),
            ),
          ],
        ),
      ),
    );
  }
}
