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
    if (widget.questao.opcoes != null) {
      for (var alternativa in widget.questao.opcoes!) {
        _controleAlternativas.add(TextEditingController(text: alternativa));
      }
    }

    
  }

  void _atualizarQuestao() {
    // Atualiza as opções de ranking no modelo
    widget.questao.opcoes= _controleAlternativas.map((controller) => controller.text).toList();
    
    // Notifica o Provider de que a questão foi alterada
    final bancoList = Provider.of<BancoList>(context, listen: false);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Coluna de alternativas
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(
                          _controleAlternativas.length,
                          (index) => Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controleAlternativas[index],
                                  decoration: InputDecoration(
                                    labelText: 'Opção ${index + 1}',
                                  ),
                                  onChanged: (value) {
                                    _atualizarQuestao(); // Atualiza o ranking no banco
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _controleAlternativas.add(TextEditingController(text: ''));
                              widget.questao.opcoes?.add('');
                            });
                            _atualizarQuestao();  // Atualiza o banco com a nova opção
                          },
                          child: const Text("Adicionar outra opção"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20), // Espaço entre colunas

                  // Coluna de níveis
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(
                          _controleNiveis.length,
                          (index) => Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controleNiveis[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Classificação',
                                  ),
                                  onChanged: (value) {
                                    _atualizarQuestao(); // Atualiza a classificação no banco
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                       
                      ],
                    ),
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
