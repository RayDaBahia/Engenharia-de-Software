

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/QuestionarioProvider%20.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetLinhaUnica extends StatefulWidget {



  final Questao questao;

    const WidgetLinhaUnica ({super.key, required this.questao});

  @override
  State<WidgetLinhaUnica> createState() => _WidgetLinhaUnicaState();
}

class _WidgetLinhaUnicaState extends State<WidgetLinhaUnica> {
 
   late TextEditingController controlePergunta;
 
   late TextEditingController controleResposta;

@override
  void initState() {
    
    controlePergunta= TextEditingController(text: widget.questao.titulo);
    controleResposta= TextEditingController(text: '');
    
    super.initState();
  }
 
 
 
  @override

  Widget build(BuildContext context) {

    final questionarioProvider = Provider.of<QuestionarioProvider>(context, listen: false);
    return Card(
      child:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controlePergunta,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                labelText: 'Digite a pergunta'
              ),
              onChanged: (value){
                widget.questao.titulo=value;
                questionarioProvider.adicionarOuAtualizarQuestao(widget.questao);
                
              },
            ),
            SizedBox(height: 10,),

        
          TextField(
              controller: controleResposta,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                labelText: 'Resposta'
              ),
              onChanged: (value){
                widget.questao.respostas[0]=value;
                questionarioProvider.adicionarOuAtualizarQuestao(widget.questao);
                
              },
              enabled: false,
            ),
          

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: ()=> questionarioProvider.removerQuestao(widget.questao.id)
                , icon: Icon(Icons.delete)),
              ],
            )
            
            
          ],
        ),
      ) ,
    );
  }
}