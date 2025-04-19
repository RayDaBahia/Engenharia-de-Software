import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/Formulario/Dinamizar/QuestaoDinamicaWidget.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class Teladinamizarquestao extends StatefulWidget {
  final Questao questaoSelecionada;
  late List<Questao> _questoesSelecionadas = [];

  Teladinamizarquestao({Key? key, required this.questaoSelecionada,})
      : super(key: key);

  @override
  State<Teladinamizarquestao> createState() => _TeladinamizarquestaoState();
}

class _TeladinamizarquestaoState extends State<Teladinamizarquestao> {
  late List<Questao> _questoesSelecionadas = [];
  Questionario? questionario;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Recupera os argumentos da navegação e atualiza o estado uma única vez
      questionario =
          ModalRoute.of(context)?.settings.arguments as Questionario?;
      if (questionario != null) {
        // Usando o Provider para carregar as questões
        Provider.of<QuestionarioList>(context, listen: false)
            .buscarQuestoes(questionario!.id);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _questoesSelecionadas =
        Provider.of<QuestionarioList>(context, listen: true).listaQuestoes;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Dinamizar alternativas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: _questoesSelecionadas.isEmpty
                  ? const Center(child: Text("Nenhuma questão selecionada"))
                  : ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        final questao = widget.questaoSelecionada;
                        return ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Coluna da esquerda (texto e widget)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Questão ${index + 1}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    QuestaoDinamicaWidget(questao: questao),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: CheckboxListTile(
                            title: const Text("Questão obrigatória"),
                            value: questao.obrigatoria,
                            onChanged: (bool? value) {
                              setState(() {
                                questao.obrigatoria = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
