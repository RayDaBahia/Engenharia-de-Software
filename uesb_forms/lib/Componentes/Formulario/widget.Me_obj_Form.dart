import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_provider.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';

class WidgetMeObjForm extends StatefulWidget {
  final Questao questao;

  const WidgetMeObjForm({super.key, required this.questao});

  @override
  _WidgetMeObjFormState createState() => _WidgetMeObjFormState();
}

class _WidgetMeObjFormState extends State<WidgetMeObjForm> {
  late List<int> selectedOptions;

  @override
  void initState() {
    super.initState();
    // Busca resposta existente no Provider
    final respostaProvider =
        Provider.of<RespostaProvider>(context, listen: false);
    final respostaSalva =
        respostaProvider.obterResposta(widget.questao.id ?? '');

    // Inicializa com resposta salva ou vazio
    selectedOptions = respostaSalva != null
        ? (respostaSalva is List
            ? List<int>.from(respostaSalva)
            : [respostaSalva as int])
        : [];
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

  void _onOptionChanged(int value, bool selected) {
    final respostaProvider =
        Provider.of<RespostaProvider>(context, listen: false);
    final isMultipleChoice =
        widget.questao.tipoQuestao == QuestaoTipo.MultiPlaEscolha;

    setState(() {
      if (selected) {
        if (isMultipleChoice) {
          selectedOptions.add(value);
        } else {
          selectedOptions = [value];
        }
      } else {
        selectedOptions.remove(value);
      }
    });

    // Salva no Provider
    if (widget.questao.id != null) {
      respostaProvider.adicionarResposta(
        widget.questao.id!,
        isMultipleChoice ? selectedOptions : selectedOptions.firstOrNull,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMultipleChoice =
        widget.questao.tipoQuestao == QuestaoTipo.MultiPlaEscolha;

    return SizedBox(
      width: 300,
      child: Card(
        elevation: 5,
        shadowColor: Colors.black,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exibição da imagem (local ou remota)
              _buildImagePreview(),

              if (widget.questao.textoQuestao != null)
                Text(
                  widget.questao.textoQuestao!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(
                  widget.questao.opcoes?.length ?? 0,
                  (index) => Row(
                    children: [
                      isMultipleChoice
                          ? Checkbox(
                              value: selectedOptions.contains(index),
                              onChanged: (bool? selected) {
                                _onOptionChanged(index, selected ?? false);
                              },
                            )
                          : Radio<int>(
                              value: index,
                              groupValue: selectedOptions.isEmpty
                                  ? -1
                                  : selectedOptions.first,
                              onChanged: (int? value) {
                                if (value != null) {
                                  _onOptionChanged(value, true);
                                }
                              },
                            ),
                      Expanded(
                        child: Text(
                          widget.questao.opcoes![index],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
