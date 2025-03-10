import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:flutter/services.dart';


class Configruacoes extends StatefulWidget {
  const Configruacoes({super.key});

  @override
  State<Configruacoes> createState() => _ConfigruacoesState();
}

class _ConfigruacoesState extends State<Configruacoes> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(30, 9, 66, 1),
     title: const Text(
    'Configurações',
    style: TextStyle(color: Colors.white),
  ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacementNamed(Rotas.MEUS_FORMULARIOS),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoTexto(
              controller: _nomeController,
              label: "Nome",
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_preenchidoPor == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selecione a opção "Preenchido por"')),
            );
            return;
          }

          final questionarioProvider = Provider.of<QuestionarioList>(context, listen: false);
          questionarioProvider.setDadosIniciais(
            meta: _metaController.text,
            nome: _nomeController.text,
            preenchido: _preenchidoPor!,
          );

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
