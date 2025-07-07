import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_provider.dart';

class WidgetCapturaForm extends StatefulWidget {
  final Questao questao;

  const WidgetCapturaForm({Key? key, required this.questao}) : super(key: key);

  @override
  State<WidgetCapturaForm> createState() => _WidgetCapturaFormState();
}

class _WidgetCapturaFormState extends State<WidgetCapturaForm> {
  Uint8List? _imagemLocal;

  @override
  void initState() {
    super.initState();
    final respostaProvider = Provider.of<RespostaProvider>(
      context,
      listen: false,
    );
    final resposta = respostaProvider.obterResposta(widget.questao.id ?? '');
    if (resposta is Uint8List) {
      _imagemLocal = resposta;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imagemLocal = bytes);
      Provider.of<RespostaProvider>(
        context,
        listen: false,
      ).adicionarResposta(widget.questao.id!, bytes);
    }
    Navigator.of(context).pop();
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            if (_imagemLocal != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover imagem'),
                onTap: () {
                  setState(() => _imagemLocal = null);
                  Provider.of<RespostaProvider>(
                    context,
                    listen: false,
                  ).adicionarResposta(widget.questao.id!, null);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imagemLocal != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Image.memory(
          _imagemLocal!,
          width: double.infinity,
          height: 220,
          fit: BoxFit.contain,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem do enunciado (se houver)
            if (widget.questao.imagemUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Image.network(
                  widget.questao.imagemUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 50);
                  },
                ),
              ),
            // Enunciado
            Text(
              widget.questao.textoQuestao,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Preview da imagem de resposta
            _buildImagePreview(),
            // Botão grande centralizado
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo, size: 32),
                label: const Text(
                  'Adicionar/Alterar Imagem',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 24,
                  ),
                  backgroundColor: const Color.fromARGB(255, 45, 12, 68),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showImageOptions,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tire uma foto ou selecione da galeria para responder.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
