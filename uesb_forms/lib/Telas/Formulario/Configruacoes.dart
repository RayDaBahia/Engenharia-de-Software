import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:uesb_forms/Modelo/Questionario.dart'; // ou onde está a classe QuestionarioList

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:uesb_forms/Modelo/Questionario.dart'; // Certifique-se de importar o provider correto

class Configruacoes extends StatefulWidget {
  const Configruacoes({super.key});

  @override
  State<Configruacoes> createState() => _ConfigruacoesState();
}

class _ConfigruacoesState extends State<Configruacoes> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _metaController = TextEditingController();
  String? _preenchidoPor; // Valor selecionado no dropdown

  @override
  void dispose() {
    _nomeController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade900,
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context)
              .pushReplacementNamed(Rotas.MEUS_FORMULARIOS),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoTexto(controller: _nomeController, label: "Nome"),
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
            CampoTexto(controller: _metaController, label: "Meta"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Verifica se o valor do dropdown foi selecionado
          if (_preenchidoPor == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selecione a opção "Preenchido por"')),
            );
            return;
          }
          // Atualiza o provider com os dados inseridos
          final questionarioProvider =
              Provider.of<QuestionarioList>(context, listen: false);

          questionarioProvider.setDadosIniciais(
            meta: _metaController.text,
            nome: _nomeController.text,
            preenchido: _preenchidoPor!,
          );
          // Navega para a próxima tela
          Navigator.of(context).pushReplacementNamed(
            Rotas.MEUS_BANCOS,
            arguments: {'isFormulario': true},
          );
        },
        backgroundColor: Colors.purple.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController? controller;

  const CampoTexto({super.key, required this.label, this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
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
                (opcao) =>
                    DropdownMenuItem(value: opcao, child: Text(opcao)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
