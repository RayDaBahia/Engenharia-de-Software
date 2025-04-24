import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetRanking extends StatefulWidget {
  final Questao questao;
  final String? bancoId;

  const WidgetRanking({super.key, required this.questao, this.bancoId});

  @override
  State<WidgetRanking> createState() => _WidgetRankingState();
}

class _WidgetRankingState extends State<WidgetRanking> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _controleAlternativas = [];
  final List<TextEditingController> _controleNiveis = [];
  Uint8List? selectedImage;

  @override
  void initState() {
    super.initState();
    _perguntaController = TextEditingController(text: widget.questao.textoQuestao);
    _initializeOptionControllers();
  }

  void _handleImageSelected(Uint8List? image) {
    setState(() {
      selectedImage = image;
    });
  }

  @override
  void dispose() {
    _perguntaController.dispose();
    for (var controller in _controleAlternativas) {
      controller.dispose();
    }
    for (var controller in _controleNiveis) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeOptionControllers() {
    _controleAlternativas.clear();
    _controleNiveis.clear();

    // Inicializa as alternativas e níveis com base nas propriedades do modelo `Questao`
if (widget.questao.ranking != null && widget.questao.ranking!.isNotEmpty) {
  widget.questao.ranking!.forEach((nivel, alternativa) {
    _controleNiveis.add(TextEditingController(text: nivel));
    _controleAlternativas.add(TextEditingController(text: alternativa));
  });
}



    
  }

  void _atualizarQuestao() {
   
    // Notifica o Provider de que a questão foi alterada
    final bancoList = Provider.of<BancoList>(context, listen: false);

    bool niveisCompativeis= _controleNiveis.any((controller) => controller.text.isEmpty);

    if(niveisCompativeis){
   
      return;
    }
    widget.questao.ranking = _controleNiveis.asMap().map((index, controller) => MapEntry(controller.text, _controleAlternativas[index].text));


    bancoList.adicionarQuestaoNaLista(widget.questao); // Atualiza a lista no Provider
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 5,
        shadowColor: Colors.black,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _perguntaController,
                maxLines: null,
                decoration: const InputDecoration(labelText: 'Digite sua pergunta aqui'),
                onChanged: (value) {
                  setState(() {
                    widget.questao.textoQuestao = value;
                  });
                  _atualizarQuestao();  // Atualiza o banco de dados com a nova pergunta
                },
              ),
              const SizedBox(height: 20),
              Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ...List.generate(
      _controleAlternativas.length,
      (index) => Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _controleAlternativas[index],
              decoration: InputDecoration(
                labelText: 'Opção ${index + 1}',
              ),
              onChanged: (_) => _atualizarQuestao(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _controleNiveis[index],
              decoration: const InputDecoration(
                labelText: 'Classificação',
              ),
              onChanged: (_) => _atualizarQuestao(),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _controleAlternativas.removeAt(index);
                _controleNiveis.removeAt(index);
              });
              _atualizarQuestao();
            },
          ),
        ],
      ),
    ),
    const SizedBox(height: 10),
    ElevatedButton(
      onPressed: () {
        setState(() {
          _controleNiveis.add(TextEditingController(text: ''));
          _controleAlternativas.add(TextEditingController(text: ''));
        });
      
      },
      child: const Text("Adicionar outra opção"),
    ),
  ],
),

            ],
          ),
        ),
      ),
    );
  }
}
