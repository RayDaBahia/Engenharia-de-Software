import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widgetBanco_Questao.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';

class WidgetPesquisa extends StatefulWidget {
  const WidgetPesquisa({super.key});

  @override
  State<WidgetPesquisa> createState() => _WidgetPesquisaState();
}

class _WidgetPesquisaState extends State<WidgetPesquisa> {
  String nomeDoBanco = '';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely access Provider here after dependencies are established
    Provider.of<BancoList>(context, listen: false).getBanco();
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: true);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.8,
              child: Expanded(
              child: TextField(
                onChanged: (value) {
                   setState(() {
                    nomeDoBanco = value;
                    /*Expanded(
                      child: ListView.builder(
                        itemCount: bancoList.filtrarBancosPorNome(value).length,
                        itemBuilder: (context, index) {
                          final bancoQuestao = bancoList.filtrarBancosPorNome(value)[index];
                          return WidgetbancoQuestao(banco: bancoQuestao);
                        },
                      ),
                    );*/  
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nome do Banco',
                ),
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
