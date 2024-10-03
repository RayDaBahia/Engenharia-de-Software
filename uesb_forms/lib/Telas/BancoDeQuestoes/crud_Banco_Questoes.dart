import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/questaoWidget.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_opcoes_questao.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_pesquisa_questao.dart';

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
              height: 15,
            ),
          
            if(banco!=null)   WidgetPesquisaQuestao(),
            SizedBox(
              height: 40,
            ),
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
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WidgetOpcoesQuestao(),
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
                        Navigator.of(context).pop();
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

}