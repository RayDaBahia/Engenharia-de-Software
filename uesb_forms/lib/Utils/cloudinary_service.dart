import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CloudinaryUploadResult {
  final String url;
  final String publicId;
  final String format;

  CloudinaryUploadResult({
    required this.url,
    required this.publicId,
    required this.format,
  });
}

class CloudinaryService {
  static const String _cloudName = 'djucywdjh';
  static const String _apiKey = '814757952771398';
  static const String _apiSecret = 'l9-qGmFw0pysCBIZxvrGUmZzCjM';
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const String folder = 'imagens-de-questoes';

  Future<CloudinaryUploadResult?> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    required String questionId,
  }) async {
    try {
      // Validações iniciais
      if (imageBytes.isEmpty)
        throw ArgumentError('imageBytes não pode estar vazio');
      if (imageBytes.length > _maxFileSize)
        throw ArgumentError('Imagem muito grande (máximo 10MB)');
      if (!_isValidExtension(fileName))
        throw ArgumentError('Formato de imagem não suportado');

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final folder = 'questionarios/$questionId';
      final signature = _generateSignature(timestamp, folder);
      final processedFileName = _generateFileName(fileName);

      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['api_key'] = _apiKey
        ..fields['timestamp'] = timestamp
        ..fields['signature'] = signature
        ..fields['folder'] = folder
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: processedFileName,
        ));

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });

      final response = await request.send().timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Tempo excedido no upload'),
          );

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);

        return CloudinaryUploadResult(
          url: jsonResponse['secure_url'],
          publicId: jsonResponse['public_id'],
          format: jsonResponse['format'],
        );
      } else {
        final errorResponse = await response.stream.bytesToString();
        throw HttpException(
          'Erro no upload: ${response.statusCode} - $errorResponse',
        );
      }
    } on TimeoutException catch (e) {
      print('[Cloudinary] Timeout: $e');
      rethrow;
    } on http.ClientException catch (e) {
      print('[Cloudinary] Erro de conexão: $e');
      rethrow;
    } catch (e) {
      print('[Cloudinary] Erro inesperado: $e');
      rethrow;
    }
  }

  String _generateSignature(String timestamp, String folder) {
    final params = 'folder=$folder&timestamp=$timestamp$_apiSecret';
    return sha1.convert(utf8.encode(params)).toString();
  }

  String _generateFileName(String originalName) {
    final ext = originalName.split('.').last.toLowerCase();
    return 'questao_${DateTime.now().millisecondsSinceEpoch}.$ext';
  }

  bool _isValidExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  Future<void> deleteImage(String imageUrlOrPublicId) async {
    try {
      // 1. Determina se é uma URL ou public_id direto
      final publicId = imageUrlOrPublicId.contains('cloudinary.com')
          ? _extractPublicIdFromUrl(imageUrlOrPublicId)
          : imageUrlOrPublicId;

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // 2. Gera a assinatura corretamente
      final signatureData =
          'public_id=$publicId&timestamp=$timestamp$_apiSecret';
      final signature = sha1.convert(utf8.encode(signatureData)).toString();

      // 3. Faz a requisição
      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/destroy'),
        body: {
          'public_id': publicId,
          'timestamp': timestamp,
          'api_key': _apiKey,
          'signature': signature,
        },
      );

      // 4. Verifica a resposta
      if (response.statusCode != 200) {
        final error =
            jsonDecode(response.body)['error']?['message'] ?? response.body;
        throw Exception('Falha ao deletar imagem: $error');
      }
    } catch (e) {
      debugPrint('Erro ao deletar imagem $imageUrlOrPublicId: $e');
      rethrow;
    }
  }

// Método interno para extrair public_id de URLs do Cloudinary
  String _extractPublicIdFromUrl(String imageUrl) {
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;

    // Encontra o índice do segmento 'upload'
    final uploadIndex = pathSegments.indexWhere((seg) => seg == 'upload');

    if (uploadIndex == -1 || uploadIndex >= pathSegments.length - 1) {
      throw ArgumentError(
          'URL do Cloudinary inválida - padrão não reconhecido');
    }

    // Pega todos os segmentos após 'upload' e remove a extensão do arquivo
    final publicIdWithVersion = pathSegments.sublist(uploadIndex + 1).join('/');
    return publicIdWithVersion.split('.').first;
  }
}
