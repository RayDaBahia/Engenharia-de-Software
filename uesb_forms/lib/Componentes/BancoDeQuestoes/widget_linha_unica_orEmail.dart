import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Componentes/widget_opcoes_imagem.dart';

class WidgetLinhaUnicaOremail extends StatefulWidget {
  final String? idBanco;
  final Questao questao;

  const WidgetLinhaUnicaOremail({
    Key? key,
    required this.questao,
    this.idBanco,
  }) : super(key: key);

  @override
  State<WidgetLinhaUnicaOremail> createState() =>
      _WidgetLinhaUnicaOremailState();
}

class _WidgetLinhaUnicaOremailState extends State<WidgetLinhaUnicaOremail> {
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
      widget.questao.imagem = image; // Atualiza a imagem na questão
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
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: WidgetOpcoesImagem(
                            onImageSelected:
                                _handleImageSelected, // Passa o callback
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.image),
                ),
              ],
            ),
            if (widget.questao.imagem != null) // Exibe a imagem se existir
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Image.memory(
                  widget.questao.imagem!,
                  width: double.infinity,
                  fit: BoxFit.contain, // Mantém a proporção da imagem
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
