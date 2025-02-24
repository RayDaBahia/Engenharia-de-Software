import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:uesb_forms/Telas/Formulario/Configruacoes.dart';

class SelecaoQuestoesBanco extends StatefulWidget {
  final Banco? banco;
  final bool isAlteracao;

  const SelecaoQuestoesBanco({super.key, this.banco, this.isAlteracao = false});

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
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Pegando os argumentos passados pela rota
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      final bancoArg = args['banco'] as Banco?;
      final isAlteracaoArg = args['isAlteracao'] as bool?;

      // Verifica se é necessário atualizar o estado
      if (bancoArg != null && (banco == null || banco!.id != bancoArg.id)) {
        setState(() {
          banco = bancoArg;
          isAlteracao = isAlteracaoArg ?? false; // Caso 'isAlteracao' seja null, define como false
        });

        if (banco != null) {
          Provider.of<BancoList>(context, listen: false).buscarQuestoesBancoNoBd(banco!.id);
        }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Substitui a tela atual pela nova
            if (!isAlteracao) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Configruacoes(), // Substitua por sua tela real
                ),
              );
            } else {
              Navigator.of(context).pushReplacementNamed(
                Rotas.EDICAO_FORMULARIO_TELA,
                arguments: {
                  'questoesSelecionadas': _questoesSelecionadas.toList(),
                },
              );
            }
          },
        ),
        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
        title: const Text('Seleção de Questões'),
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
                    if (!isAlteracao) {
                       Navigator.of(context).pushReplacementNamed(
                      Rotas.MEUS_BANCOS,
                    arguments:{ 'isFormulario':true,}                   // Aqui você passa o argumento para a rota
                            );   
                    } else {
                      Navigator.of(context).pushReplacementNamed(
                        Rotas.EDICAO_FORMULARIO_TELA,
                        arguments: {
                          'questoesSelecionadas': _questoesSelecionadas.toList(),
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
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
