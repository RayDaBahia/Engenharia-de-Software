import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Controle_Modelo/QuestionarioProvider%20.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Telas/BancoDeQuestoes/Meus_Formularios.dart';
import 'package:uesb_forms/Telas/BancoDeQuestoes/criar_Banco_Questoes.dart';
import 'package:uesb_forms/Telas/Login.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Utils/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>AuthList(),),
        ChangeNotifierProvider(create: (_)=> QuestionarioProvider ())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          
        ),
        //home: MeusFormularios(),
        routes: {
          Rotas.HOME: (ctx) => Login(),
          Rotas.MEUS_FORMULARIOS: (ctx) => const MeusFormularios(),
          Rotas.MEUS_BANCOS: (ctx)=> CriarBancoQuestoes()
        },
        
      ),
    );
  }
}
