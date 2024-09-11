import 'package:flutter/material.dart';
import 'package:uesb_forms/Telas/Meus_Formularios.dart';
import 'package:uesb_forms/Utils/rotas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
   
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),



    routes: {

      Rotas.HOME: (ctx)=> const MeusFormularios(),
    },
    );
  }
}

