import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class MeusFormularios extends StatelessWidget {
  const MeusFormularios({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthList>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Meus Formulários',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centraliza os widgets
        children: [
          const Text(
            'Você ainda não possui formulários',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20), // Espaçamento entre os widgets
          SizedBox(
            height: screenHeight * 0.3,
            child: Image.asset(
              "images/form_roxo.png",
              fit: BoxFit.fill,
            ),
          ),
          const Spacer(), // Empurra o botão para baixo
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0), // Distância do botão em relação ao rodapé
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Rotas.CRIAR_FORMULARIO);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 27, 7, 80),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      drawer: const MenuLateral(),
    );
  }
}

