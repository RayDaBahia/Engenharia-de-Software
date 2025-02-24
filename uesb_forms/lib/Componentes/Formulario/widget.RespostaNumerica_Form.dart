import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetRespostaNumericaForm extends StatefulWidget {
  final Questao questao;

  const WidgetRespostaNumericaForm({super.key, required this.questao});

  @override
  State<WidgetRespostaNumericaForm> createState() => _WidgetRespostaNumericaFormState();
}

class _WidgetRespostaNumericaFormState extends State<WidgetRespostaNumericaForm> {
  late TextEditingController _respostaController;

  @override
  void initState() {
    super.initState();
    _respostaController = TextEditingController();
  }

  @override
  void dispose() {
    _respostaController.dispose();
    super.dispose();
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
         
              // Exibir a pergunta
              Text(
                widget.questao.textoQuestao,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // Exibir respostas numéricas, se houver
              if (widget.questao.opcoes != null && widget.questao.opcoes!.isNotEmpty)
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

              // Campo para resposta numérica
              TextField(
                enabled: false,
                controller: _respostaController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Digite sua resposta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
