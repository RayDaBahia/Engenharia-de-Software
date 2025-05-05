import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_provider.dart';
import 'package:uesb_forms/Modelo/questao.dart';

class WidgetListaSuspensaForm extends StatefulWidget {
  final Questao questao;
  final String? bancoId;

  const WidgetListaSuspensaForm({
    super.key,
    required this.questao,
    this.bancoId,
  });

  @override
  State<WidgetListaSuspensaForm> createState() =>
      _WidgetListaSuspensaFormState();
}

class _WidgetListaSuspensaFormState extends State<WidgetListaSuspensaForm> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _optionControllers = [];
  Uint8List? selectedImage;
  String? _valorSelecionado; // Novo: Para controlar a seleção atual

  @override
  void initState() {
    super.initState();
    _perguntaController =
        TextEditingController(text: widget.questao.textoQuestao);
    _initializeOptionControllers();

    // Novo: Recupera a resposta salva no Provider, se existir
    final respostaProvider =
        Provider.of<RespostaProvider>(context, listen: false);
    _valorSelecionado = respostaProvider.obterResposta(widget.questao.id ?? '');
  }

  void _initializeOptionControllers() {
    _optionControllers.clear();
    for (var resposta in widget.questao.opcoes!) {
      _optionControllers.add(TextEditingController(text: resposta));
    }
  }

  @override
  void dispose() {
    _perguntaController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleImageSelected(Uint8List? image) {
    setState(() {
      selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: true);

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
              Text(
                widget.questao.textoQuestao!,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                hint: const Text('Selecione uma opção'),
                value: _valorSelecionado, // Alterado: Usa o valor do Provider
                items: widget.questao.opcoes!.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _valorSelecionado = newValue;
                  });

                  // Novo: Salva a resposta no Provider
                  if (newValue != null && widget.questao.id != null) {
                    Provider.of<RespostaProvider>(context, listen: false)
                        .adicionarResposta(widget.questao.id!, newValue);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
