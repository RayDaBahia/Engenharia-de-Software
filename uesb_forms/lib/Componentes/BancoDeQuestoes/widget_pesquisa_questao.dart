import 'package:flutter/material.dart';

class WidgetPesquisaQuestao extends StatefulWidget {
  const WidgetPesquisaQuestao({super.key});

  @override
  State<WidgetPesquisaQuestao> createState() => _WidgetPesquisaQuestaoState();
}

class _WidgetPesquisaQuestaoState extends State<WidgetPesquisaQuestao> {
   late TextEditingController pesquisaQuestao;

   @override
  void initState() {
    // TODO: implement initState
    pesquisaQuestao= TextEditingController(text: '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.9,
            child: Expanded(
              child: TextField(
                controller: pesquisaQuestao,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Pesquisar Questao',
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
