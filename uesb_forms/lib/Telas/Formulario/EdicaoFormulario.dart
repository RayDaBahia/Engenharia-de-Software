import 'package:flutter/material.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class EdicaoQuestionario extends StatefulWidget {
  final List<Questao>? questoesSelecionadas;
  final Banco? banco;

  const EdicaoQuestionario({super.key, this.questoesSelecionadas, this.banco});

  @override
  _EdicaoQuestionarioState createState() => _EdicaoQuestionarioState();
}

class _EdicaoQuestionarioState extends State<EdicaoQuestionario> {
  late List<Questao> _questoesSelecionadas;
  Banco? _banco;

  @override
  void initState() {
    super.initState();
    _questoesSelecionadas = widget.questoesSelecionadas ?? [];
    _banco = widget.banco;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        _questoesSelecionadas = args['questoesSelecionadas'] ?? _questoesSelecionadas;
        _banco = args['banco'] ?? _banco;
      });
    }
  }

void _adicionarMaisQuestoes(BuildContext context) {
     Navigator.of(context).pushReplacementNamed(
                Rotas.SELECAO_QUESTOES_BANCO,
                arguments: {
                  'banco': _banco, // Passando o banco
                  'isAlteracao':true
                
                },
              );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    

      appBar: AppBar(

leading: IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () {
    Navigator.of(context).pop(); // Volta para a tela anterior
  },
),


         title: const Text(
  'Edição do Questionário',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
  
),

        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: _questoesSelecionadas.isEmpty
                  ? const Center(child: Text("Nenhuma questão selecionada"))
                  : ListView.builder(
                      itemCount: _questoesSelecionadas.length,
                      itemBuilder: (context, index) {
                        final questao = _questoesSelecionadas[index];
                        return ListTile(
                          title: QuestaoWidgetForm(
                            questao: questao,
                            bancoId: _banco?.id ?? "",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _questoesSelecionadas.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _adicionarMaisQuestoes(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 1, 21, 37)),
                  child: const Text('Adicionar Questões',style:TextStyle(color:Color.fromRGBO(250, 250, 250, 1) ), ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context,Rotas.CONFIGURAR_ACESSO_FORMS);
                
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 1, 21, 37)),
                  child: const Text('Próximo', style: TextStyle(color:Color.fromRGBO(250, 250, 250, 1) ),),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
