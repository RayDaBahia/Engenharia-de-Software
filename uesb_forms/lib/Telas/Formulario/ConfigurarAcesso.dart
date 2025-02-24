import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ConfigurarAcessoScreen(),
  ));
}

class ConfigurarAcessoScreen extends StatefulWidget {
  @override
  _ConfigurarAcessoScreenState createState() => _ConfigurarAcessoScreenState();
}

class _ConfigurarAcessoScreenState extends State<ConfigurarAcessoScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  List<Map<String, dynamic>> entrevistadores = [];

  void _adicionarEntrevistador(String email) {
    if (email.isNotEmpty && !entrevistadores.any((e) => e["email"] == email)) {
      setState(() {
        entrevistadores.add({
          "email": email,
          "selecionado": false,
          "visivel": true, // Questionário visível por padrão
          "ativo": true, // Entrevistador ativo por padrão
        });
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

  void _alternarVisibilidade(String email) {
    setState(() {
      for (var entrevistador in entrevistadores) {
        if (entrevistador["email"] == email) {
          entrevistador["visivel"] = !entrevistador["visivel"];
        }
      }
    });
  }

  void _alternarAtivo(String email) {
    setState(() {
      for (var entrevistador in entrevistadores) {
        if (entrevistador["email"] == email) {
          entrevistador["ativo"] = !entrevistador["ativo"];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(21, 5, 49, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Configurar Acesso",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    onSubmitted: _adicionarEntrevistador,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 23, 5, 53),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(14),
                  ),
                  onPressed: () => _adicionarEntrevistador(_emailController.text),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("Entrevistadores adicionados", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: entrevistadores.length,
                itemBuilder: (context, index) {
                  final entrevistador = entrevistadores[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        children: [
                          ListTile(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Visível"),
                              Switch(
                                value: entrevistador["visivel"],
                                onChanged: (value) => _alternarVisibilidade(entrevistador["email"]),
                                activeColor: Colors.green,
                              ),
                              Text("Ativo"),
                              Switch(
                                value: entrevistador["ativo"],
                                onChanged: (value) => _alternarAtivo(entrevistador["email"]),
                                activeColor: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 24, 4, 57),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // Ação ao finalizar
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
