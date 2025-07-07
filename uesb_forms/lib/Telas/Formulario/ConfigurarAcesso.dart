import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/grupo_list.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/grupo.dart';
import 'package:uesb_forms/Modelo/usuario.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Telas/Grupos/listaGrupos.dart'; // This import might not be strictly necessary for this file
import 'package:uesb_forms/Utils/rotas.dart';

class ConfigurarAcesso extends StatefulWidget {
  @override
  _ConfigurarAcessoState createState() => _ConfigurarAcessoState();
}

class _ConfigurarAcessoState extends State<ConfigurarAcesso> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _grupoSearchController = TextEditingController();
  bool _senhaVisivel = false;
  List<String> entrevistadores = [];
  List<Grupo> gruposSugeridos = [];
  Questionario? questionario;
  DateTime? _prazoSelecionado;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _grupoSearchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> dadosQuestionario = {
    'senha': null,
    'entrevistadores': [],
    'prazo': null,
    'publicado': false,
    'grupos': []
  };
  Set<String> gruposSelecionadosIds = {};
  List<Grupo> gruposSelecionadosCompletos = [];
  bool _carregandoGrupos = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Questionario) {
      questionario = args;
      _carregarDadosQuestionario(questionario!);

      // Carregar questões do questionário
      Provider.of<QuestionarioList>(context, listen: false)
          .buscarQuestoes(questionario!.id!);
    }
  }

  void _carregarDadosQuestionario(Questionario q) async {
    _senhaController.text = q.senha ?? '';
    _prazoSelecionado = q.prazo;

    // Correção: usar lista direta de emails
    entrevistadores = q.entrevistadores ?? [];

    gruposSelecionadosIds = (q.grupos ?? []).toSet();

    // Carrega grupos de forma assíncrona
    final grupos = await _carregarGruposPorIds(gruposSelecionadosIds.toList());

    if (mounted) {
      setState(() {
        gruposSelecionadosCompletos = grupos;
      });
    }

    // Remova o método _carregarGruposIniciais() não utilizado
  }

  void _removerEntrevistador(String email) {
    setState(() => entrevistadores.remove(email));
  }

  void _removerGrupo(String idGrupo) {
    setState(() {
      gruposSelecionadosIds.remove(idGrupo);
      gruposSelecionadosCompletos.removeWhere((g) => g.id == idGrupo);
    });
  }

  void _showPublishDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Publicar Questionário?"),
          content: Text("Deseja publicar o questionário agora?"),
          actions: [
            TextButton(
              onPressed: () => _handlePublishResponse(dialogContext, true),
              child: Text("Sim"),
            ),
            TextButton(
              onPressed: () => _handlePublishResponse(dialogContext, false),
              child: Text("Não"),
            ),
          ],
        );
      },
    );
  }
