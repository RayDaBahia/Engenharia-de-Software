import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_provider.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetDataForm extends StatefulWidget {
  final Questao questao;

  const WidgetDataForm({super.key, required this.questao});

  @override
  State<WidgetDataForm> createState() => _WidgetDataFormState();
}

class _WidgetDataFormState extends State<WidgetDataForm> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final resposta = Provider.of<RespostaProvider>(context, listen: false)
        .obterResposta(widget.questao.id ?? '');
    _controller = TextEditingController(
      text: resposta != null ? _formatarData(resposta) : '',
    );
  }

  String _formatarData(dynamic data) {
    if (data is DateTime) return "${data.toLocal()}".split(' ')[0];
    return data.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      _controller.text = _formatarData(data);
      Provider.of<RespostaProvider>(context, listen: false)
          .adicionarResposta(widget.questao.id!, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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

            Text(
              widget.questao.textoQuestao,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _selecionarData,
                  child: const Icon(Icons.calendar_month),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: "Selecione uma data",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
