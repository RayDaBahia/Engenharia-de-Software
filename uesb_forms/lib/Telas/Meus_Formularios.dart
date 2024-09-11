import 'package:flutter/material.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';

class MeusFormularios  extends StatelessWidget {
  const MeusFormularios ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Uesb Formularios'),),
      body: Center(
        child: Text('Sem formulários'),
      ),
      drawer: MenuLateral(),
    );
  }
}