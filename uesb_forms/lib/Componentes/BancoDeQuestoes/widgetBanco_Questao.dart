import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Certifique-se de que o Provider esteja importado
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class WidgetbancoQuestao extends StatelessWidget {
  final Banco banco;
  final bool isFormulario;

  const WidgetbancoQuestao({
    super.key,
    required this.banco, required this.isFormulario,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.sizeOf(context);
    var screenWidth = screenSize.width;

    // Recupera o BancoList a partir do Provider
    final bancoList = Provider.of<BancoList>(context, listen: false);

    return InkWell(
      onTap: () {
        if(!isFormulario){
        Navigator.of(context).pushNamed(Rotas.CRUD_BANCO, arguments: banco);}
        else{
   Navigator.of(context).pushNamed(
          Rotas.SELECAO_QUESTOES_BANCO,
          arguments: banco,
        );


      }},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: screenWidth,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      banco!.nome,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 27, 7, 80),
                        fontSize: 30,
                      ),
                    ),
                    if(!isFormulario)
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Color.fromARGB(255, 27, 7, 80),
                            onPressed: () async {
                              // Exibe um diálogo de confirmação
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirmar Exclusão'),
                                    content: Text(
                                        'Tem certeza de que deseja excluir este banco?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Cancelar'),
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                              false); // Retorna 'false' ao pressionar "Cancelar"
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Excluir'),
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                              true); // Retorna 'true' ao pressionar "Excluir"
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Se o usuário confirmou a exclusão
                              if (confirm == true) {
                                try {
                                  await bancoList.excluirBanco(banco.id ?? '');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Banco excluído com sucesso')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Erro ao excluir o banco')),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.copy),
                            color: Color.fromARGB(255, 27, 7, 80),
                            onPressed: () async {
                              try {
                                await bancoList.duplicarBanco(banco.id ?? '');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Banco duplicado com sucesso')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Erro ao duplicar o banco')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                const Divider(
                  color: Colors.black,
                ),
                Text(
                  banco!.descricao,
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
