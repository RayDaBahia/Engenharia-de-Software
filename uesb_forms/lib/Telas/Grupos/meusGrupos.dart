import 'package:flutter/material.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Telas/Grupos/criarGrupo.dart';
import 'package:uesb_forms/Telas/Grupos/listaGrupos.dart';

class Meusgrupos extends StatefulWidget {
  const Meusgrupos({super.key});

  @override
  State<Meusgrupos> createState() => _MeusgruposState();
}

class _MeusgruposState extends State<Meusgrupos> {
  String _perfilSelecionado = "Líder";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Grupos', style: const TextStyle(color: Colors.white)),
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
                const PopupMenuItem(value: "Líder", child: Text("Líder")),
                const PopupMenuItem(
                  value: "Entrevistador",
                  child: Text("Entrevistador"),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _perfilSelecionado == "Líder"
                      ? Icons
                            .person // Ícone para Líder
                      : Icons.assignment_ind, // Ícone para Entrevistador
                  color: const Color.fromARGB(
                    255,
                    233,
                    233,
                    234,
                  ), // Cor do ícone
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: MenuLateral(),
      body: _perfilSelecionado == 'Líder'
          ? ListaGrupos(key: ValueKey('lider'), lider: true)
          : ListaGrupos(key: ValueKey('entrevistador'), lider: false),
    );
  }
}
