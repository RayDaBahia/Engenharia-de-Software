import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/aplicacao_list.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Telas/Formulario/Dados.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class FormularioLider extends StatefulWidget {
  final Questionario questionario;
  final VoidCallback onAplicar; // Callback para aplicar
  final VoidCallback onTestar; // Callback para testar

  const FormularioLider({
    super.key,
    required this.questionario,
    required this.onAplicar,
    required this.onTestar,
  });

  @override
  State<FormularioLider> createState() => _FormularioLiderState();
}

class _FormularioLiderState extends State<FormularioLider> {
  @override
  void initState() {
    super.initState();

    // Chama a verificação ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarEncerramento();
    });
  }

  Future<void> _verificarEncerramento() async {
    final provider = Provider.of<QuestionarioList>(context, listen: false);
    final atualizado = await provider.verificaEncerramento(widget.questionario);
    if (atualizado) {
      debugPrint(
        '✅ Questionário ${widget.questionario.nome} foi encerrado (prazo ou meta atingida).',
      );
    } else {
      debugPrint(
        '🕒 Questionário ${widget.questionario.nome} ainda está ativo.',
      );
    }

    if (atualizado && mounted) {
      setState(() {}); // Atualiza a UI se houve mudança de status
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionarioProvider = Provider.of<QuestionarioList>(
      context,
      listen: true,
    );

    final Provider_aplicacao = Provider.of<AplicacaoList>(
      context,
      listen: false,
    );
    final dataPublicacao = widget.questionario.dataPublicacao != null
        ? DateFormat('dd/MM/yyyy').format(widget.questionario.dataPublicacao!)
        : "Não publicado";

    final prazo = widget.questionario.prazo != null
        ? DateFormat('dd/MM/yyyy').format(widget.questionario.prazo!)
        : "Indefinido";

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
                      Color.fromARGB(255, 103, 52, 139),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 5,
                child: getStatusIcon(widget.questionario),
              ),
              Positioned(
                left: 10,
                top: 5,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) async {
                    switch (value) {
                      case 'publicar':
                        await questionarioProvider.publicarQuestionario(
                          widget.questionario.id,
                        );
                        break;
                      case 'ativar':
                        await questionarioProvider.ativarQuestionario(
                          widget.questionario.id,
                        );
                        break;
                      case 'desativar':
                        await questionarioProvider.desativarQuestionario(
                          widget.questionario.id,
                        );
                        break;
                      case 'editar':
                        Navigator.of(context).pushNamed(
                          Rotas.EDICAO_FORMULARIO_TELA,
                          arguments: widget.questionario,
                        );
                        break;
                      case 'editar configurações':
                        Navigator.of(context).pushNamed(
                          Rotas.CONFIGURAR_ACESSO_FORMS,
                          arguments: widget.questionario,
                        );
                        break;
                      case 'testar':
                        widget.onTestar();
                        break;
                      case 'aplicar':
                        widget.onAplicar();
                        break;
                      case 'Dados':
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                Dados(questionario: widget.questionario),
                          ),
                        );

                        break;
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ação "$value" realizada com sucesso!'),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) {
                    List<PopupMenuEntry<String>> opcoes = [];

                    // Adiciona opções de teste e aplicar (sempre visíveis)
                    opcoes.add(
                      const PopupMenuItem(
                        value: 'testar',
                        child: Row(
                          children: [
                            SizedBox(width: 8),
                            Text('Testar questionário'),
                          ],
                        ),
                      ),
                    );

                    if (!widget.questionario.publicado) {
                      opcoes.add(
                        const PopupMenuItem(
                          value: 'publicar',
                          child: Text('Publicar'),
                        ),
                      );
                      opcoes.add(
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar conteudo'),
                        ),
                      );
                      opcoes.add(
                        const PopupMenuItem(
                          value: 'editar configurações',
                          child: Text('Editar configurações gerais'),
                        ),
                      );
                    }
                    if (widget.questionario.publicado) {
                      if (!widget.questionario.ativo &&
                          !widget.questionario.encerrado) {
                        opcoes.add(
                          const PopupMenuItem(
                            value: 'ativar',
                            child: Text('Ativar'),
                          ),
                        );
                      }
                      if (!widget.questionario.ativo) {
                        opcoes.add(
                          const PopupMenuItem(
                            value: 'Dados',
                            child: Row(
                              children: [SizedBox(width: 8), Text('Respostas')],
                            ),
                          ),
                        );
                      } else {
                        opcoes.add(
                          const PopupMenuItem(
                            value: 'desativar',
                            child: Text('Desativar'),
                          ),
                        );
                        opcoes.add(
                          const PopupMenuItem(
                            value: 'Dados',
                            child: Row(
                              children: [SizedBox(width: 8), Text('Respostas')],
                            ),
                          ),
                        );
                        opcoes.add(
                          const PopupMenuItem(
                            value: 'aplicar',
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Text('Aplicar questionário'),
                              ],
                            ),
                          ),
                        );
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
                  widget.questionario.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Líder: ${widget.questionario.liderNome}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "Publicado em: $dataPublicacao",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Text(
                  "Prazo: $prazo",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!widget.questionario.ativo &&
                        !widget.questionario.publicado)
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: Color.fromARGB(255, 69, 12, 126),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmar Duplicação'),
                                content: const Text(
                                  'Tem certeza de que deseja duplicar este questionário?',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: const Text('Duplicar'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            await questionarioProvider.duplicarQuestionario(
                              widget.questionario,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Questionário duplicado com sucesso!',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    if (!widget.questionario.ativo &&
                        !widget.questionario.publicado)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmar Exclusão'),
                                content: const Text(
                                  'Tem certeza de que deseja excluir este questionário?',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: const Text('Excluir'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            await questionarioProvider.excluirQuestionario(
                              widget.questionario.id,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Questionário excluído com sucesso!',
                                  ),
                                ),
                              );
                            }
                          }
                        },
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

  Widget getStatusIcon(Questionario questionario) {
    final agora = DateTime.now();

    if (!questionario.publicado) {
      return const Row(
        children: [
          Icon(Icons.hourglass_empty, color: Colors.grey, size: 20),
          SizedBox(width: 5),
          Text("Rascunho", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (questionario.encerrado) {
      return const Row(
        children: [
          Icon(Icons.check, color: Colors.red, size: 20),
          SizedBox(width: 5),
          Text("Encerrado", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (questionario.senha != null && questionario.senha!.isNotEmpty) {
      return const Row(
        children: [
          Icon(Icons.lock, color: Colors.orange, size: 20),
          SizedBox(width: 5),
          Text("Bloqueado", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (questionario.publicado && questionario.ativo) {
      return const Row(
        children: [
          Icon(Icons.visibility, color: Colors.green, size: 20),
          SizedBox(width: 5),
          Text("Ativo", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (questionario.publicado && !questionario.ativo) {
      return const Row(
        children: [
          Icon(Icons.visibility_off, color: Colors.green, size: 20),
          SizedBox(width: 5),
          Text("Inativo", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (!questionario.visivel) {
      return const Row(
        children: [
          Icon(Icons.remove_red_eye, color: Colors.green, size: 20),
          SizedBox(width: 5),
          Text("Não vísivel", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    // ✅ Fallback obrigatório
    return const Row(
      children: [
        Icon(Icons.help_outline, color: Colors.white, size: 20),
        SizedBox(width: 5),
        Text("Desconhecido", style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
