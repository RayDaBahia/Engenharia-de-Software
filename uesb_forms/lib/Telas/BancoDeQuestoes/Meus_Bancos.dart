import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widgetBanco_Questao.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:uesb_forms/Modelo/Banco.dart';


class MeusBancos extends StatefulWidget {
  const MeusBancos({super.key});

  @override
  State<MeusBancos> createState() => _MeusBancosState();
  
}

class _MeusBancosState extends State<MeusBancos> {

  @override
  void initState() {
    super.initState();
    // Do not access context-dependent services here
  }

  @override
  void didChangeDependencies() {

/*
que é chamado depois que o widget é inserido na árvore e quando suas dependências mudam
*/
    super.didChangeDependencies();
   
    Provider.of<BancoList>(context, listen: false).getBanco();
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: true);
    return Scaffold(
      drawer: MenuLateral(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
      ),
      body: Column(
  children: [
    if (bancoList.bancosLista.isNotEmpty) ...[
      Expanded(
        child: ListView.builder(
          itemCount: bancoList.bancosLista.length,
          itemBuilder: (context, index) {
            final bancoQuestao = bancoList.bancosLista[index];
            return WidgetbancoQuestao(banco: bancoQuestao);
          },
        ),
      ),
    ] else ...[
      Center(child: Text('Você não possui bancos')),
    ],
    // Botão para adicionar novo banco
    SizedBox(
      height: 50,
      width: 10,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Rotas.CRUD_BANCO);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 27, 7, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '+',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        
      ),
    ),
    
  ],
)
   
    );
  }

}

