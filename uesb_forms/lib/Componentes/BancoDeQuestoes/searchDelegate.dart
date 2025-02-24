import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class MySearchDelegate extends SearchDelegate {
  final List<Banco> listaDeBancos;
  final bool isFormulario; // Torna final para evitar modificações acidentais

  MySearchDelegate(this.listaDeBancos, {this.isFormulario = false}); // Agora é um parâmetro nomeado opcional

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
    List<Banco> results = listaDeBancos
        .where((banco) => banco.nome.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].nome),
          onTap: () {
            if (!isFormulario) {
              // Se não for um formulário, navega para CRUD_BANCO
              Navigator.of(context).pushNamed(
                Rotas.CRUD_BANCO,
                arguments: results[index], // Passando o banco como argumento
              );
            } else {
              // Se for um formulário, navega para SELECAO_QUESTOES_BANCO com argumentos no formato correto
              Navigator.of(context).pushNamed(
                Rotas.SELECAO_QUESTOES_BANCO,
                arguments: {
                  'banco': results[index], // Agora está correto
                  'isAlteracao': false, // Se precisar passar essa informação
                },
              );
            }
            close(context, null); // Fecha a pesquisa após a navegação
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Banco> suggestions = listaDeBancos
        .where((banco) => banco.nome.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].nome),
          onTap: () {
            if (!isFormulario) {
              Navigator.of(context).pushNamed(
                Rotas.CRUD_BANCO,
                arguments: suggestions[index],
              );
            } else {
              Navigator.of(context).pushNamed(
                Rotas.SELECAO_QUESTOES_BANCO,
                arguments: {
                  'banco': suggestions[index], // Agora está correto
                  'isAlteracao': true, // Se precisar passar essa informação
                },
              );
            }
            close(context, null);
          },
        );
      },
    );
  }
}
