import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/AplicacaoQuestionario.dart';
import 'package:uesb_forms/Modelo/Banco.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Controle_Modelo/export_excel.dart'; // Import condicional
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:permission_handler/permission_handler.dart';
import 'package:file_saver/file_saver.dart';
import 'package:excel/excel.dart';

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

      final Set<String> idsQuestoes = {};
      for (var aplicacao in _aplicacoes) {
        for (var resposta in aplicacao.respostas) {
          idsQuestoes.add(resposta['idQuestao']);
        }
      }
      final List<String> questoesOrdenadas = idsQuestoes.toList()..sort();

      final questoesSnapshot = await FirebaseFirestore.instance
          .collection('questionarios')
          .doc(questionario.id)
          .collection('questoes')
          .get();

      final Map<String, String> idParaEnunciado = {
        for (var doc in questoesSnapshot.docs)
          doc.id: doc['textoQuestao'] ?? doc.id,
      };

      final cabecalho = [
        'ID Aplicação',
        'ID Entrevistador',
        'ID Entrevistado',
        ...questoesOrdenadas.map((id) => idParaEnunciado[id] ?? id),
      ];
      sheet.appendRow(cabecalho.map((e) => TextCellValue(e)).toList());

      for (var aplicacao in _aplicacoes) {
        final Map<String, dynamic> mapaRespostas = {
          for (var r in aplicacao.respostas) r['idQuestao']: r['resposta'],
        };

        // Use o método buscarNomeUsuario para obter os nomes
        final nomeEntrevistador = await buscarNomeUsuario(
          aplicacao.idEntrevistador,
          'usuarios',
        );
        final nomeEntrevistado = await buscarNomeUsuario(
          aplicacao.idEntrevistado,
          'usuarios',
        );

        final linha = [
          aplicacao.idAplicacao,
          nomeEntrevistador, // agora mostra o nome
          nomeEntrevistado, // agora mostra o nome
          ...questoesOrdenadas.map((id) {
            final resposta = mapaRespostas[id];
            if (resposta == null) return 'Sem dados';

            if (resposta is Timestamp) {
              return resposta.toDate().toIso8601String();
            }

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
        // ANDROID / iOS
        if (io.Platform.isAndroid || io.Platform.isIOS) {
          var status = await Permission.storage.request();

          // Se não foi concedido, tente pedir novamente (apenas Android)
          if (!status.isGranted && io.Platform.isAndroid) {
            status = await Permission.manageExternalStorage.request();
          }

          if (!status.isGranted) {
            // Aqui você pode mostrar um diálogo explicando por que precisa da permissão
            throw Exception("Permissão negada");
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
}