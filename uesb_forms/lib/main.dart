import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/Qustionario.g.dart';
import 'package:uesb_forms/Modelo/questao.g.dart';
import 'package:uesb_forms/Telas/BancoDeQuestoes/meus_Bancos.dart';
import 'package:uesb_forms/Telas/BancoDeQuestoes/crud_Banco_Questoes.dart';
import 'package:uesb_forms/Telas/Formulario/ConfigurarAcesso.dart';
import 'package:uesb_forms/Telas/Formulario/EdicaoQuestionario.dart';
import 'package:uesb_forms/Telas/Formulario/Meus_Formularios.dart';
import 'package:uesb_forms/Telas/Formulario/SelecaoQuestoesBanco.dart';
import 'package:uesb_forms/Telas/Login.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:uesb_forms/Utils/firebase_options.dart';
import 'package:uesb_forms/Modelo/questao.dart';  // Importando Questao
import 'package:uesb_forms/Modelo/questionario.dart';  // Importando Questionario

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializando o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializando o Hive
  await Hive.initFlutter();

  // Registrando os adaptadores
  
  Hive.registerAdapter(QuestionarioAdapter());
  Hive.registerAdapter(QuestaoAdapter());
  Hive.registerAdapter(QuestaoTipoAdapter());

  
  await Hive.openBox('questionarioBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthList()),
         ChangeNotifierProvider(create: (_) => RespostasList()),
        ChangeNotifierProxyProvider<AuthList, BancoList>(
          create: (_) => BancoList(),
          update: (context, authList, previousBancoList) => BancoList(authList),
        ),
       ChangeNotifierProxyProvider<AuthList, QuestionarioList>(
              create: (_) => QuestionarioList(null), // Inicializa com `null` para evitar erro
              update: (context, authList, previous) => QuestionarioList(authList),
        ),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 18, 2, 47)),
          useMaterial3: true,
        ),
        routes: {
          Rotas.HOME: (ctx) => const Login(),
          Rotas.MEUS_FORMULARIOS: (ctx) => const MeusFormularios(),
          Rotas.MEUS_BANCOS: (ctx) => const MeusBancos(),
          Rotas.CRUD_BANCO: (ctx) => const CrudBancoQuestoes(),
          Rotas.SELECAO_QUESTOES_BANCO: (ctx) => SelecaoQuestoesBanco(),
          Rotas.EDICAO_FORMULARIO_TELA: (ctx) => EdicaoQuestionario(),
          Rotas.CONFIGURAR_ACESSO_FORMS: (ctx) => ConfigurarAcesso(),
      
        },
      ),
    );
  }
}
