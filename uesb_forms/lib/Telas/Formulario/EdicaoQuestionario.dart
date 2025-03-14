import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class EdicaoQuestionario extends StatefulWidget {
  final Banco? banco;

  const EdicaoQuestionario({super.key, this.banco});

  @override
  _EdicaoQuestionarioState createState() => _EdicaoQuestionarioState();
}

class _EdicaoQuestionarioState extends State<EdicaoQuestionario> {
  late List<Questao> _questoesSelecionadas = [];
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _metaController = TextEditingController();
  String? _preenchidoPor;

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  void _adicionarMaisQuestoes(BuildContext context) {
    Navigator.of(context).pushNamed(
      Rotas.MEUS_BANCOS,
      arguments: {'isFormulario': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    _questoesSelecionadas = Provider.of<QuestionarioList>(context, listen: true).listaQuestoes;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _questoesSelecionadas.clear();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Edição do Questionário',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CampoTexto(controller: _nomeController, label: "Título", maxLength: 60),
                  const SizedBox(height: 10),
                  CampoTexto(controller: _descricaoController, label: "Descrição", maxLength: 160),
                  const SizedBox(height: 10),
                  CampoDropdown(
                    label: "Preenchido por",
                    onChanged: (value) => setState(() => _preenchidoPor = value),
                  ),
                  const SizedBox(height: 10),
                  CampoNumero(controller: _metaController, label: "Meta"),
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
                          title: QuestaoWidgetForm(questao: questao),
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
                    if (_preenchidoPor == null || _preenchidoPor!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('É necessário informar quem irá preencher o questionário')),
                      );
                      return;
                    }
                    if (_nomeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content : Text('é necessário definir um título para o questionario')),
                      );
                      return;
                    }

                    Provider.of<QuestionarioList>(context, listen: false).setDadosTemporarios(
                      listaDeQuestoes: _questoesSelecionadas,
                      nome: _nomeController.text.isEmpty ? 'Sem título' : _nomeController.text,
                      descricao: _descricaoController.text.isEmpty ? 'Sem descrição' : _descricaoController.text,
                      meta: _metaController.text.isEmpty ? '0' : _metaController.text,
                      preenchido: _preenchidoPor,
                    );
                    Navigator.pushNamed(context, Rotas.CONFIGURAR_ACESSO_FORMS);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 21, 37),
                  
                  ),
                  child: const Text('Próximo', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarMaisQuestoes(context),
        backgroundColor: const Color.fromARGB(255, 21, 3, 44),
        child: const Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
      ),
    );
  }
}

class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int? maxLength;

  const CampoTexto({super.key, required this.label, required this.controller, this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLength: maxLength,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
            counterText: "",
          ),
        ),
      ],
    );
  }
}

class CampoNumero extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const CampoNumero({super.key, required this.label, required this.controller});

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
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

class CampoDropdown extends StatelessWidget {
  final String label;
  final ValueChanged<String?> onChanged;

  const CampoDropdown({super.key, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade200, border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
      items: ['Entrevistador', 'Entrevistado', 'Ambos'].map((opcao) => DropdownMenuItem(value: opcao, child: Text(opcao))).toList(),
      onChanged: onChanged,
    );
  }
}
