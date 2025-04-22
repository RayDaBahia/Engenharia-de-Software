import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class _WidgetOpcoesImagemState extends State<WidgetOpcoesImagem> {
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _imageData;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      // Carregar a imagem
      final imageBytes = await pickedFile.readAsBytes();
      // Decodificar a imagem
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (pickedFile != null) {
        // Carregar a imagem como bytes
        final imageBytes = await pickedFile.readAsBytes();

      // Redimensionar a imagem para uma largura máxima de 100, mantendo a proporção
      if (originalImage != null) {
        img.Image resizedImage = img.copyResize(originalImage, width: 100);
        // Codificar de volta em bytes
        final resizedBytes = img.encodePng(resizedImage);
        widget.onImageSelected(Uint8List.fromList(
            resizedBytes)); // Chama o callback passando a imagem redimensionada
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



@@ -66,9 +84,6 @@ class _WidgetOpcoesImagemState extends State<WidgetOpcoesImagem> {
                leading: const Icon(Icons.close),
                title: const Text('Remover Foto'),
                onTap: () {
                  setState(() {
                    _imageData = null; // Remove a imagem
                  });
                  widget
                      .onImageSelected(null); // Chama o callback passando null
                  Navigator.pop(context);

@@ -92,7 +107,6 @@ class _WidgetOpcoesImagemState extends State<WidgetOpcoesImagem> {

  @override
  Widget build(BuildContext context) {
    return const SizedBox
        .shrink(); // Retorna um SizedBox vazio, ocultando qualquer UI
    return const SizedBox.shrink(); // Retorna um SizedBox vazio
  }
}