import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Controle_Modelo/QuestionarioProvider%20.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Telas/BancoDeQuestoes/meus_Formularios.dart';
import 'package:uesb_forms/Telas/BancoDeQuestoes/crud_Banco_Questoes.dart';
import 'package:uesb_forms/Telas/login.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Utils/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialize o Firebase com as opções específicas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>AuthList(),),
        ChangeNotifierProvider(create: (_)=> QuestionarioProvider ()),
        //O ProductService sempre terá acesso à instância mais atualizada do AuthService,
       ChangeNotifierProxyProvider<AuthList, BancoList >(
        create: (_)=>BancoList(),
        
        update: (context, authList, previousBancoList)
        => BancoList(authList)
        ,)

    
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
          Rotas.MEUS_BANCOS: (ctx)=> CrudBancoQuestoes()
        },
        
      ),
    );
  }
}
