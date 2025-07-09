import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Componentes/widget_opcoes_imagem.dart';

class WidgetRanking extends StatefulWidget {
  final Questao questao;
  final String? bancoId;
  final bool isFormulario; // Novo parâmetro para modo formulário

  const WidgetRanking({
    super.key,
    required this.questao,
    this.bancoId,
    this.isFormulario = false, // Padrão: modo edição
  });

  @override
  State<WidgetRanking> createState() => _WidgetRankingState();
}

class _WidgetRankingState extends State<WidgetRanking> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _controleAlternativas = [];
  final List<TextEditingController> _controleNiveis = [];

  @override
  void initState() {
    super.initState();
    _perguntaController =
        TextEditingController(text: widget.questao.textoQuestao);
    _initializeOptionControllers();
  }

  void _handleImageSelected(Uint8List? image) {
    setState(() {
      // Armazena a imagem localmente na questão
      widget.questao.imagemLocal = image;
      // Se estava usando uma imagem remota e substituiu por nenhuma, marca para remoção
      if (image == null && widget.questao.imagemUrl != null) {
        widget.questao.imagemUrl = null;
      }
    });
    _atualizarQuestao();
  }

  Widget _buildImagePreview() {
    // Prioridade para imagem local (se estiver sendo editada)
    if (widget.questao.imagemLocal != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Image.memory(
          widget.questao.imagemLocal!,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    // Se tem URL remota
    else if (widget.questao.imagemUrl != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Image.network(
          widget.questao.imagemUrl!,
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
      );
    }
    return const SizedBox.shrink(); // Nenhuma imagem
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
              // Botões de ação (só no modo edição)
              if (!widget.isFormulario)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed:() async {
                      await Provider.of<BancoList>(context, listen: false)
                            .removerQuestao(widget.bancoId, widget.questao);
           if (mounted) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Questão excluída com sucesso!')),
    );
  });
}},
                      icon: const Icon(Icons.delete),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: WidgetOpcoesImagem(
                              onImageSelected: _handleImageSelected,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.image),
                    ),
                  ],
                ),

              // Exibição da imagem
              _buildImagePreview(),

              // Campo de pergunta
              TextField(
                controller: _perguntaController,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Digite sua pergunta aqui',
                ),
                onChanged: (value) {
                  widget.questao.textoQuestao = value;
                  _atualizarQuestao();
                },
                readOnly: widget.isFormulario, // Só edita no modo edição
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
    void showSuccessMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating, // Faz ele "flutuar" acima da UI
      margin: const EdgeInsets.all(16), // Margem nas bordas
      duration: const Duration(seconds: 3), // Tempo que ele fica visível
    ),
  );
}
}
