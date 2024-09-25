import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_mE_obj.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';

class MeusFormularios extends StatelessWidget {
  const MeusFormularios({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthList>(context, listen: false);

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Uesb Formularios',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 27, 7, 80),
      ),
     body: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bem Vindo(a) nome do usuário'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 150),
          ),
          Container(
            height: screenHeight * 0.3,
            width: screenHeight * 0.4,
            child: Image.asset(
              "images/form_roxo.png",
              fit: BoxFit.fill,

         
      ),
          ),
        ],
       
     ),
      drawer: MenuLateral()
    );
   
    
  }
}