

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/QuestionarioProvider%20.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetLinhaUnica extends StatefulWidget {



  final String?  idBanco;
  final Questao questao;

    const WidgetLinhaUnica ({super.key, required this.questao, this.idBanco});

  @override
  State<WidgetLinhaUnica> createState() => _WidgetLinhaUnicaState();
}

class _WidgetLinhaUnicaState extends State<WidgetLinhaUnica> {
 
   late TextEditingController controlePergunta;
 
   late TextEditingController controleResposta;

@override
  void initState() {
    
    controlePergunta= TextEditingController(text: widget.questao.textoQuestao);
    controleResposta= TextEditingController(text: '');
    
    super.initState();
  }
 
 
 
  @override

  Widget build(BuildContext context) {

    final  bancoList = Provider.of<BancoList>(context, listen: false);
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
                widget.questao.textoQuestao=value;
                bancoList.adicionarQuestaoNaLista(widget.questao);
                
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
             
              enabled: false,
            ),
          

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: () {
                  bancoList.removerQuestao(widget.idBanco, widget.questao);
                }
                , icon: Icon(Icons.delete)),
              ],
            )
            
            
          ],
        ),
      ) ,
    );
  }
}