Future<void> _handlePublishResponse(BuildContext dialogContext, bool publicar) async {
  Navigator.of(dialogContext).pop(); // Fecha o AlertDialog

  _capturarInformacoes(publicar);

  // Aguarda o fechamento completo do AlertDialog
  await Future.delayed(Duration.zero);
  debugPrint('Infos capturadas');
  if (!mounted) return;
  debugPrint('Até antes do show dialog ok');


  try {
      debugPrint('Antes do finalizar ok');
    await _FinalizarQuestionario();
    debugPrint('tudo certo ao finalizar');
  } finally {
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Fecha o loading
      Navigator.pushReplacementNamed(context, Rotas.MEUS_FORMULARIOS);
    }
  }
}


  Future<void> _selecionarPrazo() async {
    DateTime now = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _prazoSelecionado ?? now, // Use existing date if available
      firstDate: now,
      lastDate:
          DateTime(now.year + 5), // Allow selecting up to 5 years from now
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: _prazoSelecionado != null
            ? TimeOfDay.fromDateTime(_prazoSelecionado!)
            : TimeOfDay.fromDateTime(now), // Use existing time if available
      );

      if (selectedTime != null) {
        setState(() {
          _prazoSelecionado = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  void _capturarInformacoes(bool publicado) {
    setState(() {
      dadosQuestionario['senha'] =
          _senhaController.text.isNotEmpty ? _senhaController.text : '';

      dadosQuestionario['entrevistadores'] = entrevistadores; // Lista direta

      dadosQuestionario['prazo'] = _prazoSelecionado;
      dadosQuestionario['publicado'] = publicado;

      dadosQuestionario['grupos'] = gruposSelecionadosIds.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Configurações Gerais",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () async {
                // Adicione async
                _capturarInformacoes(questionario?.publicado ?? false);
                if (questionario != null) {
                  questionario!.senha = _senhaController.text;
                  questionario!.entrevistadores = entrevistadores;
                  questionario!.prazo = _prazoSelecionado;
                  questionario!.grupos = gruposSelecionadosIds.toList();

                  await Provider.of<QuestionarioList>(context, listen: false)
                      .atualizarQuestionario(questionario!);

                  // Atualiza a tela anterior
                  Navigator.pushReplacementNamed(
                      context, Rotas.MEUS_FORMULARIOS);
                } else {
                  _showPublishDialog();
                }
              },
              child: Text(
                "Finalizar",
                style: TextStyle(
                  color: const Color.fromARGB(255, 1, 21, 37),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        // Wrap the entire column in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção Senha
              Text("Senha de acesso (Opcional)",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              TextField(
                controller: _senhaController,
                obscureText: !_senhaVisivel,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(_senhaVisivel
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // SEÇÃO: PESQUISA DE GRUPOS
              Text("Adicionar Grupos",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              TextField(
                controller: _grupoSearchController,
                decoration: InputDecoration(
                  hintText: "Pesquisar grupo",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      if (_grupoSearchController.text.isNotEmpty) {
                        _buscarGrupos(_grupoSearchController.text);
                      }
                    },
                  ),
                ),
                onChanged: (value) {
                  // Optional: Live search as user types
                  if (value.isNotEmpty) {
                    _buscarGrupos(value);
                  } else {
                    setState(() => gruposSugeridos.clear());
                  }
                },
              ),

              // Lista de grupos sugeridos
              if (gruposSugeridos.isNotEmpty)
                ConstrainedBox(
                  // Use ConstrainedBox for specific height within SingleChildScrollView
                  constraints: BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap:
                        true, // Important when inside SingleChildScrollView
                    itemCount: gruposSugeridos.length,
                    itemBuilder: (context, index) {
                      final grupo = gruposSugeridos[index];
                      return ListTile(
                        title: Text(grupo.nome),
                        trailing: IconButton(
                          icon: Icon(Icons.add, color: Colors.green),
                          onPressed: () => _adicionarGrupo(grupo),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 10),

              // Lista de grupos adicionados
              Text("Grupos adicionados",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              if (_carregandoGrupos)
                Center(child: CircularProgressIndicator())
              else
                ConstrainedBox(
                  // Use ConstrainedBox for specific height within SingleChildScrollView
                  constraints: BoxConstraints(maxHeight: 150),
                  child: gruposSelecionadosCompletos.isEmpty
                      ? Center(child: Text(""))
                      : ListView.builder(
                          addAutomaticKeepAlives: true, // Adicione esta linha
                          itemCount: gruposSelecionadosCompletos.length,
                          itemBuilder: (context, index) {
                            final grupo = gruposSelecionadosCompletos[index];
                            return Card(
                              child: ListTile(
                                title: Text(grupo.nome),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removerGrupo(grupo.id!),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              SizedBox(height: 20),

              // SEÇÃO ENTREVISTADORES
              Text("Adicionar entrevistadores",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Pesquisar e-mail",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {},
                  ),
                ),
                onChanged: (value) =>
                    setState(() {}), // Trigger rebuild to update StreamBuilder
              ),

              StreamBuilder<List<Usuario>>(
                stream: Provider.of<AuthList>(context)
                    .buscarUsuariosPorEmail(_emailController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Erro: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(""));
                  }
                  return ConstrainedBox(
                    // Constrain height for the search results
                    constraints: BoxConstraints(maxHeight: 150),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final usuario = snapshot.data![index];
                        return ListTile(
                          title: Text(usuario.nome ?? "Nome não disponível"),
                          subtitle:
                              Text(usuario.email ?? "Email não disponível"),
                          trailing: IconButton(
                            icon: Icon(Icons.add, color: Colors.green),
                            onPressed: () =>
                                _adicionarEntrevistador(usuario.email ?? ""),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              SizedBox(height: 20),
              Text("Entrevistadores adicionados",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 150),
                child: entrevistadores.isEmpty
                    ? Center(child: Text(""))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: entrevistadores.length,
                        itemBuilder: (context, index) {
                          final email = entrevistadores[index];
                          return Card(
                            child: ListTile(
                              title: Text(email),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removerEntrevistador(email),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Seção Prazo
              SizedBox(height: 20), // Add some space before the date picker
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to start
                children: [
                  Text("Selecionar prazo para o questionário",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _prazoSelecionado != null
                              ? "${_prazoSelecionado!.toLocal().day}/${_prazoSelecionado!.toLocal().month}/${_prazoSelecionado!.toLocal().year} ${_prazoSelecionado!.toLocal().hour}:${_prazoSelecionado!.toLocal().minute.toString().padLeft(2, '0')}"
                              : "Nenhum prazo selecionado",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Colors.blue),
                        onPressed: _selecionarPrazo,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20), // Space at the bottom
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _buscarGrupos(String termo) async {
    try {
      final grupoList = Provider.of<GrupoList>(context, listen: false);
      final grupos = await grupoList.buscarGruposPorNome(termo);

      if (mounted) {
        setState(() {
          // Filter out groups already selected
          gruposSugeridos = grupos
              .where(
                  (g) => g.id != null && !gruposSelecionadosIds.contains(g.id))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Erro na busca de grupos: $e");
      // Optionally show a user-friendly error message
    }
  }

  void _adicionarEntrevistador(String email) {
    if (email.isNotEmpty && !entrevistadores.contains(email)) {
      setState(() => entrevistadores.add(email));
      _emailController.clear();
    }
  }

  void _adicionarGrupo(Grupo grupo) {
    if (grupo.id != null && !gruposSelecionadosIds.contains(grupo.id)) {
      setState(() {
        gruposSelecionadosIds.add(grupo.id!);
        gruposSelecionadosCompletos.add(grupo);
        _grupoSearchController.clear();
        gruposSugeridos.clear();
      });
      Provider.of<GrupoList>(context, listen: false);
    }
  }

// Verifique se o questionário foi realmente salvo
Future<void> _FinalizarQuestionario() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('Usuário não está autenticado. Cancelando salvamento.');
    // Aqui você pode exibir um diálogo ou mensagem de erro na UI também
    return;
  }

  final questionarioProvider =
      Provider.of<QuestionarioList>(context, listen: false);

  try {
    await questionarioProvider.adicionarQuestionario(
      senha: dadosQuestionario['senha'],
      entrevistadores: dadosQuestionario['entrevistadores'],
      prazo: dadosQuestionario['prazo'],
      publicado: dadosQuestionario['publicado'],
      gruposIds: dadosQuestionario['grupos'],
    );
    print('Questionário salvo com sucesso.');
  } catch (e, stacktrace) {
    print('Erro ao salvar questionário: $e');
    print(stacktrace);
  }
}

  Future<List<Grupo>> _carregarGruposPorIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final grupoList = Provider.of<GrupoList>(context, listen: false);
      return await grupoList.buscarGruposPorIds(ids);
    } catch (e) {
      debugPrint("Erro ao carregar grupos por IDs: $e");
      return [];
    }
  }
}
