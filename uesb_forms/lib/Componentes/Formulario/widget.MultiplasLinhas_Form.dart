import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetMultiplaslinhasForm extends StatefulWidget {
  final Questao questao;

  const WidgetMultiplaslinhasForm ({super.key, required this.questao});

  @override
  _WidgetMultiplaslinhasFormState createState() => _WidgetMultiplaslinhasFormState();
}

class _WidgetMultiplaslinhasFormState extends State<WidgetMultiplaslinhasForm > {
  late TextEditingController controleResposta;

  @override
  void initState() {
    super.initState();
    controleResposta = TextEditingController();
  }

  @override
  void dispose() {
    controleResposta.dispose();
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
      
            Text(
              widget.questao.textoQuestao,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: controleResposta,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Digite sua resposta',
              ),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
