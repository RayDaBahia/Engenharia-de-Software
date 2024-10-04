import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class WidgetOpcoesQuestao extends StatelessWidget {
  const WidgetOpcoesQuestao({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
                  onPressed: () {
                    _showBottomSheet(context);
                  },
                  backgroundColor: const Color.fromARGB(255, 33, 12, 71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: const Icon(Icons.add),
                );
  }

  void _showBottomSheet(BuildContext context) {
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
                      id: Random().nextInt(1000000).toString(),
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
                 Provider.of<BancoList>(context, listen: false)
                      .adicionarQuestaoNaLista(
                    Questao(
                      id: Random().nextInt(1000000).toString(),
                      textoQuestao: '',
                      tipoQuestao: QuestaoTipo.Ranking,
                      opcoesRanking: [],
                     ordemRanking: [],
                    ),
                  );

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
