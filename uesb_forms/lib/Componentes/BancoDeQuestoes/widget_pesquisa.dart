import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/searchDelegate.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widgetBanco_Questao.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';

class WidgetPesquisa extends StatefulWidget {
  final List<String> nomesBancos; // Recebe a lista de nomes dos bancos
  WidgetPesquisa({super.key, required this.nomesBancos});

  @override
  State<WidgetPesquisa> createState() => _WidgetPesquisaState();
}

class _WidgetPesquisaState extends State<WidgetPesquisa> {
  String nomeDoBanco = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: TextField(
              onTap: () => showSearch(
                context: context,
                delegate: MySearchDelegate(widget
                    .nomesBancos), // Passa os nomes dos bancos para o delegate
              ),
              onChanged: (value) {
                setState(
                  () {
                    nomeDoBanco = value;
                    showSearch(
                      context: context,
                      delegate: MySearchDelegate(
                          widget.nomesBancos), // Usa a lista para pesquisa
                    );
                  },
                );
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nome do Banco',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
