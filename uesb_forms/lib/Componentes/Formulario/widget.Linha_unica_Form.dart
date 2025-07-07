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
  bool emailInvalido = false;

  @override
  void initState() {
    super.initState();
    final respostaProvider =
        Provider.of<RespostaProvider>(context, listen: false);
    final respostaSalva =
        respostaProvider.obterResposta(widget.questao.id ?? '');

    _controller = TextEditingController(text: respostaSalva?.toString() ?? '');
    _controller.addListener(_atualizarResposta);
  }

  void _atualizarResposta() {
    if (widget.questao.id != null) {
      if (widget.questao.tipoQuestao == QuestaoTipo.LinhaUnica) {
        Provider.of<RespostaProvider>(context, listen: false)
            .adicionarResposta(widget.questao.id!, _controller.text);
      } else {
        addQuestaoEmail(_controller.text);
      }
    }
  }

  void addQuestaoEmail(String text) {
    bool valido = validarEmail(text);

  
Provider.of<RespostaProvider>(context, listen: false)
    .adicionarResposta(widget.questao.id!, text);

setState(() {
  emailInvalido = !valido;
});

  }

  bool validarEmail(String email) {
    final RegExp regex = RegExp(
      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
    );
    return regex.hasMatch(email);
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
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
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
            Text(widget.questao.textoQuestao, style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),),
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
              keyboardType:
                  widget.questao.tipoQuestao == QuestaoTipo.Email ? TextInputType.emailAddress : TextInputType.text,
            ),
            if (emailInvalido && widget.questao.tipoQuestao == QuestaoTipo.Email)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'E-mail inválido',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
