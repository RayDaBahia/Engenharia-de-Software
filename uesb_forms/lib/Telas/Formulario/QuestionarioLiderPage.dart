import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/Formulario/FormularioCard.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_list.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class QuestionariosLiderPage extends StatefulWidget {
  const QuestionariosLiderPage({super.key});

  @override
  _QuestionariosLiderPageState createState() => _QuestionariosLiderPageState();
}

class _QuestionariosLiderPageState extends State<QuestionariosLiderPage> {
  String _searchQuery = ""; // Variável para armazenar o texto de pesquisa

  @override
  Widget build(BuildContext context) {
    final questionariosLider =
        Provider.of<QuestionarioList>(context, listen: true)
            .questionariosLider
            .where((questionario) =>
                questionario.nome.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList(); // Filtra os questionários pela pesquisa

    return Column(
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

        // Faixa de categoria com diferentes status
        // Faixa de categoria com diferentes status
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  _CategoriaChip('Visível Ativo', Icons.visibility),
                  _CategoriaChip('Visível Inativo', Icons.visibility_outlined),
                  _CategoriaChip('Não Visível', Icons.visibility_off),
                  _CategoriaChip('Encerrado', Icons.check),
                  _CategoriaChip('Não Publicado', Icons.hourglass_empty)

                ],
              ),
            ),
          ),

        // Lista de questionários (envolver com Expanded)
        Expanded(
          child: questionariosLider.isEmpty
              ? const Center(
                  child: Text(
                    'Sem Formulário a Exibir',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: questionariosLider.length,
                    itemBuilder: (ctx, index) {
                      final questionario = questionariosLider[index];

                      return FutureBuilder<int>(
                        future: Provider.of<RespostasList>(context, listen: false)
                            .contarRespostas(questionario.id),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final respostas = snapshot.data ?? 0;

                          return FormularioCard(
                            questionario: questionario,
                            numRespostas: respostas,
                            isLider: true,
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
        Positioned(
          bottom: 40, // Distância do fundo da tela
          right: 20, // Distância da borda direita
          child: _botaoAdicionarFormulario(context),
        ),
      ],
    );
  }
  
  Widget _botaoAdicionarFormulario(BuildContext context) {
    return Padding(
      
      padding: const EdgeInsets.only(bottom: 40.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Rotas.EDICAO_FORMULARIO_TELA);
        },
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
  Widget _CategoriaChip(String categoria, IconData icon) {
    return Chip(
      label: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 45, 12, 68), size: 20),
          const SizedBox(width: 5),
          Text(categoria, style: TextStyle(color: const Color.fromARGB(255, 45, 12, 68))),
        ],
      ),
      backgroundColor: Colors.transparent, // Remover fundo colorido
    );
  }
}
