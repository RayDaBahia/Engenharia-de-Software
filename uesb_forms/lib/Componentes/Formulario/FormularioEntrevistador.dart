import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';

class FormularioEntrevistador extends StatelessWidget {
  final Questionario questionario;
  final VoidCallback? onAplicar;
  final VoidCallback? onTestar;

  const FormularioEntrevistador({
    super.key,
    required this.questionario,
    this.onAplicar,
    this.onTestar,
  });

  @override
  Widget build(BuildContext context) {
    final dataPublicacao = questionario.dataPublicacao != null
        ? DateFormat('dd/MM/yyyy').format(questionario.dataPublicacao!)
        : "Não publicado";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // Cabeçalho com gradiente e menu
          Stack(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(255, 103, 52, 139)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              if (questionario.senha != null && questionario.senha!.isNotEmpty)
                const Positioned(
                  right: 10,
                  top: 10, // Ajuste para alinhar verticalmente
                  child: Icon(Icons.lock, color: Colors.white, size: 30),
                ),
            ],
          ),
          // Corpo do card
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionario.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Líder: ${questionario.liderNome}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "Publicado em: $dataPublicacao",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 12),
                // Botões principais (sempre visíveis se publicado)
                if (questionario.publicado)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (questionario.ativo)
                        ElevatedButton(
                          onPressed: () => _handleAcao(
                            context,
                            onAplicar,
                            "Aplicar",
                            questionario.senha,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 45, 12, 68),
                          ),
                          child: const Text('Aplicar',
                              style: TextStyle(color: Colors.white)),
                        ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _handleAcao(
                          context,
                          onTestar,
                          "Testar",
                          questionario.senha,
                        ),
                        child: const Text('Testar'),
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

  Future<void> _handleAcao(
    BuildContext context,
    VoidCallback? callback,
    String acao,
    String? senha,
  ) async {
    if (senha?.isNotEmpty ?? false) {
      final senhaDigitada = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Senha requerida"),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(hintText: "Digite a senha"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                final controller = (context as Element)
                    .findAncestorWidgetOfExactType<TextField>()
                    ?.controller;
                Navigator.pop(context, controller?.text ?? '');
              },
              child: const Text("Confirmar"),
            ),
          ],
        ),
      );

      if (senhaDigitada == senha) {
        callback?.call();
      } else if (senhaDigitada != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Senha incorreta!")),
        );
      }
    } else {
      callback?.call();
    }
  }
}
