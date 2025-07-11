import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/Formulario/FormularioLider.dart';
import 'package:uesb_forms/Controle_Modelo/aplicacao_list.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart'; // Certifique-se de importar a lista
import 'package:uesb_forms/Modelo/AplicacaoQuestionario.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Telas/Aplicacao/telaAplicacao.dart';
import 'package:uesb_forms/Telas/Aplicacao/telaTesteQuestionario.dart';

class QuestionarioliderGrupo extends StatefulWidget {
  final String grupoId;

  const QuestionarioliderGrupo({super.key, required this.grupoId});

  @override
  State<QuestionarioliderGrupo> createState() => _QuestionarioliderGrupoState();
}

class _QuestionarioliderGrupoState extends State<QuestionarioliderGrupo> {
  String _searchQuery = "";
  String _filtroSelecionado = "Todos";
  List<Questionario> _questionariosGrupo = [];

  @override
  void initState() {
    super.initState();
    _carregarQuestionarios();
  }

  Future<void> _carregarQuestionarios() async {
    final questionarios = await Provider.of<QuestionarioList>(context, listen: false)
        .buscarQuestionariosPorGrupo(widget.grupoId);
    setState(() {
      _questionariosGrupo = questionarios;
    });
  }

  void _aplicarQuestionario(Questionario questionario, BuildContext context) {
    try {
      final auth = Provider.of<AuthList>(context, listen: false);
      final aplicacaoList = Provider.of<AplicacaoList>(context, listen: false);

      if (!auth.isAutenticado()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faça login primeiro')),
        );
        return;
      }

      aplicacaoList.aplicacaoAtual = Aplicacaoquestionario(
        idAplicacao: DateTime.now().millisecondsSinceEpoch.toString(),
        idQuestionario: questionario.id,
        idEntrevistador: auth.usuario?.id ?? '',
        respostas: [],
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelaAplicacao(
            perfilUsuario: 'Entrevistador',
            idEntrevistador: auth.usuario?.id ?? '',
          ),
          settings: RouteSettings(arguments: questionario),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  void _testarQuestionario(Questionario questionario, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaTesteQuestionario(
          perfilUsuario: 'Líder',
          idEntrevistador: 'teste-${DateTime.now().millisecondsSinceEpoch}',
        ),
        settings: RouteSettings(arguments: questionario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionariosFiltrados = _questionariosGrupo.where((questionario) {
      bool matchesSearch = questionario.nome.toLowerCase().contains(_searchQuery.toLowerCase());

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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CategoriaChip("Todos", Icons.list, "Todos"),
                      _CategoriaChip("Visível Ativo", Icons.visibility, "Visível Ativo"),
                      _CategoriaChip("Visível Inativo", Icons.visibility_off, "Visível Inativo"),
                      _CategoriaChip("Não Visível", Icons.remove_red_eye, "Não Visível"),
                      _CategoriaChip("Encerrado", Icons.check, "Encerrado"),
                      _CategoriaChip("Não Publicado", Icons.hourglass_empty, "Não Publicado"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: questionariosFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum questionário encontrado",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: questionariosFiltrados.length,
                          itemBuilder: (ctx, index) {
                            final questionario = questionariosFiltrados[index];
                            return FormularioLider(
                              questionario: questionario,
                              onAplicar: () => _aplicarQuestionario(questionario, context),
                              onTestar: () => _testarQuestionario(questionario, context),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _CategoriaChip(String label, IconData icon, String filtro) {
    return GestureDetector(
      onTap: () => setState(() => _filtroSelecionado = filtro),
      child: Chip(
        label: Row(
          children: [
            Icon(
              icon,
              color: _filtroSelecionado == filtro
                  ? Colors.white
                  : const Color.fromARGB(249, 85, 16, 106),
              size: 20,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: _filtroSelecionado == filtro
                    ? Colors.white
                    : const Color.fromARGB(255, 19, 18, 19),
              ),
            ),
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
