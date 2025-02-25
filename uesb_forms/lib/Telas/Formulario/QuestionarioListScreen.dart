import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';

class QuestionarioListScreen extends StatefulWidget {
  @override
  _QuestionarioListScreenState createState() => _QuestionarioListScreenState();
}

class _QuestionarioListScreenState extends State<QuestionarioListScreen> {
  String filtroSelecionado = 'Todos';
  
  @override
  Widget build(BuildContext context) {
   Provider.of<QuestionarioList>(context).selecionarFiltro(filtroSelecionado);

  List<Questionario> questionarios = Provider.of<QuestionarioList>(context).obterQuestionariosFiltrados();


    
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Formulários'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _mostrarFiltros(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: questionarios.length,
        itemBuilder: (context, index) {
          return QuestionarioItem(questionario: questionarios[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }

  void _mostrarFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Líder'), onTap: () => _selecionarFiltro('Líder')),
            ListTile(title: Text('Entrevistador'), onTap: () => _selecionarFiltro('Entrevistador')),
            ListTile(title: Text('Aplicado'), onTap: () => _selecionarFiltro('Aplicado')),
            ListTile(title: Text('Publicado'), onTap: () => _selecionarFiltro('Publicado')),
            ListTile(title: Text('Em construção'), onTap: () => _selecionarFiltro('Em construção')),
            ListTile(title: Text('Publicado Visível'), onTap: () => _selecionarFiltro('Publicado Visível')),
            ListTile(title: Text('Publicado Não Visível'), onTap: () => _selecionarFiltro('Publicado Não Visível')),
          ],
        );
      },
    );
  }

void _selecionarFiltro(String filtro) {
  setState(() {
    filtroSelecionado = filtro;
  });
  // Atualiza o provider sem ouvir mudanças para evitar chamar notifyListeners() durante o build
  Provider.of<QuestionarioList>(context, listen: false).selecionarFiltro(filtroSelecionado);
  Navigator.pop(context);
}

}

class QuestionarioItem extends StatelessWidget {
  final Questionario questionario;

  QuestionarioItem({required this.questionario});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(questionario.nome),
        subtitle: Text(questionario.dataPublicacao?.toIso8601String() ?? 'Sem data'),

        trailing: PopupMenuButton<String>(
          onSelected: (value) => _acaoSelecionada(value, context),
          itemBuilder: (context) => _opcoesMenu(),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _opcoesMenu() {
    List<PopupMenuEntry<String>> opcoes = [];

    if (!questionario.publicado) {
      opcoes.add(PopupMenuItem(value: 'editar', child: Text('Editar')));
      opcoes.add(PopupMenuItem(value: 'excluir', child: Text('Excluir')));
    }
    if (questionario.publicado && !questionario.aplicado) {
      opcoes.add(PopupMenuItem(value: 'ativar', child: Text(questionario.ativo ? 'Desativar' : 'Ativar')));
    }
    if (questionario.publicado) {
      opcoes.add(PopupMenuItem(value: 'verDados', child: Text('Ver Dados')));
    }
    return opcoes;
  }

  void _acaoSelecionada(String value, BuildContext context) {
    switch (value) {
      case 'editar':
        // Implementar lógica de edição
        break;
      case 'excluir':
        // Implementar lógica de exclusão
        break;
      case 'ativar':
        // Implementar lógica de ativação/desativação
        break;
      case 'verDados':
        // Implementar lógica de visualização de dados
        break;
    }
  }
}
