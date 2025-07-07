import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_provider.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetRankingForm extends StatefulWidget {
  final Questao questao;

  const WidgetRankingForm({super.key, required this.questao});

  @override
  State<WidgetRankingForm> createState() => _WidgetRankingFormState();
}

class _WidgetRankingFormState extends State<WidgetRankingForm> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _controleAlternativas = [];
  final List<String> _classificacoesSelecionadas = [];
  late List<String> _opcoesDeClassificacao;

  @override
  void initState() {
    super.initState();
    widget.questao.ranking ??= {};
    _opcoesDeClassificacao = widget.questao.ranking!.keys.toList();
    _perguntaController =
        TextEditingController(text: widget.questao.textoQuestao);
    _initializeOptionControllers();
    _carregarRespostaSalva();
  }

  void _carregarRespostaSalva() {
    final respostaProvider =
        Provider.of<RespostaProvider>(context, listen: false);
    final resposta = respostaProvider.obterResposta(widget.questao.id ?? '');
    if (resposta != null && resposta is Map<String, String>) {
      resposta.forEach((nivel, alternativa) {
        final index = _classificacoesSelecionadas.indexOf(nivel);
        if (index != -1) {
          _controleAlternativas[index].text = alternativa;
        }
      });
    }
  }

  void _initializeOptionControllers() {
    _controleAlternativas.clear();
    _classificacoesSelecionadas.clear();
    widget.questao.ranking!.forEach((nivel, alternativa) {
      _controleAlternativas.add(TextEditingController(text: alternativa));
      _classificacoesSelecionadas.add(nivel);
    });
  }

  void _atualizarQuestao() {
    final bancoList = Provider.of<BancoList>(context, listen: false);
    widget.questao.textoQuestao = _perguntaController.text;
    widget.questao.ranking = Map.fromIterables(
      _classificacoesSelecionadas,
      _controleAlternativas.map((c) => c.text),
    );
    bancoList.adicionarQuestaoNaLista(widget.questao);

    // Atualiza o Provider com as respostas
    if (widget.questao.id != null) {
      final respostaProvider =
          Provider.of<RespostaProvider>(context, listen: false);
      final respostas = Map.fromIterables(
        _classificacoesSelecionadas,
        _controleAlternativas.map((c) => c.text),
      );
      respostaProvider.adicionarResposta(widget.questao.id!, respostas);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        color: Colors.white,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Adicionado: Exibe imagem se houver URL
              if (widget.questao.imagemUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.network(
                    widget.questao.imagemUrl!,
                    height: 500,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 50);
                    },
                  ),
                ),

              Text(
                _perguntaController.text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(_controleAlternativas.length, (i) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _controleAlternativas[i],
                          decoration:
                              InputDecoration(labelText: 'Opção ${i + 1}'),
                          onChanged: (_) => _atualizarQuestao(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _classificacoesSelecionadas[i],
                          decoration:
                              const InputDecoration(labelText: 'Classificação'),
                          items: _opcoesDeClassificacao
                              .map((nivel) => DropdownMenuItem(
                                    value: nivel,
                                    child: Text(nivel),
                                  ))
                              .toList(),
                          onChanged: (novoNivel) {
                            setState(() {
                              int velho =
                                  _classificacoesSelecionadas.indexWhere(
                                      (nivelNovo) => nivelNovo == novoNivel);
                              if (velho != -1) {
                                _classificacoesSelecionadas[velho] =
                                    _classificacoesSelecionadas[i];
                              }
                              _classificacoesSelecionadas[i] = novoNivel!;
                            });
                            _atualizarQuestao();
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
