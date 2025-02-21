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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        // Carregar a imagem como bytes
        final imageBytes = await pickedFile.readAsBytes();

        // Decodificar a imagem
        final img.Image? originalImage = img.decodeImage(imageBytes);

        if (originalImage != null) {
          // Redimensionar a imagem apenas se for muito grande
          final img.Image resizedImage = img.copyResize(
            originalImage,
            width: 1024, // Largura máxima de 1024 pixels
            maintainAspect: true, // Mantém a proporção da imagem
          );

          // Codificar de volta para PNG com qualidade máxima
          final resizedBytes = img.encodePng(resizedImage);

          // Passa a imagem para o callback
          widget.onImageSelected(Uint8List.fromList(resizedBytes));
        } else {
          // Se a imagem não puder ser decodificada, exiba uma mensagem de erro
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formato de imagem não suportado.')),
          );
        }
      }
    } catch (e) {
      // Exibe uma mensagem de erro genérica
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao processar a imagem: $e')),
      );
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
    return const SizedBox.shrink(); // Retorna um SizedBox vazio
  }
}
