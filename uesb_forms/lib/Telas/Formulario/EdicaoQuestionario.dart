import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:flutter/services.dart';

class EdicaoQuestionario extends StatefulWidget {
  final List<Questao>? questoesSelecionadas;
  final Banco? banco;

  const EdicaoQuestionario({super.key, this.questoesSelecionadas, this.banco});

  @override
  _EdicaoQuestionarioState createState() => _EdicaoQuestionarioState();
}

class _EdicaoQuestionarioState extends State<EdicaoQuestionario> {
  late List<Questao> _questoesSelecionadas;
  Banco? _banco;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _metaController = TextEditingController();
  String? _preenchidoPor;




  @override
  void initState() {
    super.initState();
    _questoesSelecionadas = widget.questoesSelecionadas ?? [];
    _banco = widget.banco;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        _questoesSelecionadas = args['questoesSelecionadas'] ?? _questoesSelecionadas;
        _banco = args['banco'] ?? _banco;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  void _adicionarMaisQuestoes(BuildContext context) {
    Navigator.of(context).pushNamed(
      Rotas.SELECAO_QUESTOES_BANCO,
      arguments: {
        'banco': _banco,
        'isAlteracao': true
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Edição do Questionário',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
      ),
      body: 
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoTexto(
              controller: _nomeController,
              label: "Titulo",
              maxLength: 60, // Limite de 60 caracteres
            ),
            const SizedBox(height: 10),
            CampoTexto(
              controller: _descricaoController,
              label: "Descrição",
              maxLength: 160, // Limite de 160 caracteres
            ),
            const SizedBox(height: 10),
            CampoDropdown(
              label: "Preenchido por",
              onChanged: (value) {
                setState(() {
                  _preenchidoPor = value;
                });
              },
            ),
            const SizedBox(height: 10),
            CampoNumero(
              controller: _metaController,
              label: "Meta",
            ),
          ],
        ),
      ), 
       Expanded(
              child: _questoesSelecionadas.isEmpty
                  ? const Center(child: Text("Nenhuma questão selecionada"))
                  : ListView.builder(
                      itemCount: _questoesSelecionadas.length,
                      itemBuilder: (context, index) {
                        final questao = _questoesSelecionadas[index];
                        return ListTile(
                          title: QuestaoWidgetForm(
                            questao: questao,
                            bancoId: _banco?.id ?? "",
                          ),
                          subtitle: CheckboxListTile(
                            title: const Text("Questão obrigatória"),
                            value: questao.obrigatoria,
                            onChanged: (bool? value) {
                              setState(() {
                                questao.obrigatoria = value ?? false;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _questoesSelecionadas.removeAt(index);
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
                   Provider.of<QuestionarioList>(context, listen: false).setDadosTemporarios(listaDeQuestoes: _questoesSelecionadas);
                    Navigator.pushNamed(context, Rotas.CONFIGURAR_ACESSO_FORMS);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 21, 37),
                  ),
                  child: const Text(
                    'Próximo',
                    style: TextStyle(color: Color.fromRGBO(250, 250, 250, 1)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_preenchidoPor == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selecione a opção "Preenchido por"')),
            );
            return;
          }

           _adicionarMaisQuestoes(context);
       

          Navigator.of(context).pushNamed(
            Rotas.MEUS_BANCOS,
            arguments: {'isFormulario': true},
          );
        },
        backgroundColor: const Color.fromARGB(255, 21, 3, 44),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}



class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final int? maxLength;

  const CampoTexto({super.key, required this.label, this.controller, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLength: maxLength, // Aplica a limitação de caracteres
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide.none,
            ),
            counterText: "", // Remove a exibição do contador padrão
          ),
        ),
      ],
    );
  }
}

class CampoNumero extends StatelessWidget {
  final String label;
  final TextEditingController? controller;

  const CampoNumero({super.key, required this.label, this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Permite apenas números
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class CampoDropdown extends StatelessWidget {
  final String label;
  final ValueChanged<String?>? onChanged;

  const CampoDropdown({super.key, required this.label, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide.none,
            ),
          ),
          items: ['Entrevistador', 'Entrevistado', 'Ambos']
              .map(
                (opcao) => DropdownMenuItem(value: opcao, child: Text(opcao)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
