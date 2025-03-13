import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/usuario.dart'; // Assumindo que a classe Usuario está definida nesse arquivo
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Utils/rotas.dart'; // O modelo de AuthList que contém a lógica de busca

class ConfigurarAcesso extends StatefulWidget {
  @override
  _ConfigurarAcessoState createState() => _ConfigurarAcessoState();
}

class _ConfigurarAcessoState extends State<ConfigurarAcesso> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  List<Map<String, dynamic>> entrevistadores = [];

  late Questionario questionario;
  DateTime? _prazoSelecionado;

  // Variável para armazenar os dados do questionário
  Map<String, dynamic> dadosQuestionario = {
    'senha': null,
    'entrevistadores': [],
    'prazo': null,
    'publicado': false
  };

  void _adicionarEntrevistador(String email) {
    if (email.isNotEmpty && !entrevistadores.any((e) => e["email"] == email)) {
      setState(() {
        entrevistadores.add({"email": email, "selecionado": false});
      });
      _emailController.clear();
    }
  }

  void _removerEntrevistador(String email) {
    setState(() {
      entrevistadores.removeWhere((e) => e["email"] == email);
    });
  }

  void _alternarSelecao(String email) {
    setState(() {
      for (var entrevistador in entrevistadores) {
        if (entrevistador["email"] == email) {
          entrevistador["selecionado"] = !entrevistador["selecionado"];
        }
      }
    });
  }
void _FinalizarQuestionario() async {
  final questionarioProvider = Provider.of<QuestionarioList>(context, listen: false);

    await questionarioProvider.adicionarQuestionario(

      senha: dadosQuestionario['senha'].isEmpty ? '' : dadosQuestionario['senha'], 
      entrevistadores: dadosQuestionario['entrevistadores'], 
      prazo: dadosQuestionario['prazo'], 
      publicado: dadosQuestionario['publicado']
    );

  questionarioProvider.limparQuestoesSelecionadas();
  
}


  // Método para exibir o diálogo de confirmação
 void _showPublishDialog() {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) { // Novo contexto específico do diálogo
      return AlertDialog(
        title: Text("Publicar Questionário?"),
        content: Text("Deseja publicar o questionário agora?"),
        actions: [
          TextButton(
            onPressed: () {

           _capturarInformacoes(true);
           _FinalizarQuestionario();

      
            Navigator.pushReplacementNamed(context, Rotas.MEUS_FORMULARIOS);
            },
            child: Text("Sim"),
          ),
          TextButton(
            onPressed: () {
            _capturarInformacoes(false);
             _FinalizarQuestionario();
            Navigator.pushReplacementNamed(context, Rotas.MEUS_FORMULARIOS);
              
             
            },
            child: Text("Não"),
          ),
        ],
      );
    },
  );
}




  // Função para escolher a data e hora do prazo
  Future<void> _selecionarPrazo() async {
    DateTime now = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
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

  // Método para capturar todas as informações
  void _capturarInformacoes(bool publicado) {
    setState(() {
      dadosQuestionario['senha'] = _senhaController.text.isNotEmpty
          ? _senhaController.text
          : ''; // Senha (se fornecida)
      dadosQuestionario['entrevistadores'] = entrevistadores
          .where((e) => e['selecionado'] == true)
          .map((e) => e['email'] as String)
          .toList(); // Lista de entrevistadores selecionados
      dadosQuestionario['prazo'] = _prazoSelecionado; // Prazo selecionado
      dadosQuestionario['publicado']=publicado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:const Color.fromARGB(255, 45, 12, 68),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Configurar Acesso",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de senha
            Text("Senha de acesso (Opcional)", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            TextField(
              controller: _senhaController,
              obscureText: !_senhaVisivel,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: Icon(_senhaVisivel ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _senhaVisivel = !_senhaVisivel;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            // Campo de pesquisa de e-mail
            Text("Adicionar entrevistadores", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Pesquisar e-mail",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Atualiza a tela para recarregar a pesquisa
                    },
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),

            // StreamBuilder para realizar a busca conforme a digitação
            StreamBuilder<List<Usuario>>(
              stream: Provider.of<AuthList>(context)
                  .buscarUsuariosPorEmail(_emailController.text), // Passa o texto da pesquisa
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Nenhum entrevistador encontrado"));
                }
                return Column(
                  children: snapshot.data!.map((usuario) {
                    return ListTile(
                      title: Text(usuario.nome ?? "Nome não disponível"),
                      subtitle: Text(usuario.email ?? "Email não disponível"),
                      trailing: IconButton(
                        icon: Icon(Icons.add, color: Colors.green),
                        onPressed: () => _adicionarEntrevistador(usuario.email ?? ""),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            SizedBox(height: 20),

            // Lista de entrevistadores adicionados
            Text("Entrevistadores adicionados", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: entrevistadores.length,
                itemBuilder: (context, index) {
                  final entrevistador = entrevistadores[index];
                  return Card(
                    child: ListTile(
                      leading: Checkbox(
                        value: entrevistador["selecionado"],
                        onChanged: (value) => _alternarSelecao(entrevistador["email"]),
                      ),
                      title: Text(entrevistador["email"]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removerEntrevistador(entrevistador["email"]),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Campo de seleção de prazo
            Text("Selecionar prazo para o questionário", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _prazoSelecionado != null
                        ? "${_prazoSelecionado!.toLocal()}"
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

            SizedBox(height: 20),

            // Botão Finalizar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 24, 4, 57),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  
                  _showPublishDialog(); // Exibe o diálogo ao pressionar "Finalizar"
                },
                child: Text("Finalizar", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
