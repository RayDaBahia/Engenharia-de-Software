import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Modelo/auth_list.dart';

class MeusFormularios  extends StatelessWidget {
  const MeusFormularios ({super.key});



  @override
  Widget build(BuildContext context) {


 final authUser=Provider.of<AuthList>(context, listen: false);
    return Scaffold(

      appBar: AppBar(title: Text('Uesb Formularios'),),
      body: Center(
        child: Text('Bem Vindo(a) ${authUser.usuario!.nome}'),
      ),
      drawer: MenuLateral(),
    );
  }
}