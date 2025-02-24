import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';

class SelecaoQuestoesBanco extends StatefulWidget {
  const SelecaoQuestoesBanco ({super.key});

  @override
  State<SelecaoQuestoesBanco> createState() => _SelecaoQuestoesBancoState();
}

class _SelecaoQuestoesBancoState extends State<SelecaoQuestoesBanco> {
  late TextEditingController _questaoFiltro;
  final Set<Questao> _questoesSelecionadas = {};
  Banco? banco;

  @override
  void initState() {
    super.initState();
    _questaoFiltro = TextEditingController();
    _questaoFiltro.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (banco == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Banco) {
        setState(() {
          banco = args;
        });
        Provider.of<BancoList>(context, listen: false).buscarQuestoesBancoNoBd(banco!.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: true);
    final filtroTexto = _questaoFiltro.text.toLowerCase();
    final questoesFiltradas = bancoList.filtrarQuestoes(filtroTexto);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
        title: TextField(
          controller: _questaoFiltro,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(249, 0, 16, 81),
            hintText: 'Pesquisar questões...',
            hintStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(

              child: ListView.builder(
                itemCount: questoesFiltradas.length,
                itemBuilder: (context, index) {
                  final questao = questoesFiltradas[index];
                  final isSelected = _questoesSelecionadas.contains(questao);
                  return ListTile(
                    title: QuestaoWidgetForm(questao: questao, bancoId: banco?.id ?? ''),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('Voltar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _questoesSelecionadas.toList());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
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
