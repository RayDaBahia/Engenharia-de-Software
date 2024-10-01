import 'package:flutter/material.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/banco.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class MeusBancos extends StatefulWidget {
  const MeusBancos({super.key});

  @override
  State<MeusBancos> createState() => _MeusBancosState();
}

class _MeusBancosState extends State<MeusBancos> {
  @override
  Widget build(BuildContext context) {
    BancoList bancoList = BancoList();

    var screenSize = MediaQuery.sizeOf(context);
    var screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
      ),
      body: FutureBuilder<List<Widget>>(
        future: inicializarComponentes(bancoList, screenWidth),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Exibe o erro no console para depuração
            print('Erro: ${snapshot.error}');
            return ListView(
              children: [
                Text('Erro ao carregar os bancos'),
              ],
            );
          } else if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!,
            );
          } else {
            return const Center(child: Text('Nenhum banco disponível'));
          }
        },
      ),
    );
  }

  Future<List<Widget>> inicializarComponentes(
      BancoList bd, double screenWidth) async {
    try {
      List<Banco> bancos = bd.bancosLista;

      List<Widget> componentesList = [];

      for (Banco banco in bancos) {
        componentesList.add(Padding(
          padding: const EdgeInsets.all(16),
          child: criarComponente(screenWidth, banco.nome, banco.descricao),
        ));
      }

      componentesList.add(
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
      );

      return componentesList;
    } catch (e) {
      print('Erro ao inicializar componentes: $e');
      throw e;
    }
  }
}

Container criarComponente(
    double screenWidth, String nomeBancoP, String descricaoBancoP) {
  return Container(
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
          Text(
            nomeBancoP,
            style: const TextStyle(
              color: Color.fromARGB(255, 27, 7, 80),
              fontSize: 30,
            ),
          ),
          const Divider(
            color: Colors.black,
          ),
          Text(
            descricaoBancoP,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  );
}
