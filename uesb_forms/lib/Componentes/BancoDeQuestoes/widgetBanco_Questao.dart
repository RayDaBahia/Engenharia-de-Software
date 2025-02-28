import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class WidgetbancoQuestao extends StatefulWidget {
  final Banco banco;
  final bool isFormulario;

  const WidgetbancoQuestao({
    super.key,
    required this.banco,
    required this.isFormulario,
  });

  @override
  State<WidgetbancoQuestao> createState() => _WidgetbancoQuestaoState();
}

class _WidgetbancoQuestaoState extends State<WidgetbancoQuestao> {
  late BancoList _bancoList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bancoList = Provider.of<BancoList>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.sizeOf(context).width;

    return InkWell(
      onTap: () {
        if (!widget.isFormulario) {
          Navigator.of(context).pushNamed(Rotas.CRUD_BANCO, arguments: widget.banco);
        } else {
          Navigator.of(context).pushNamed(
            Rotas.SELECAO_QUESTOES_BANCO,
            arguments: {'banco': widget.banco},
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: screenWidth,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.black, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.banco.nome,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 27, 7, 80),
                        fontSize: 30,
                      ),
                    ),
                    if (!widget.isFormulario)
                      Row(
                        children: [
                          IconButton(
                            tooltip: "Excluir banco",
                            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 27, 7, 80)),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar Exclusão'),
                                    content: const Text('Tem certeza de que deseja excluir este banco?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancelar'),
                                        onPressed: () => Navigator.of(context).pop(false),
                                      ),
                                      TextButton(
                                        child: const Text('Excluir'),
                                        onPressed: () => Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                try {
                                  await _bancoList.excluirBanco(widget.banco.id ?? '');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Banco excluído com sucesso')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Erro ao excluir o banco')),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            tooltip: "Duplicar banco",
                            icon: const Icon(Icons.copy, color: Color.fromARGB(255, 27, 7, 80)),
                            onPressed: () async {
                              try {
                                await _bancoList.duplicarBanco(widget.banco.id ?? '');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Banco duplicado com sucesso')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Erro ao duplicar o banco')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
                const Divider(color: Colors.black),
                Text(
                  widget.banco.descricao,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
