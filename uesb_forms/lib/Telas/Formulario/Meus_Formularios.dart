import 'package:flutter/material.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Telas/Formulario/QuestionarioEntrevistadorPage.dart';
import 'package:uesb_forms/Telas/Formulario/QuestionarioLiderPage.dart';

class MeusFormularios extends StatefulWidget {
  const MeusFormularios({super.key});

  @override
  _MeusFormulariosState createState() => _MeusFormulariosState();
}

class _MeusFormulariosState extends State<MeusFormularios> {
  String _perfilSelecionado = "Líder"; // Perfil padrão

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '$_perfilSelecionado - Meus Formulários',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              onSelected: (String perfil) {
                setState(() {
                  _perfilSelecionado = perfil;
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: "Líder",
                  child: Text("Líder"),
                ),
                const PopupMenuItem(
                  value: "Entrevistador",
                  child: Text("Entrevistador"),
                ),
              ],
              child: Container(
                /*decoration: const BoxDecoration(
                  color: Colors.white, // Fundo branco
                  shape: BoxShape.circle,
                ),*/
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _perfilSelecionado == "Líder"
                      ? Icons.person // Ícone para Líder
                      : Icons.assignment_ind, // Ícone para Entrevistador
                  color: const Color.fromARGB(255, 233, 233, 234), // Cor do ícone
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const MenuLateral(),
      body: _perfilSelecionado == "Líder"
          ? const QuestionariosLiderPage()
          : const QuestionariosEntrevistadorPage()
    );
  }
}
