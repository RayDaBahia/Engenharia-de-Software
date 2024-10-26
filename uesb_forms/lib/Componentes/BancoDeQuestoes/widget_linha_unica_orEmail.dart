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

  const WidgetLinhaUnicaOremail(
      {super.key, required this.questao, this.idBanco});

  @override
  State<WidgetLinhaUnicaOremail> createState() =>
      _WidgetLinhaUnicaOremailState();
}

class _WidgetLinhaUnicaOremailState extends State<WidgetLinhaUnicaOremail> {
  late TextEditingController controlePergunta;
  late TextEditingController controleResposta;
  Uint8List?
      selectedImage; // Variável para armazenar a imagem selecionada como bytes

  @override
  void initState() {
    super.initState();
    controlePergunta = TextEditingController(text: widget.questao.textoQuestao);
    controleResposta = TextEditingController(text: '');
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
                    // Abre o widget de opções de imagem quando o botão de imagem
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: WidgetOpcoesImagem(
                            onImageSelected: (image) {
                              _handleImageSelected(
                                  image); // Atualiza a imagem selecionada
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
            // Exibir a imagem selecionada, se houver
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
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controleResposta,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: widget.questao.tipoQuestao == QuestaoTipo.LinhaUnica
                    ? 'Resposta'
                    : 'Digite seu e-mail',
              ),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}
