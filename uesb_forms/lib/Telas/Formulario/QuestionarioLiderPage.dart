import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/Formulario/FormularioLider.dart';
import 'package:uesb_forms/Controle_Modelo/aplicacao_list.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/AplicacaoQuestionario.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:uesb_forms/Telas/Aplicacao/telaAplicacao.dart';

class QuestionariosLiderPage extends StatefulWidget {
  const QuestionariosLiderPage({super.key});

  @override
  _QuestionariosLiderPageState createState() => _QuestionariosLiderPageState();
}

class _QuestionariosLiderPageState extends State<QuestionariosLiderPage> {
  String _searchQuery = "";
  String _filtroSelecionado = "Todos";

  void _testarQuestionario(Questionario questionario, BuildContext context) {
// Navegar para a tela passando o questionário
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaAplicacao(
          perfilUsuario: 'Entrevistador',
          idEntrevistador: '123',
        ),
        settings: RouteSettings(arguments: questionario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionariosLider = Provider.of<QuestionarioList>(context)
        .questionariosLider
        .where((questionario) {
      bool matchesSearch =
          questionario.nome.toLowerCase().contains(_searchQuery.toLowerCase());

      switch (_filtroSelecionado) {
        case "Visível Ativo":
          return questionario.visivel && questionario.ativo && matchesSearch;
        case "Visível Inativo":
          return questionario.visivel && !questionario.ativo && matchesSearch;
        case "Não Visível":
          return !questionario.visivel && matchesSearch;
        case "Encerrado":
          return !questionario.ativo && questionario.publicado && matchesSearch;
        case "Não Publicado":
          return !questionario.publicado && matchesSearch;
        default:
          return matchesSearch;
      }
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Barra de pesquisa (mantido igual)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (query) => setState(() => _searchQuery = query),
                  decoration: InputDecoration(
                    labelText: 'Pesquisar por nome',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),

              // Filtros (mantido igual)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CategoriaChip("Todos", Icons.list, "Todos"),
                      _CategoriaChip(
                          "Visível Ativo", Icons.visibility, "Visível Ativo"),
                      _CategoriaChip("Visível Inativo", Icons.visibility_off,
                          "Visível Inativo"),
                      _CategoriaChip(
                          "Não Visível", Icons.remove_red_eye, "Não Visível"),
                      _CategoriaChip("Encerrado", Icons.check, "Encerrado"),
                      _CategoriaChip("Não Publicado", Icons.hourglass_empty,
                          "Não Publicado"),
                    ],
                  ),
                ),
              ),

              // Lista de questionários
              Expanded(
                child: questionariosLider.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum questionário encontrado",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: questionariosLider.length,
                          itemBuilder: (ctx, index) {
                            final questionario = questionariosLider[index];
                            return FormularioLider(
                              questionario: questionario,
                              onTestar: () => _testarQuestionario(
                                  questionario as Questionario, context),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),

          // Botão flutuante (mantido igual)
          Positioned(
            bottom: 40,
            right: 20,
            child: _botaoAdicionarFormulario(context),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares (mantidos iguais)
  Widget _botaoAdicionarFormulario(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: ElevatedButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(Rotas.EDICAO_FORMULARIO_TELA),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 45, 12, 68),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
        ),
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _CategoriaChip(String label, IconData icon, String filtro) {
    return GestureDetector(
      onTap: () => setState(() => _filtroSelecionado = filtro),
      child: Chip(
        label: Row(
          children: [
            Icon(icon,
                color: _filtroSelecionado == filtro
                    ? Colors.white
                    : const Color.fromARGB(249, 85, 16, 106),
                size: 20),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: _filtroSelecionado == filtro
                        ? Colors.white
                        : const Color.fromARGB(255, 19, 18, 19))),
          ],
        ),
        backgroundColor: _filtroSelecionado == filtro
            ? const Color.fromARGB(255, 45, 12, 68)
            : const Color.fromARGB(255, 254, 253, 253),
        side: const BorderSide(color: Color.fromARGB(255, 45, 12, 68)),
      ),
    );
  }
}
