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
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      Navigator.of(context).pop();
      await Future.delayed(Duration.zero); // Garante que o modal feche antes

      setState(() => _isProcessing = true);
      final pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        final originalBytes = await pickedFile.readAsBytes();
        final originalImage = img.decodeImage(originalBytes);

        if (originalImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formato de imagem não suportado')),
          );
          return;
        }

        // Redimensionamento proporcional correto
        const maxWidth = 1024;
        int newWidth = originalImage.width;
        int newHeight = originalImage.height;

        if (originalImage.width > maxWidth) {
          double scaleFactor = maxWidth / originalImage.width;
          newWidth = maxWidth;
          newHeight = (originalImage.height * scaleFactor).toInt();
        }

        final resizedImage = img.copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
        );

        final pngBytes = img.encodePng(resizedImage);
        widget.onImageSelected(Uint8List.fromList(pngBytes));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao processar imagem: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isProcessing) const LinearProgressIndicator(),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Usar câmera'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Escolher foto da galeria'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Remover Foto'),
                onTap: () {
                  widget.onImageSelected(null);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBottomSheet(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
