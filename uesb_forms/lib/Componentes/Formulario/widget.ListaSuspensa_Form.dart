import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';


class WidgetListaSuspensaForm extends StatefulWidget {
  final Questao questao;
  final String? bancoId;

  const WidgetListaSuspensaForm ({
    super.key,
    required this.questao,
    this.bancoId,
  });

  @override
  State< WidgetListaSuspensaForm > createState() => _WidgetListaSuspensaFormState();
}

class _WidgetListaSuspensaFormState extends State< WidgetListaSuspensaForm> {
  late TextEditingController _perguntaController;
  final List<TextEditingController> _optionControllers = [];
  Uint8List? selectedImage;

  @override
  void initState() {
    super.initState();
    _perguntaController = TextEditingController(text: widget.questao.textoQuestao);
    _initializeOptionControllers();
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
      selectedImage = image; // Atualiza a imagem selecionada
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
        color: Colors.white, // Cor de fundo do card
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              
              Text(
                  widget.questao.textoQuestao!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
          
              DropdownButton<String>(
                hint: const Text('Selecione uma opção'),
                value: widget.questao.opcoes!.isNotEmpty ? widget.questao.opcoes![0] : null, // Exibe a primeira opção
                items: widget.questao.opcoes!.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                   onChanged: (String? newValue) {
                  setState(() {
                    // Atualizar a questão com a nova opção selecionada
                    if (newValue != null) {
                      // Encontrar o índice da opção selecionada
                      int index = widget.questao.opcoes!.indexOf(newValue);
                      if (index != -1) {
                        widget.questao.opcoes![index] = newValue;
                      }
                    }
                  });
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
