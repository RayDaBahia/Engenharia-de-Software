import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widgetBanco_Questao.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_pesquisa.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Telas/Formulario/EdicaoQuestionario.dart';
import 'package:uesb_forms/Utils/rotas.dart';
import 'package:uesb_forms/Modelo/Banco.dart';

class MeusBancos extends StatefulWidget {
  const MeusBancos({super.key});

  @override
  State<MeusBancos> createState() => _MeusBancosState();
}

class _MeusBancosState extends State<MeusBancos> {
  String _searchQuery = ""; // Adicione esta linha

  @override
  void initState() {
    super.initState();
    // Do not access context-dependent services here
  }

  bool isFormulario = false; // Valor padrão
  bool _bancosCarregados = false; // Controle de carregamento

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final argumentos =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    isFormulario = argumentos?['isFormulario'] ?? false;

    if (!_bancosCarregados) {
      // Impede chamadas múltiplas
      Provider.of<BancoList>(context, listen: false).getBanco();
      _bancosCarregados = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: true);

    // Filtra os bancos pelo nome, igual ao QuestionarioLiderPage
    final bancosFiltrados = bancoList.bancosLista.where((banco) {
      return banco.nome.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      drawer: isFormulario ? null : MenuLateral(),
      appBar: AppBar(
        title: Text(
          isFormulario ? 'Meus Bancos' : 'Selecione o banco',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
        leading: isFormulario
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop(
                    MaterialPageRoute(
                      builder: (context) =>
                          EdicaoQuestionario(), // Substitua por sua tela real
                    ),
                  );
                },
              )
            : null, // Se não for formulário, mantém o padrão
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Campo de busca igual ao QuestionarioLiderPag

                bancoList.bancosLista.isEmpty?
                Text(''):
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
                if (bancosFiltrados.isNotEmpty) ...[
                  Expanded(
                    child: ListView.builder(
                      itemCount: bancosFiltrados.length,
                      itemBuilder: (context, index) {
                        final bancoQuestao = bancosFiltrados[index];
                        return WidgetbancoQuestao(
                            banco: bancoQuestao, isFormulario: isFormulario);
                      },
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Text('Você não possui bancos'),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _botaoAdicionarBanco(context),
          ),
        ],
      ),
    );
  }

  Widget _botaoAdicionarBanco(BuildContext context) {
    return 
    Align(
      alignment: Alignment.bottomLeft,
   child:  Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ElevatedButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(Rotas.CRUD_BANCO),
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
    ));
  }
}
