import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Componentes/widget_opcoes_imagem.dart';

class WidgetMultiplaslinhas extends StatefulWidget {
  final String? idBanco;
  final Questao questao;
  final bool
      isFormulario; // Novo parâmetro para diferenciar modo edição/formulário

  const WidgetMultiplaslinhas({
    super.key,
    required this.questao,
    this.idBanco,
    this.isFormulario = false, // Padrão: modo edição
  });

  @override
  _WidgetMultiplaslinhasState createState() => _WidgetMultiplaslinhasState();
}

class _WidgetMultiplaslinhasState extends State<WidgetMultiplaslinhas> {
  late TextEditingController controlePergunta;
  late TextEditingController controleResposta;

  @override
  void initState() {
    super.initState();
    controlePergunta = TextEditingController(text: widget.questao.textoQuestao);
    controleResposta = TextEditingController(text: '');
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
  }

  Widget _buildImagePreview() {
    // Prioridade para imagem local (se estiver sendo editada)
    if (widget.questao.imagemLocal != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Image.memory(
          widget.questao.imagemLocal!,
          height: 500,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    // Se tem URL remota
    else if (widget.questao.imagemUrl != null) {
      return Padding(
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
      );
    }
    return const SizedBox.shrink(); // Nenhuma imagem
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: false);

    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Botões de ação (só aparecem no modo edição)
            if (!widget.isFormulario)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                  onPressed:() async {
                      await Provider.of<BancoList>(context, listen: false)
                            .removerQuestao(widget.idBanco, widget.questao);
                  
          if (mounted) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Questão excluída com sucesso!')),
    );
  });
};},
                    icon: const Icon(Icons.delete),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: WidgetOpcoesImagem(
                              onImageSelected: _handleImageSelected,
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.image),
                  ),
                ],
              ),

            // Exibição da imagem (local ou remota)
            _buildImagePreview(),

            // Campo de pergunta
            TextField(
              controller: controlePergunta,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: 'Digite a pergunta',
              ),
              onChanged: (value) {
                widget.questao.textoQuestao = value;
                bancoList.adicionarQuestaoNaLista(widget.questao);
              },
              readOnly: widget.isFormulario, // Só edita no modo edição
              maxLines: null, // Permite múltiplas linhas
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 10),

            // Campo de resposta
            TextField(
              controller: controleResposta,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: 'Resposta',
              ),
              enabled: widget.isFormulario, // Só habilitado no modo formulário
              maxLines: null, // Permite múltiplas linhas
              keyboardType: TextInputType.multiline,
            ),
          ],
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
  @override
  void dispose() {
    controlePergunta.dispose();
    controleResposta.dispose();
    super.dispose();
  }
}
