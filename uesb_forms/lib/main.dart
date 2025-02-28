import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Telas/BancoDeQuestoes/meus_Bancos.dart';
import 'package:uesb_forms/Telas/BancoDeQuestoes/crud_Banco_Questoes.dart';
import 'package:uesb_forms/Telas/Formulario/Configruacoes.dart';
import 'package:uesb_forms/Telas/Formulario/ConfigurarAcesso.dart';
import 'package:uesb_forms/Telas/Formulario/EdicaoQuestionario.dart';
import 'package:uesb_forms/Telas/Formulario/Meus_Formularios.dart';
import 'package:uesb_forms/Telas/Formulario/SelecaoQuestoesBanco.dart';

import 'package:uesb_forms/Telas/Login.dart';

import 'package:uesb_forms/Utils/rotas.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Utils/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>AuthList(),),
        //O ProductService sempre terá acesso à instância mais atualizada do AuthService,
       ChangeNotifierProxyProvider<AuthList, BancoList >(
        create: (_)=>BancoList(),
        
        update: (context, authList, previousBancoList)
        => BancoList(authList)
        ,),

        
  ChangeNotifierProxyProvider<AuthList, QuestionarioList >(
        create: (_)=>QuestionarioList(),
        
        update: (context, authList, previousBancoList)
        => QuestionarioList(authList)
        ,)


    
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.white
            )
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          
        ),
        //home: MeusFormularios(),
        routes: {
          Rotas.HOME: (ctx) => const Login(),
          Rotas.MEUS_FORMULARIOS: (ctx) => const MeusFormularios(),
          Rotas.MEUS_BANCOS: (ctx)=> const MeusBancos( ),
          Rotas.CRUD_BANCO: (ctx)=> const CrudBancoQuestoes( ),
          Rotas.CRIAR_FORMULARIO: (ctx)=> const Configruacoes(),
        
          Rotas.SELECAO_QUESTOES_BANCO: (ctx)=>  SelecaoQuestoesBanco (), 
          Rotas.EDICAO_FORMULARIO_TELA: (ctx)=> EdicaoQuestionario(),
          Rotas.CONFIGURAR_ACESSO_FORMS: (ctx) => ConfigurarAcesso()
        },
        
      ),
    );
  }
}