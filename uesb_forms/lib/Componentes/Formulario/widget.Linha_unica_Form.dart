import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Componentes/WidgetOpcoesImagem.dart';

class WidgetLinhaUnicaOremailForm extends StatefulWidget {
  final Questao questao;
  final bool isFormulario; // 🔥 Define se está preenchendo o formulário

  const WidgetLinhaUnicaOremailForm({
    super.key,
    required this.questao,
    this.isFormulario = true, // Padrão: não está preenchendo o formulário
  });

  @override
  State<WidgetLinhaUnicaOremailForm> createState() =>
      _WidgetLinhaUnicaOremailFormState();
}

class _WidgetLinhaUnicaOremailFormState extends State<WidgetLinhaUnicaOremailForm> {

  late TextEditingController controleResposta;
  

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
 
    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      color: Colors.white, // Cor de fundo do card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
         
              Text(widget.questao.textoQuestao),

                 const SizedBox(height: 10), // Caso contrário, não exibe nada
            TextField(
              controller: controleResposta,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                labelText: widget.questao.tipoQuestao == QuestaoTipo.LinhaUnica
                    ? 'Resposta'
                    : 'Digite seu e-mail',
              ),
              maxLines: 1,
              maxLength: (MediaQuery.of(context).size.width / 11).floor(),
    
                   
            ),
          ],
        ),
      ),
    );
  }
}
