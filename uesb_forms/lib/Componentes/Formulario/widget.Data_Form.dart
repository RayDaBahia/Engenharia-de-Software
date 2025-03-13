import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetDataForm extends StatefulWidget {
  final Questao questao;

  const WidgetDataForm({super.key, required this.questao});

  @override
  State<WidgetDataForm> createState() => _WidgetDataFormState();
}

class _WidgetDataFormState extends State<WidgetDataForm> {
  late TextEditingController controleResposta;

  @override
  void initState() {
    super.initState();
    controleResposta = TextEditingController(
    //  text: widget.questao.respostaData != null
     //     ? "${widget.questao.respostaData!.toLocal()}".split(' ')[0]
          //: '',
    );
  }

  @override
  void dispose() {
    controleResposta.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
       // widget.questao.respostaData = selectedDate;
        controleResposta.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              widget.questao.textoQuestao,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _selectDate,
                  child: const Icon(Icons.calendar_month),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controleResposta,
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

