import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/questaoWidget.dart';

import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Modelo/Banco.dart';

class CrudBancoQuestoes extends StatefulWidget {
  const CrudBancoQuestoes({super.key}); // Adicionando o ID no construtor

  @override
  State<CrudBancoQuestoes> createState() => _CrudBancoQuestoesState();
}

class _CrudBancoQuestoesState extends State<CrudBancoQuestoes> {
  Banco? banco;
  bool _isLoaded = false; // Adiciona um flag para evitar múltiplas execuções

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;

      // Verifica se args não é nulo e é do tipo Banco
      if (args is Banco) {
        banco = args;
        Provider.of<BancoList>(context, listen: false)
            .buscarQuestoesBancoNoBd(banco!.id);

        _descricaoBancoController.text = banco!.descricao;
        _nomeBancoController.text = banco!.nome;
      } else {
        Provider.of<BancoList>(context, listen: false).limparListaQuestoes();
      }

      _isLoaded = true;
    }
  }

  late TextEditingController _descricaoBancoController;
  late TextEditingController _nomeBancoController;
  late TextEditingController _questaoFiltro;

  @override
  @override
  void initState() {
    super.initState();
    _descricaoBancoController = TextEditingController();
    _nomeBancoController = TextEditingController();
    _questaoFiltro = TextEditingController();
    // Chama o método para obter bancos
  }

  @override
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
              decoration: InputDecoration(
                labelText:
                    _nomeBancoController.text.isEmpty ? 'Banco Sem Título' : '',
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
              decoration: InputDecoration(
                labelText: _descricaoBancoController.text.isEmpty
                    ? 'adicione uma descrição ao banco'
                    : '',
                labelStyle: TextStyle(
                  color: Colors.grey, // Cor clara para a descrição
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _questaoFiltro,
                    decoration: InputDecoration(
                        fillColor: const Color.fromARGB(47, 90, 88, 88),
                        filled: true,
                        labelText: 'Pesquisar Questão',
                        labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 37, 46, 72), // Cor branca
                          fontWeight: FontWeight.bold, // Negrito
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 175, 186, 196)))),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Icon(
                  Icons.find_in_page_outlined,
                  color: Colors.grey,
                  size: 45,
                ),
              ],
            ),

          SizedBox(height: 60,),
            
          
            Expanded(
              child: ListView.builder(
                itemCount: bancoList.questoesLista.length,
                itemBuilder: (context, index) {
                  final questao = bancoList.questoesLista[index];
                  return QuestaoWidget(
                    questao: questao,
                    bancoId: banco?.id ?? '', // Acesso seguro ao id do banco
                  );
                },
              ),
            ),
            SizedBox(height: 10,),
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
                    if (banco == null) {
                      try {
                        await bancoList.SalvarBanco(
                          _nomeBancoController.text,
                          _descricaoBancoController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Banco criado com sucesso!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erro ao criar banco: $e")),
                        );
                      }
                    } else {
                      try {
                        banco!.nome = _nomeBancoController.text;
                        banco!.descricao = _descricaoBancoController.text;
                        await bancoList.AtualizarBanco(banco!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Banco atualizado com sucesso!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Erro ao atualizar banco: $e")),
                        );
                      }
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
                  child: banco == null
                      ? const Text('Salvar')
                      : const Text('Atualizar'),
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
                  onTap: () {}),
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
                onTap: () {
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
