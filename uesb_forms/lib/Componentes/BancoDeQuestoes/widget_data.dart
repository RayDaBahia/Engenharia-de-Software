import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetData extends StatefulWidget {
  final String? idBanco;
  final Questao questao;

  const WidgetData({super.key, required this.questao, this.idBanco});

  @override
  State<WidgetData> createState() => _WidgetDataState();
}

class _WidgetDataState extends State<WidgetData> {
  late TextEditingController controlePergunta;

  late TextEditingController controleResposta;

  @override
  void initState() {
    controlePergunta = TextEditingController(text: widget.questao.textoQuestao);
    controleResposta = TextEditingController(text: '');

    super.initState();
  }

  void _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),

// estratégia quando tenho algo assincrono, algo que será chamado quando algo acontecer.
    ).then((DateTime? pickedDate) {
      if (pickedDate == null) {
        return;
      }

// estratégia quando tenho algo assincrono, algo que será chamado quando algo acontecer.
      setState(() {
       
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: false);

    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: controlePergunta,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Digite a pergunta'),
                  onChanged: (value) {
                    widget.questao.textoQuestao = value;
                    bancoList.adicionarQuestaoNaLista(widget.questao);
                  },
                ),
                SizedBox(height: 30,),
                
                Row(
                  
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _selectDate,
                      child: Icon(Icons.calendar_month)
                    ),
                    Padding(
                      padding: EdgeInsets.all(10)),
                    Spacer(),
                    IconButton(
                        onPressed: () {
                          bancoList.removerQuestao(
                              widget.idBanco, widget.questao);
                        },
                        icon: Icon(Icons.delete)),
                  ],
                ),
              ],
            )));
  }
}
