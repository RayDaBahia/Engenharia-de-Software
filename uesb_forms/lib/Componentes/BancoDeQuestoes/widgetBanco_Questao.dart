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
          Navigator.of(context)
              .pushNamed(Rotas.CRUD_BANCO, arguments: widget.banco);
        } else {
          Navigator.of(context).pushNamed(
            Rotas.SELECAO_QUESTOES_BANCO,
            arguments: {'banco': widget.banco},
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.banco.nome.length > 25
                            ? '${widget.banco.nome.substring(0, 25)}...'
                            : widget.banco.nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!widget.isFormulario)
                      Row(
                        children: [
                          IconButton(
                            tooltip: "Excluir banco",
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar Exclusão'),
                                    content: const Text(
                                        'Tem certeza de que deseja excluir este banco?'),
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
                                try {
                                  await _bancoList
                                      .excluirBanco(widget.banco.id ?? '');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Banco excluído com sucesso')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Erro ao excluir o banco')),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                          IconButton(
                            tooltip: "Duplicar banco",
                            icon: const Icon(Icons.copy, color: Colors.white),
                            onPressed: () async {
                              try {
                                await _bancoList
                                    .duplicarBanco(widget.banco.id ?? '');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Banco duplicado com sucesso')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Erro ao duplicar o banco')),
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
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.banco.descricao.length > 50
                          ? '${widget.banco.descricao.substring(0, 50)}...'
                          : widget.banco.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
