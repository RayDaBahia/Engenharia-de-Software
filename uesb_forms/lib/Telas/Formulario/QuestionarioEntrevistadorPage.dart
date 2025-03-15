import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/Formulario/FormularioEntrevistador.dart';
import 'package:uesb_forms/Componentes/Formulario/FormularioLider.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';


class QuestionariosEntrevistadorPage extends StatefulWidget {
  const QuestionariosEntrevistadorPage({super.key});

  @override
  State<QuestionariosEntrevistadorPage> createState() => _QuestionariosEntrevistadorPageState();
}

class _QuestionariosEntrevistadorPageState extends State<QuestionariosEntrevistadorPage> {
  String _searchQuery = ""; // Armazena o termo de pesquisa
  String _filtroSelecionado = "Todos"; // Filtro atual (padrão: mostrar todos)

  @override
  Widget build(BuildContext context) {
    Provider.of<QuestionarioList>(context, listen: true).carregarQuestionariosEntrevistador();
    final questionariosEntrevistador = context.watch<QuestionarioList>().questionariosEntrevistador.where((questionario) {
      bool matchesSearch = questionario.nome.toLowerCase().contains(_searchQuery.toLowerCase());
      switch (_filtroSelecionado) {
        case "Inativos":
          return !questionario.ativo && matchesSearch;
        case "Ativos":
          return questionario.ativo && matchesSearch;
        case "Encerrados":
          return !questionario.ativo && questionario.publicado && matchesSearch;
        case "Bloqueados":
          return (questionario.senha?.isNotEmpty ?? false) && matchesSearch;
        default:
          return matchesSearch;
      }
    }).toList();

    return questionariosEntrevistador.isEmpty
        ? const Center(
            child: Text(
              'Você ainda não possui questionários como Entrevistador',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        : Column(
            children: [
              // Barra de pesquisa
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Pesquisar por nome',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),

              // Filtros de categoria
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CategoriaChip("Todos", Icons.list, "Todos"),
                      _CategoriaChip("Ativos", Icons.visibility, "Ativos"),
                      _CategoriaChip("Inativos", Icons.visibility_off, "Inativos"),
                      _CategoriaChip("Bloqueados", Icons.lock, "Bloqueados"),
                      _CategoriaChip("Encerrados", Icons.check, "Encerrados"),
                    ],
                  ),
                ),
              ),

              // Lista de questionários
              Expanded(
                child: ListView.builder(
                  itemCount: questionariosEntrevistador.length,
                  itemBuilder: (ctx, index) {
                    final questionario = questionariosEntrevistador[index];

                  

                        return FormularioEntrevistador(
                          questionario: questionario,
                          //numRespostas: respostas,
                        
                        );
                     
                    
                  },
                ),
              ),
            ],
          );
  }

  /// Componente Chip para selecionar categorias (somente um ativo por vez)
  Widget _CategoriaChip(String label, IconData icon, String filtro) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroSelecionado = filtro;
        });
      },
      child: Chip(
        label: Row(
          children: [
            Icon(icon, color: _filtroSelecionado == filtro ? Colors.white : const Color.fromARGB(249, 85, 16, 106), size: 20),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: _filtroSelecionado == filtro ? Colors.white : const Color.fromARGB(255, 19, 18, 19))),
          ],
        ),
        backgroundColor: _filtroSelecionado == filtro ? const Color.fromARGB(255, 45, 12, 68): const Color.fromARGB(255, 254, 253, 253),
        side: BorderSide(color: const Color.fromARGB(255, 45, 12, 68)), // Borda visível quando não está selecionado
      ),
    );
  }
}
