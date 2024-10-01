import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/questaoWidget.dart';

import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class CrudBancoQuestoes extends StatefulWidget {



  const CrudBancoQuestoes({super.key}); // Adicionando o ID no construtor

  @override
  State<CrudBancoQuestoes> createState() => _CrudBancoQuestoesState();
}


class _CrudBancoQuestoesState extends State<CrudBancoQuestoes> {

  
  String? bancoId;

    void didChangeDependencies() {
    super.didChangeDependencies();
    
    // O ModalRoute.of(context) deve ser usado aqui para acessar os argumentos da rota
    bancoId = ModalRoute.of(context)!.settings.arguments as String?;
  }



  late TextEditingController _descricaoBancoController;
  late TextEditingController _nomeBancoController;

  @override
   @override
  void initState() {
    super.initState();
    _descricaoBancoController = TextEditingController();
    _nomeBancoController = TextEditingController();
    // Chama o método para obter bancos
    if(bancoId!=null) Provider.of<BancoList>(context, listen: false).buscarQuestoesBancoNoBd(bancoId);
   
  }
  late final  listaquestao;


  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: true);

   

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
      ),
     
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeBancoController,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'Banco Sem Título',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 27, 7, 80),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextField(
              controller: _descricaoBancoController,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'Adicione uma descrição ao banco',
                labelStyle: TextStyle(
                  color: Colors.grey, // Cor clara para a descrição
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: bancoList.questoesLista.length,
                itemBuilder: (context, index) {
                  final questao = bancoList.questoesLista[index];
                  return QuestaoWidget(questao: questao, bancoId: bancoId,); // Aqui instanciamos o widget correto para cada questão
                },
              ),
            ),
            const Spacer(),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () async {
                    try {
                      await bancoList.SalvarBanco(
                        _nomeBancoController.text,
                        _descricaoBancoController.text,
                      );

                      // Exibe uma mensagem de sucesso
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Banco criado com sucesso!"),
                      ));
                    } catch (e) {
                      // Lida com qualquer erro que possa acontecer ao criar o banco
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Erro ao criar banco: $e"),
                      ));
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 37, 7, 88),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Salvar'),
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
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap:
                true, // Permite que a ListView ocupe apenas o espaço necessário
            children: [
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Linha Única'),
                onTap: () {
                  Provider.of<BancoList>(context, listen: false)
                      .adicionarQuestaoNaLista(
                    Questao(
                     
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
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Múltiplas Linhas'),
                  onTap: () {
                  
                  }),
              ListTile(
                leading: const Icon(Icons.format_list_numbered),
                title: const Text('Número'),
                onTap: () {
                        Provider.of<BancoList>(context, listen: false)
                        .adicionarQuestaoNaLista(
                      Questao(
                       
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
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data'),
                onTap: () {
                      Provider.of<BancoList>(context, listen: false)
                        .adicionarQuestaoNaLista(
                      Questao(
                       
                         textoQuestao: '',
                         tipoQuestao: QuestaoTipo.Data,
                        
                      ),
                    );
              
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de data
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Imagem (Captura)'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de captura de imagem
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_box),
                title: const Text('Múltipla Escolha'),
                onTap: () {
                  Provider.of<BancoList>(context, listen: false)
                        .adicionarQuestaoNaLista(
                      Questao(
                        
                         textoQuestao: '',
                         tipoQuestao: QuestaoTipo.MultiPlaEscolha,
                         opcoes: [],
                      ),
                    );
                    Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.radio_button_checked),
                title: const Text('Objetiva'),
                onTap: () {
                 Provider.of<BancoList>(context, listen: false)
                        .adicionarQuestaoNaLista(
                      Questao(
                         id: Random().nextInt(1000000).toString(),
                         textoQuestao: '',
                         tipoQuestao: QuestaoTipo.Objetiva,
                         opcoes: [],
                      ),
                    );
                    Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Ranking (Classificação)'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de ranking
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_drop_down),
                title: const Text('Resposta Única (Lista Suspensa)'),
                onTap : () {
                  Provider.of<BancoList>(context, listen: false)
                        .adicionarQuestaoNaLista(
                      Questao(
                        
                         textoQuestao: '',
                         tipoQuestao: QuestaoTipo.ListaSuspensa,
                         opcoes: [],
                      ),
                    );
                    Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('E-mail (Com Validação)'),
                onTap: () {
               
                  Provider.of<BancoList>(context, listen: false)
                      .adicionarQuestaoNaLista(
                    Questao(
                     
                      textoQuestao: '',
                      tipoQuestao: QuestaoTipo.Email,
                      resposta: '',
                    ),
                  );
                  Navigator.pop(context);
                  // Navegar ou mostrar o widget de linha única
                
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
