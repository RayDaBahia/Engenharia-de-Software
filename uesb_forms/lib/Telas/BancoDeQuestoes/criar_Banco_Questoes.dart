import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_multipla_escolha.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/QuestionarioProvider%20.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class CriarBancoQuestoes extends StatelessWidget {
  const CriarBancoQuestoes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
      ),
      drawer: MenuLateral(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Banco Sem Título',
                labelStyle: TextStyle(
                  color: const Color.fromARGB(255, 27, 7, 80),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextField(
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Adicione uma descrição ao banco',
                labelStyle: TextStyle(
                  color: Colors.grey, // Cor clara para a descrição
                ),
              ),
            ),
            Expanded(
              child: Consumer<QuestionarioProvider>(
                builder: (context, questionario, child) {
                  return ListView.builder(
                    itemCount: questionario.questoes.length,
                    itemBuilder: (context, index) {
                      final questao = questionario.questoes[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: WidgetMultiplaEscolha(questao: questao),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _showOptions(context);
                  },
                  backgroundColor: const Color.fromARGB(255, 33, 12, 71),
                  foregroundColor: Colors.white,
                  child: Icon(Icons.add),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    // Adicione a lógica de salvar aqui
                  },
                  child: Text('Salvar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 37, 7, 88),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  

 void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true, // Permite que a ListView ocupe apenas o espaço necessário
            children: [
              ListTile(
                leading: Icon(Icons.text_fields),
                title: Text('Linha Única'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de linha única
                },
              ),
              ListTile(
                leading: Icon(Icons.text_fields),
                title: Text('Múltiplas Linhas'),
                 onTap: () {
                Provider.of<QuestionarioProvider>(context, listen: false)
                    .adicionarOuAtualizarQuestao(
                      Questao(
                        titulo: '',
                        id: Random().nextInt(1000000).toString(),
                        respostas: [],
                      ),
                    );
                Navigator.pop(context);
                 }
              ),
              ListTile(
                leading: Icon(Icons.format_list_numbered),
                title: Text('Número'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de número
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Data'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de data
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Imagem (Captura)'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de captura de imagem
                },
              ),
              ListTile(
                leading: Icon(Icons.check_box),
                title: Text('Múltipla Escolha'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de múltipla escolha
                },
              ),
              ListTile(
                leading: Icon(Icons.radio_button_checked),
                title: Text('Objetiva'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de pergunta objetiva
                },
              ),
              ListTile(
                leading: Icon(Icons.star),
                title: Text('Ranking (Classificação)'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de ranking
                },
              ),
              ListTile(
                leading: Icon(Icons.arrow_drop_down),
                title: Text('Resposta Única (Lista Suspensa)'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de resposta única
                },
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('E-mail (Com Validação)'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de e-mail
                },
              ),
            ],
          ),
        );
      },
    );
  }
}