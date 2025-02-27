import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class SelecaoQuestoesBanco extends StatefulWidget {
  @override
  _SelecaoQuestoesBancoState createState() => _SelecaoQuestoesBancoState();
}

class _SelecaoQuestoesBancoState extends State<SelecaoQuestoesBanco> {
  late TextEditingController _questaoFiltro;
  final Set<Questao> _questoesSelecionadas = {};
  Banco? banco;
  bool isAlteracao = false;

  @override
  void initState() {
    super.initState();
    _questaoFiltro = TextEditingController();
    _questaoFiltro.addListener(() {
      setState(() {}); // Atualiza o estado ao digitar no campo de filtro
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      final bancoArg = args['banco'] as Banco?;
      final isAlteracaoArg = args['isAlteracao'] as bool?;

      if (bancoArg != null && (banco == null || banco!.id != bancoArg.id)) {
        banco = bancoArg;
        isAlteracao = isAlteracaoArg ?? false;

        if (banco != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<BancoList>(context, listen: false).buscarQuestoesBancoNoBd(banco!.id);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context);
    final filtroTexto = _questaoFiltro.text.toLowerCase();
    final questoesFiltradas = bancoList.filtrarQuestoes(filtroTexto);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
        title: const Text(
          'Seleção de Questões',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _questaoFiltro,
              decoration: const InputDecoration(
                labelText: 'Filtrar questões',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: questoesFiltradas.length,
                itemBuilder: (context, index) {
                  final questao = questoesFiltradas[index];
                  final isSelected = _questoesSelecionadas.contains(questao);
                  return ListTile(
                    title: QuestaoWidgetForm(
                      questao: questao,
                      bancoId: banco?.id ?? '',
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _questoesSelecionadas.add(questao);
                          } else {
                            _questoesSelecionadas.remove(questao);
                          }
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Voltar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Rotas.EDICAO_FORMULARIO_TELA,
                      arguments: {
                        'questoesSelecionadas': _questoesSelecionadas.toList(),
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Confirmar'),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questaoFiltro.dispose();
    super.dispose();
  }
}
