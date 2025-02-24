import 'package:flutter/material.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class Configruacoes extends StatelessWidget {
  const Configruacoes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade900,
        title: const Text('Configurações'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CampoTexto(label: "Nome"),
            const SizedBox(height: 10),
            const CampoDropdown(label: "Preenchido por"),
            const SizedBox(height: 10),
            const CampoTexto(label: "Meta"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
              Rotas.MEUS_BANCOS,
              arguments:{ 'isFormulario':true,}                   // Aqui você passa o argumento para a rota
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

  const CampoTexto({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
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

  const CampoDropdown({super.key, required this.label});

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
              .map((opcao) => DropdownMenuItem(value: opcao, child: Text(opcao)))
              .toList(),
          onChanged: (value) {},
        ),
      ],
    );
  }
}
