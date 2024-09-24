import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/questaoWidget.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_linha_unica.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_multipla_escolha.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/QuestionarioProvider%20.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class CrudBancoQuestoes extends StatefulWidget {

  final String? bancoId; // Defina bancoId como opcional

  CrudBancoQuestoes({super.key, this.bancoId}); // Adicionando o ID no construtor

  @override
  State<CrudBancoQuestoes> createState() => _CrudBancoQuestoesState();
}


class _CrudBancoQuestoesState extends State<CrudBancoQuestoes> {
  late TextEditingController _descricaoBancoController;
  late TextEditingController _nomeBancoController;

  @override
   @override
  void initState() {
    super.initState();
    _descricaoBancoController = TextEditingController();
    _nomeBancoController = TextEditingController();
    // Chama o método para obter bancos
    if(widget.bancoId!=null) Provider.of<BancoList>(context, listen: false).buscarQuestoesBancoNoBd(widget.bancoId);
   
  }
  late final  listaquestao;


  @override
  Widget build(BuildContext context) {
    final banco_list = Provider.of<BancoList>(context);

   

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
              controller: _nomeBancoController,
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
              controller: _descricaoBancoController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Adicione uma descrição ao banco',
                labelStyle: TextStyle(
                  color: Colors.grey, // Cor clara para a descrição
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: banco_list.questoesLista.length,
                itemBuilder: (context, index) {
                  final questao = banco_list.questoesLista[index];
                  return QuestaoWidget(questao: questao, bancoId: widget.bancoId,); // Aqui instanciamos o widget correto para cada questão
                },
              ),
            ),
            Spacer(),
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
                  onPressed: () async {
                    try {
                      await banco_list.SalvarBanco(
                        _nomeBancoController.text,
                        _descricaoBancoController.text,
                      );

                      // Exibe uma mensagem de sucesso
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Banco criado com sucesso!"),
                      ));
                    } catch (e) {
                      // Lida com qualquer erro que possa acontecer ao criar o banco
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Erro ao criar banco: $e"),
                      ));
                    }
                  },
                  child: Text('Salvar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 37, 7, 88),
                    padding: EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12.0),
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
            shrinkWrap:
                true, // Permite que a ListView ocupe apenas o espaço necessário
            children: [
              ListTile(
                leading: Icon(Icons.text_fields),
                title: Text('Linha Única'),
                onTap: () {
                  Provider.of<BancoList>(context, listen: false)
                      .adicionarQuestaoNaLista(
                    Questao(
                      id: Random().nextInt(1000000).toString(),
                      textoQuestao: '',
                      tipoQuestao: QuestaoTipo.LinhaUnica,
                      resposta: '',
                    ),
                  );
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de linha única
                },
              ),
              ListTile(
                  leading: Icon(Icons.text_fields),
                  title: Text('Múltiplas Linhas'),
                  onTap: () {
                    Provider.of<BancoList>(context, listen: false)
                        .adicionarQuestaoNaLista(
                      Questao(
                         id: Random().nextInt(1000000).toString(),
                         textoQuestao: '',
                         tipoQuestao: QuestaoTipo.MultiPlaEscolha,
                         opcoes: [],
                      ),
                    );
                    Navigator.pop(context);
                  }),
              ListTile(
                leading: Icon(Icons.format_list_numbered),
                title: Text('Número'),
                onTap: () {
                        Provider.of<BancoList>(context, listen: false)
                        .adicionarQuestaoNaLista(
                      Questao(
                         id: Random().nextInt(1000000).toString(),
                         textoQuestao: '',
                         tipoQuestao: QuestaoTipo.Numerica,
                         opcoes: [],
                      ),
                    );
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de número
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Data'),
                onTap: () {
                      Provider.of<BancoList>(context, listen: false)
                        .adicionarQuestaoNaLista(
                      Questao(
                         id: Random().nextInt(1000000).toString(),
                         textoQuestao: '',
                         tipoQuestao: QuestaoTipo.data,
                        
                      ),
                    );
              
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
