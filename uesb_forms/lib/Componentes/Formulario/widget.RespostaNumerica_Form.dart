import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_provider.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetRespostaNumericaForm extends StatefulWidget {
  final Questao questao;

  const WidgetRespostaNumericaForm({super.key, required this.questao});

  @override
  State<WidgetRespostaNumericaForm> createState() =>
      _WidgetRespostaNumericaFormState();
}

class _WidgetRespostaNumericaFormState
    extends State<WidgetRespostaNumericaForm> {
  late TextEditingController _respostaController;

  @override
  void initState() {
    super.initState();
    // Inicializa com a resposta salva no Provider (se existir)
    final respostaSalva = Provider.of<RespostaProvider>(context, listen: false)
        .obterResposta(widget.questao.id ?? '');
    _respostaController = TextEditingController(
      text: respostaSalva?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _respostaController.dispose();
    super.dispose();
  }

  void _salvarResposta(String valor) {
    if (valor.isNotEmpty) {
      Provider.of<RespostaProvider>(context, listen: false)
          .adicionarResposta(widget.questao.id!, int.tryParse(valor) ?? valor);
    }
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NOVO: Exibe imagem se houver URL
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

              // Mantido igual abaixo (todo o resto do código original)
              Text(
                widget.questao.textoQuestao,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              if (widget.questao.opcoes != null &&
                  widget.questao.opcoes!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.questao.opcoes!.map((opcao) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        opcao,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              TextField(
                controller: _respostaController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Digite sua resposta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: _salvarResposta,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
