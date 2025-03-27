import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class EdicaoQuestionario extends StatefulWidget {
// Permita receber pela rota  de modo opcional questionario  que será utilizado para a edição do questionário.
  const EdicaoQuestionario({
    super.key,
  });

  @override
  _EdicaoQuestionarioState createState() => _EdicaoQuestionarioState();
}

class _EdicaoQuestionarioState extends State<EdicaoQuestionario> {
  late List<Questao> _questoesSelecionadas = [];
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _metaController = TextEditingController();
  String? _preenchidoPor;
  bool isEdicaoQuestionario = false;
  Questionario? questionario;


 @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Recupera os argumentos da navegação e atualiza o estado uma única vez
      questionario = ModalRoute.of(context)?.settings.arguments as Questionario?;
      if (questionario != null) {
        isEdicaoQuestionario = true;
        _nomeController.text = questionario!.nome;
        _descricaoController.text = questionario!.descricao;
        _metaController.text = questionario!.meta.toString();
        _preenchidoPor = questionario!.tipoAplicacao;

        // Usando o Provider para carregar as questões
        Provider.of<QuestionarioList>(context, listen: false)
            .buscarQuestoes(questionario!.id);
      }
    });
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
      Rotas.MEUS_BANCOS,
      arguments: {'isFormulario': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    _questoesSelecionadas =
        Provider.of<QuestionarioList>(context, listen: true).listaQuestoes;

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
  actions: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          if (_preenchidoPor == null || _preenchidoPor!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'É necessário informar quem irá preencher o questionário')),
            );
            return;
          }
          if (_nomeController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'É necessário definir um título para o questionário')),
            );
            return;
          }

          if (!isEdicaoQuestionario) {
            Provider.of<QuestionarioList>(context, listen: false)
                .setDadosTemporarios(
              listaDeQuestoes: _questoesSelecionadas,
              nome: _nomeController.text.isEmpty
                  ? 'Sem título'
                  : _nomeController.text,
              descricao: _descricaoController.text.isEmpty
                  ? 'Sem descrição'
                  : _descricaoController.text,
              meta: _metaController.text.isEmpty
                  ? '0'
                  : _metaController.text,
              preenchido: _preenchidoPor,
            );
            Navigator.pushNamed(
                context, Rotas.CONFIGURAR_ACESSO_FORMS);
          } else {
            questionario!.nome = _nomeController.text;
            questionario!.descricao = _descricaoController.text;
            questionario!.meta = int.parse(_metaController.text);
            questionario!.tipoAplicacao = _preenchidoPor!;
            Provider.of<QuestionarioList>(context, listen: false)
                .atualizarQuestionario(questionario!);
            Navigator.of(context).pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 1, 21, 37),
        ),
        child: isEdicaoQuestionario
            ? const Text('Concluir',
                style: TextStyle(color: Colors.white))
            : const Text('Próximo',
                style: TextStyle(color: Colors.white)),
      ),
    ),
  ],
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
                  CampoTexto(
                      controller: _nomeController,
                      label: "Título",
                      maxLength: 60),
                  const SizedBox(height: 10),
                  CampoTexto(
                      controller: _descricaoController,
                      label: "Descrição",
                      maxLength: 160),
                  const SizedBox(height: 10),
                  CampoDropdown(
                    label: "Preenchido por",
                    onChanged: (value) =>
                        setState(() => _preenchidoPor = value),
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
                          trailing:
                           IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                 Provider.of<QuestionarioList>(context, listen: false)
                                    .excluirQuestaoSelecionada(index, questionario!.id);
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
         
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

  const CampoTexto(
      {super.key,
      required this.label,
      required this.controller,
      this.maxLength});

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
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none),
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
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

class CampoDropdown extends StatelessWidget {
  final String label;
  final ValueChanged<String?> onChanged;

  const CampoDropdown(
      {super.key, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
      items: ['Entrevistador', 'Entrevistado', 'Ambos']
          .map((opcao) => DropdownMenuItem(value: opcao, child: Text(opcao)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
