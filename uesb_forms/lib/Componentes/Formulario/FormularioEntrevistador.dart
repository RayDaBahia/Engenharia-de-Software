import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';

class FormularioEntrevistador extends StatelessWidget {
  final Questionario questionario;
  // final int numRespostas;

  const FormularioEntrevistador({
    super.key,
    required this.questionario,
    // required this.numRespostas,
  });

  @override
  Widget build(BuildContext context) {
    final questionarioProvider =
        Provider.of<QuestionarioList>(context, listen: false);

    // Formatar a data de publicação
    String dataPublicacao = questionario.dataPublicacao != null
        ? DateFormat('dd/MM/yyyy').format(questionario.dataPublicacao!)
        : "Data não disponível";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
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
                  top: 10,
                  child: Icon(Icons.lock, color: Colors.white, size: 20),
                ),
              Positioned(
                left: 10,
                top: 10,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) async {
                    if (value == 'Notificar líder') {

                      // Lógica para notificar o líder
                      // Você pode enviar uma notificação ou e-mail para o líder aqui.
                    
                     
                    } else if (value == 'Responder') {
                      if (questionario.senha == null ||
                          questionario.senha!.isEmpty) {
                        String senhaDigitada =
                            await _mostrarDialogoSenha(context);

                        // Verificar se a senha fornecida é igual à senha do questionário
                        if (senhaDigitada == questionario.senha) {
                          // Lógica para responder ao questionário
                          // Você pode abrir uma nova tela ou permitir que o usuário complete o questionário aqui.
  
                        } else {
                          // Exibir um alerta caso a senha esteja incorreta
                          await _exibirAlertaSenhaIncorreta(context);
                        }
                      } else {

                      }
                      // Adicione a lógica necessária
                    } 

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Ação "$value" realizada com sucesso!')),
                      );
                    }
                  },
                  itemBuilder: (context) {
                    List<PopupMenuEntry<String>> opcoes = [];

                    if (questionario.publicado) {
                      if (questionario.ativo) {
                        opcoes.add(const PopupMenuItem(
                            value: 'Notificar líder',
                            child: Text('Notificar líder')));
                        opcoes.add(const PopupMenuItem(
                            value: 'Responder', child: Text('Responder')));
                      }
                    }

                    return opcoes;
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  questionario.nome,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Líder: ${questionario.liderNome}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /*
                      Text(
                        "Respostas: $numRespostas / ${questionario.meta}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),*/
                      Text(
                        "Publicado em: $dataPublicacao",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _mostrarDialogoSenha(BuildContext context) async {
    String senha = '';
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _senhaController = TextEditingController();

        return AlertDialog(
          title: Text("Digite a senha"),
          content: TextField(
            controller: _senhaController,
            obscureText: true,
            decoration: InputDecoration(hintText: "Senha"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                senha = _senhaController.text;
                Navigator.of(context).pop(senha); // Retorna a senha digitada
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
    return senha; // Retorna a senha digitada
  }

  // Função para exibir um alerta se a senha for incorreta
  Future<void> _exibirAlertaSenhaIncorreta(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erro"),
          content: Text("A senha digitada está incorreta."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: Text("Fechar"),
            ),
          ],
        );
      },
    );
  }
}
