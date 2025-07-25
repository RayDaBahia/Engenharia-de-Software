import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class SelecaoQuestoesBanco extends StatefulWidget {
  const SelecaoQuestoesBanco({super.key});

  @override
  _SelecaoQuestoesBancoState createState() => _SelecaoQuestoesBancoState();
}

class _SelecaoQuestoesBancoState extends State<SelecaoQuestoesBanco> {
  late TextEditingController _questaoFiltro;
  final Set<Questao> _questoesSelecionadas = {};
  Banco? banco;
  bool isAlteracao = false;

  @override
@override
void initState() {
  super.initState();
  _questaoFiltro = TextEditingController(); // ✅ INICIALIZA AQUI
}


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      final bancoArg = args['banco'] as Banco?;
      final isAlteracaoArg = args['isAlteracao'] as bool?;

      if (bancoArg != null && (banco == null || banco!.id != bancoArg.id)) {
        banco = bancoArg;
        isAlteracao = isAlteracaoArg ?? false;

        if (banco != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<BancoList>(
              context,
              listen: false,
            ).buscarQuestoesBancoNoBd(banco!.id);
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
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
        title: const Text(
          'Seleção de Questões',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                Provider.of<QuestionarioList>(
                  context,
                  listen: false,
                ).adicionarListaQuestoesSelecionadas(
                  _questoesSelecionadas.toList(),
                );
                showSuccessMessage(
                  context,
                  'Questões selecionadas com sucesso!',
                );
                Navigator.pop(context);
              },
              child: Text(
                "Finalizar",
                style: TextStyle(
                  color: const Color.fromARGB(255, 1, 21, 37),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _questaoFiltro,
                onChanged: (value) {
                  setState(() {}); // Atualiza filtro com segurança
                },
                decoration: InputDecoration(
                  labelText: 'Pesquisar por nome',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
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
                /*
                    ElevatedButton(
                    onPressed: () {
                    
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  const Color.fromARGB(255, 255, 255, 255), // Fundo roxo
                      foregroundColor:  const Color.fromARGB(255, 45, 12, 68)            ),
                    child: const Text('Voltar',style: TextStyle(fontWeight: FontWeight.bold), ),
                  ),*/

                // Center(
                //     child: ElevatedButton(
                //   onPressed: () {
                //     Provider.of<QuestionarioList>(context, listen: false)
                //         .adicionarListaQuestoesSelecionadas(
                //             _questoesSelecionadas.toList());

                //     showSuccessMessage(
                //         context, 'Questões selecionadas com sucesso!');
                //     Navigator.pop(context);
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor:
                //         const Color.fromARGB(255, 45, 12, 68), // Fundo roxo
                //     foregroundColor: Colors.white, // Texto branco
                //   ),
                //   child: const Text('Confirmar'),
                // )),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating, // Faz ele "flutuar" acima da UI
        margin: const EdgeInsets.all(16), // Margem nas bordas
        duration: const Duration(seconds: 3), // Tempo que ele fica visível
      ),
    );
  }

  @override
  void dispose() {
    _questaoFiltro.dispose();
    super.dispose();
  }
}
