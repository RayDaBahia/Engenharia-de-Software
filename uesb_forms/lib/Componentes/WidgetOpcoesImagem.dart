import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class WidgetOpcoesImagem extends StatefulWidget {
  final Function(Uint8List?) onImageSelected;

  const WidgetOpcoesImagem({Key? key, required this.onImageSelected})
      : super(key: key);

  @override
  _WidgetOpcoesImagemState createState() => _WidgetOpcoesImagemState();
}

class _WidgetOpcoesImagemState extends State<WidgetOpcoesImagem> {
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _imageData;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      // Carregar a imagem
      final imageBytes = await pickedFile.readAsBytes();
      // Decodificar a imagem
      img.Image? originalImage = img.decodeImage(imageBytes);

      // Redimensionar a imagem para uma largura máxima de 100, mantendo a proporção
      if (originalImage != null) {
        img.Image resizedImage = img.copyResize(originalImage, width: 100);
        // Codificar de volta em bytes
        final resizedBytes = img.encodePng(resizedImage);
        widget.onImageSelected(Uint8List.fromList(
            resizedBytes)); // Chama o callback passando a imagem redimensionada
      }
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Usar câmera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Escolher foto da galeria'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Remover Foto'),
                onTap: () {
                  setState(() {
                    _imageData = null; // Remove a imagem
                  });
                  widget
                      .onImageSelected(null); // Chama o callback passando null
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Mostra a BottomSheet imediatamente após o widget ser construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBottomSheet(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox
        .shrink(); // Retorna um SizedBox vazio, ocultando qualquer UI
  }
}
