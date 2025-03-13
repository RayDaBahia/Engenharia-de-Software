import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';

class FormularioCard extends StatelessWidget {
  final Questionario questionario;
  final int numRespostas;

  const FormularioCard({
    super.key,
    required this.questionario,
    required this.numRespostas
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // Parte superior com o degradê
          Container(
            height: 40, // Define a altura do degradê no topo
            width: double.infinity, // Ocupa toda a largura do card
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 103, 52, 139)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Área branca com as informações
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  questionario.nome,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Líder: ${questionario.liderNome}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  "Respostas: ${numRespostas} / ${questionario.meta}",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, color: Color.fromARGB(255, 69, 12, 126)),
                        onPressed: () {},
                      ),
                      if (!questionario.ativo)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
