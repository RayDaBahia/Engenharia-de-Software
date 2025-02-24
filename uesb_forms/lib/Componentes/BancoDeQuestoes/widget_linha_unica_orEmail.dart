import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Componentes/WidgetOpcoesImagem.dart';

class WidgetLinhaUnicaOremail extends StatefulWidget {
  final String? idBanco;
  final Questao questao;
  final bool isFormulario; // 🔥 Define se está preenchendo o formulário

  const WidgetLinhaUnicaOremail({
    super.key,
    required this.questao,
    this.idBanco,
    this.isFormulario = true, // Padrão: não está preenchendo o formulário
  });

  @override
  State<WidgetLinhaUnicaOremail> createState() =>
      _WidgetLinhaUnicaOremailState();
}

class _WidgetLinhaUnicaOremailState extends State<WidgetLinhaUnicaOremail> {
  late TextEditingController controlePergunta;
  late TextEditingController controleResposta;
  Uint8List? selectedImage; // Variável para armazenar a imagem selecionada

  @override
  void initState() {
    super.initState();
    controlePergunta = TextEditingController(text: widget.questao.textoQuestao);
    controleResposta = TextEditingController(text: widget.questao.resposta ?? '');
  }

  void _handleImageSelected(Uint8List? image) {
    setState(() {
      selectedImage = image; // Atualiza a imagem selecionada
    });
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: false);

    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      color: Colors.white, // Cor de fundo do card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    bancoList.removerQuestao(widget.idBanco, widget.questao);
                  },
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.copy_sharp),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: WidgetOpcoesImagem(
                            onImageSelected: (image) {
                              _handleImageSelected(image);
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.image),
                ),
              ],
            ),
            if (selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Image.memory(
                  selectedImage!,
                  height: 500,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            // Verifica o tipo da questão

                  if (widget.questao.tipoQuestao == QuestaoTipo.LinhaUnica) 
                    TextField(
                      controller: controlePergunta,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        labelText: 'Digite sua pergunta',
                      ),
                      onChanged: (value) {
                        widget.questao.textoQuestao = value;
                        bancoList.adicionarQuestaoNaLista(widget.questao);
                      },
                    ),

                 const SizedBox(height: 10), // Caso contrário, não exibe nada
            TextField(
              controller: controleResposta,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                labelText: widget.questao.tipoQuestao == QuestaoTipo.LinhaUnica
                    ? 'Resposta'
                    : 'Digite seu e-mail',
              ),
              maxLines: 1,
              maxLength: (MediaQuery.of(context).size.width / 11).floor(),
              enabled: widget.isFormulario, // 🔥 Só ativa se estiver preenchendo o formulário
              onChanged: widget.isFormulario
                  ? (value) {
                      widget.questao.resposta = value;
                    }
                  : null, // 🔥 Só salva se estiver preenchendo o formulário
            ),
          ],
        ),
      ),
    );
  }
}
