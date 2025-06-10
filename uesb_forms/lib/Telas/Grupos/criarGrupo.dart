import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Controle_Modelo/grupo_list.dart';
import 'package:uesb_forms/Modelo/grupo.dart';
import 'package:uesb_forms/Modelo/usuario.dart';

class Criargrupo extends StatefulWidget {
  const Criargrupo({super.key});

  @override
  State<Criargrupo> createState() => CriargrupoState();
}

class CriargrupoState extends State<Criargrupo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<String> entrevistadores = [];

  Grupo? grupo;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Grupo) {
        grupo = args;
        _nomeController.text = grupo?.nome ?? '';
        _descricaoController.text = grupo?.descricao ?? '';
        entrevistadores = grupo?.idEntrevistadores ?? [];
      }
      _isLoaded = true;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _adicionarEntrevistador(String email) {
    if (email.isNotEmpty && !entrevistadores.contains(email)) {
      setState(() => entrevistadores.add(email));
      _emailController.clear();
    }
  }

  void _removerEntrevistador(String email) {
    setState(() => entrevistadores.remove(email));
  }

  void _criarGrupo() async {
    final grupoList = Provider.of<GrupoList>(context, listen: false);

    await grupoList.addGrupo(
      _nomeController.text,
      _descricaoController.text,
      entrevistadores, // lista de emails
    );

    setState(() {
      _nomeController.clear();
      _descricaoController.clear();
      entrevistadores.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grupo criado com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _atualizarGrupo(BuildContext contexto) async {
    final grupoList = Provider.of<GrupoList>(context, listen: false);

    Grupo grupoAtualizado = Grupo(
      id: grupo!.id,
      nome: _nomeController.text,
      idLider: grupo!.idLider,
      descricao: _descricaoController.text.isNotEmpty
          ? _descricaoController.text
          : '', // String vazia se nada for digitado
      idEntrevistadores: entrevistadores,
      dataCriacao: grupo!.dataCriacao ?? DateTime.now(),
    );

    await grupoList.atualizarGrupo(grupoAtualizado);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grupo atualizado com sucesso'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    Navigator.of(contexto).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: grupo == null
              ? Text('Criar grupo', style: TextStyle(color: Colors.white))
              : Text('Atualizar grupo', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 45, 12, 68),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nome do Grupo',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      TextFormField(
                        controller: _nomeController,
                        maxLength: 80,
                        decoration: InputDecoration(
                          hintText: 'Digite o nome do grupo',
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'O nome é obrigatório';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Text('Descrição',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      TextFormField(
                        controller: _descricaoController,
                        maxLength: 150,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Insira aqui uma descrição para o seu grupo!',
                          counterText: '',
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Adicionar entrevistadores",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: "Pesquisar e-mail",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                      SizedBox(height: 10),

                      StreamBuilder<List<Usuario>>(
                        stream: Provider.of<AuthList>(context)
                            .buscarUsuariosPorEmail(_emailController.text),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text("Erro ao carregar usuários");
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text("Nenhum usuário encontrado");
                          }

                          return Column(
                            children: snapshot.data!.map((usuario) {
                              return ListTile(
                                title:
                                    Text(usuario.nome ?? "Nome não disponível"),
                                subtitle:
                                    Text(usuario.email ?? "Email não disponível"),
                                trailing: IconButton(
                                  icon: Icon(Icons.add, color: Colors.green),
                                  onPressed: () => _adicionarEntrevistador(
                                      usuario.email ?? ""),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Text("Entrevistadores adicionados",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Column(
                        children: List.generate(entrevistadores.length, (index) {
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
                        }),
                      ),

                      SizedBox(height: 80), // Espaço extra pro botão não sobrepor
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        grupo == null
                            ? _criarGrupo()
                            : _atualizarGrupo(context);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF1B0C2F),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: MenuLateral(),
    );
  }
}
