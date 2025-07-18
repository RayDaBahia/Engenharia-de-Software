import 'package:flutter/material.dart';
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
    super.initState();
    controlePergunta = TextEditingController(text: widget.questao.textoQuestao);
    controleResposta = TextEditingController(text: '');
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
      setState(() {});
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: false);

    return Card(
       color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () async {
                      await Provider.of<BancoList>(context, listen: false)
                            .removerQuestao(widget.idBanco, widget.questao);
              if (mounted) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Questão excluída com sucesso!')),
    );
  });
};},
                        icon: const Icon(Icons.delete)),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.image),
                    ),
                  ],
                ),
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
                const SizedBox(
                  height: 30,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: null, child: Icon(Icons.calendar_month)),
                    Padding(padding: EdgeInsets.all(10)),
                    Spacer(),
                  ],
                ),
              ],
            )));
  }

  void showSuccessMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating, // Faz ele "flutuar" acima da UI
      margin: const EdgeInsets.all(16), // Margem nas bordas
      duration: const Duration(seconds: 3), // Tempo que ele fica visível
    ),
  );
}

}