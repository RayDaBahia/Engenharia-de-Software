import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Modelo/grupo.dart';
import 'package:uesb_forms/Telas/Formulario/QuestionarioEntrevistadorPage.dart';
import 'package:uesb_forms/Telas/Grupos/pessoasGrupo.dart';
import 'package:uesb_forms/Telas/Grupos/questionarioEntrevistadorGrupo.dart';
import 'package:uesb_forms/Telas/Grupos/questionarioLider.dart'; // nome do arquivo com letra minúscula

class GrupoPage extends StatefulWidget {
  const GrupoPage({
    super.key,
  });

  @override
  State<GrupoPage> createState() => _GrupoPageState();
}

class _GrupoPageState extends State<GrupoPage> {
  int _selectedIndex = 0;
  late Grupo grupo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pega o grupo apenas uma vez
    grupo = ModalRoute.of(context)!.settings.arguments as Grupo;
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthList>(context, listen: false);

    final user = authUser!.usuario!.id;
    Widget formsEscolha = user == grupo.idLider
        ? QuestionarioliderGrupo(grupoId: grupo.id!)
        : Questionarioentrevistadorgrupo(grupoId: grupo.id!);// aqui é pra exibir do entrevistador

    final List<Widget> _screens = [
      // Aqui você pode adicionar mais páginas se quiser
      PessoasGrupo(grupo),
      formsEscolha, // Placeholder
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupo', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
        leading: const BackButton(),
        
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pessoas'),
          BottomNavigationBarItem(
              // se for lider eu mostro o forms de lider
              // se não for lider eu mostro o de entrevistador
              icon: Icon(Icons.article),
              label: 'Formulários'),
        ],
      ),
    );
  }
}
