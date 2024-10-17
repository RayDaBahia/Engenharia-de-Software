import 'package:flutter/material.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class MySearchDelegate extends SearchDelegate {
  final List<String> nomesBancos;

  MySearchDelegate(this.nomesBancos);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Limpa a pesquisa
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Fecha a pesquisa
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> results = nomesBancos
        .where((banco) => banco.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return
         ListTile(
          title: Text(results[index]),
          onTap: () {
            // Navega para a tela do banco passando o nome do banco selecionado como argumento
            Navigator.of(context).pushNamed(
              Rotas.CRUD_BANCO,
              arguments:
                  results[index], // Aqui você passa o argumento para a rota
            );
            close(context, null); // Fecha a pesquisa após a navegação
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = nomesBancos
        .where((banco) => banco.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            // Navega para a tela do banco passando o nome do banco selecionado como argumento
            Navigator.of(context).pushNamed(
              Rotas.CRUD_BANCO,
              arguments:
                  suggestions[index], // Aqui você passa o argumento para a rota
            );
            close(context, null); // Fecha a pesquisa após a navegação
          },
        );
      },
    );
  }
}
