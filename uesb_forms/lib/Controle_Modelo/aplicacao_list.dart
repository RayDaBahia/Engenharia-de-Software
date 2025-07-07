import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/AplicacaoQuestionario.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Controle_Modelo/export_excel.dart';
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:permission_handler/permission_handler.dart';
import 'package:file_saver/file_saver.dart';
import 'package:excel/excel.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AplicacaoList with ChangeNotifier {
  List<Aplicacaoquestionario> _aplicacoes = [];
  List<Questao> _questoes = [];
  Aplicacaoquestionario aplicacaoAtual = Aplicacaoquestionario(
    idAplicacao: "0",
    idQuestionario: "0",
    respostas: [],
  );

  List<Aplicacaoquestionario> get aplicacoes => _aplicacoes;

  Future<void> persistirNoFirebase() async {
    await FirebaseFirestore.instance
        .collection("aplicacoes")
        .add(aplicacaoAtual.toMapAplicacao());
  }

  void adicionarResposta(
    String idQuestao,
    dynamic resposta,
    String? idEntrevistador,
    String? idEntrevistado,
  ) {
    aplicacaoAtual.idEntrevistado = idEntrevistado;
    aplicacaoAtual.idEntrevistador = idEntrevistador;
    aplicacaoAtual.respostas.add({
      "idQuestao": idQuestao,
      "resposta": resposta,
    });
    notifyListeners();
  }

  Future<List<Aplicacaoquestionario>> buscarAplicacoes(
    String idQuestionario,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("aplicacoes")
        .where("idQuestionario", isEqualTo: idQuestionario)
        .get();

    return snapshot.docs.map((doc) {
      return Aplicacaoquestionario.fromMapAplicacao(doc.data());
    }).toList();
  }

  Future<void> exportarParaExcelWeb(Questionario questionario) async {
    try {
      _aplicacoes = await buscarAplicacoes(questionario.id);

      final excel = Excel.createExcel();
      excel.delete('Sheet1');
      final sheet = excel['Dados'];

      // Coleta todos os IDs de questões únicas
      final Set<String> idsQuestoes = {};
      for (var aplicacao in _aplicacoes) {
        for (var resposta in aplicacao.respostas) {
          idsQuestoes.add(resposta['idQuestao']);
        }
      }
      final List<String> questoesOrdenadas = idsQuestoes.toList()..sort();

      // Busca os enunciados das questões no Firestore
      final questoesSnapshot = await FirebaseFirestore.instance
          .collection('questionarios')
          .doc(questionario.id)
          .collection('questoes')
          .get();

      final Map<String, String> idParaEnunciado = {
        for (var doc in questoesSnapshot.docs)
          doc.id: doc['textoQuestao'] ?? doc.id,
      };

      // Cabeçalho da planilha (mantendo ID Aplicação conforme solicitado)
      final cabecalho = [
        'ID Aplicação',
        'ID Entrevistador',
        'ID Entrevistado',
        ...questoesOrdenadas.map((id) => idParaEnunciado[id] ?? id),
      ];
      sheet.appendRow(cabecalho.map((e) => TextCellValue(e)).toList());

      // Preenchimento das linhas com dados
      for (var aplicacao in _aplicacoes) {
        final Map<String, dynamic> mapaRespostas = {
          for (var r in aplicacao.respostas) r['idQuestao']: r['resposta'],
        };

        // Busca nomes dos usuários (entrevistador e entrevistado)
        final nomeEntrevistador = await buscarNomeUsuario(
          aplicacao.idEntrevistador,
          'usuarios',
        );
        final nomeEntrevistado = await buscarNomeUsuario(
          aplicacao.idEntrevistado,
          'usuarios',
        );

        // Formata os dados para a linha da planilha
        final linha = [
          aplicacao.idAplicacao, // Mantido conforme solicitado
          nomeEntrevistador,
          nomeEntrevistado,
          ...questoesOrdenadas.map((id) {
            final resposta = mapaRespostas[id];
            if (resposta == null) return 'Sem dados';

            // Tratamento especial para campos Timestamp
            if (resposta is Timestamp) {
              return resposta.toDate().toIso8601String();
            }

            // Tratamento para strings que contém Timestamp
            if (resposta is String && resposta.contains('Timestamp')) {
              final regex = RegExp(r'seconds=(\d+),');
              final match = regex.firstMatch(resposta);
              if (match != null) {
                final seconds = int.parse(match.group(1)!);
                return DateTime.fromMillisecondsSinceEpoch(
                  seconds * 1000,
                ).toIso8601String();
              }
            }

            return resposta.toString();
          }),
        ];

        sheet.appendRow(linha.map((e) => TextCellValue(e.toString())).toList());
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) throw Exception("Erro ao gerar Excel");

      final fileName = "aplicacoes_${questionario.nome}.xlsx";

      if (kIsWeb) {
        await exportarParaExcelWebDummy(fileBytes, fileName);
      } else {
        // Tratamento de permissões para Android/iOS
        if (io.Platform.isAndroid || io.Platform.isIOS) {
          // Verifica e solicita permissões de armazenamento
          bool permissaoConcedida = await _verificarPermissoesArmazenamento();
          if (!permissaoConcedida) {
            throw Exception("Permissão de armazenamento negada");
          }

          final Uint8List bytes = Uint8List.fromList(fileBytes);
          await FileSaver.instance.saveFile(
            name: fileName,
            bytes: bytes,
            ext: "xlsx",
          );
        }
      }
    } catch (e) {
      print("Erro na exportação: $e");
      rethrow;
    }
  }

  Future<String> buscarNomeUsuario(String? id, String colecao) async {
    if (id == null || id.isEmpty) return '';
    final doc = await FirebaseFirestore.instance
        .collection(colecao)
        .doc(id)
        .get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['nome'] ?? id;
    }
    return id;
  }

  // Método auxiliar para verificar e solicitar permissões de armazenamento
  Future<bool> _verificarPermissoesArmazenamento() async {
    if (!io.Platform.isAndroid) return true;

    // Verifica a versão do Android
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final isAndroid11OrHigher = androidInfo.version.sdkInt >= 30;

    // Tenta primeiro com a permissão padrão de armazenamento
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    // Para Android 11+ tenta a permissão especial se necessário
    if (isAndroid11OrHigher && !status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    return status.isGranted;
  }
}
