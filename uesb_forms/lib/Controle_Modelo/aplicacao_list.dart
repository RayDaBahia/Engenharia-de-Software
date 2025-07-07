import 'dart:typed_data';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_saver/file_saver.dart';
import 'package:excel/excel.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uesb_forms/Modelo/AplicacaoQuestionario.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Controle_Modelo/export_excel.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AplicacaoList with ChangeNotifier {
  List<Aplicacaoquestionario> _aplicacoes = [];
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

      // ========== [1] BUSCA DADOS DO QUESTIONÁRIO ==========
      final questoesSnapshot = await FirebaseFirestore.instance
          .collection('questionarios')
          .doc(questionario.id)
          .collection('questoes')
          .get();

      final Map<String, String> idParaEnunciado = {};
      final Map<String, String> idParaTipo = {};
      final Map<String, List<String>> idParaAlternativas = {};

      for (var doc in questoesSnapshot.docs) {
        idParaEnunciado[doc.id] = doc['textoQuestao'] ?? doc.id;
        idParaTipo[doc.id] = doc['tipo'] ?? 'texto';

        if (doc['tipo'] == 'multiplaEscolha' && doc['alternativas'] != null) {
          idParaAlternativas[doc.id] = List<String>.from(doc['alternativas']);
        }
      }

      // ========== [2] PREPARA PLANILHA ==========
      final excel = Excel.createExcel();
      excel.delete('Sheet1');
      final sheet = excel['Dados'];

      // Coleta IDs de questões
      final Set<String> idsQuestoes = {};
      for (var aplicacao in _aplicacoes) {
        for (var resposta in aplicacao.respostas) {
          idsQuestoes.add(resposta['idQuestao']);
        }
      }
      final List<String> questoesOrdenadas = idsQuestoes.toList()..sort();

      // Cabeçalho MODIFICADO (removidas as colunas solicitadas)
      final cabecalho = [
        'Entrevistador', // Mantido apenas entrevistador
        ...questoesOrdenadas.map((id) => idParaEnunciado[id] ?? id), // Questões
      ];
      sheet.appendRow(cabecalho.map((e) => TextCellValue(e)).toList());

      // ========== [3] PREENCHE DADOS ==========
      for (var aplicacao in _aplicacoes) {
        final Map<String, dynamic> mapaRespostas = {
          for (var r in aplicacao.respostas) r['idQuestao']: r['resposta'],
        };

        final nomeEntrevistador = await buscarNomeUsuario(
          aplicacao.idEntrevistador,
          'usuarios',
        );

        // Linha MODIFICADA (removidos os campos solicitados)
        final linha = [
          nomeEntrevistador, // Mantido apenas entrevistador
          ...questoesOrdenadas.map((id) {
            final resposta = mapaRespostas[id];
            if (resposta == null) return 'Sem resposta';

            // Trata múltipla escolha
            if (idParaTipo[id] == 'multiplaEscolha' &&
                idParaAlternativas.containsKey(id)) {
              try {
                final index = int.tryParse(resposta.toString());
                if (index != null &&
                    index >= 0 &&
                    index < idParaAlternativas[id]!.length) {
                  return idParaAlternativas[id]![index];
                }
              } catch (e) {
                print('Erro ao processar resposta: $e');
              }
            }

            // Trata datas
            if (resposta is Timestamp) {
              return resposta.toDate().toIso8601String();
            }

            return resposta.toString();
          }),
        ];

        sheet.appendRow(linha.map((e) => TextCellValue(e.toString())).toList());
      }

      // ========== [4] SALVA ARQUIVO ==========
      final fileBytes = excel.encode();
      if (fileBytes == null) throw Exception("Erro ao gerar Excel");

      final fileName = "aplicacoes_${questionario.nome}.xlsx";

      if (kIsWeb) {
        await exportarParaExcelWebDummy(fileBytes, fileName);
      } else if (io.Platform.isAndroid || io.Platform.isIOS) {
        // ========== [5] VERIFICA PERMISSÕES ==========
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
    } catch (e) {
      print("Erro na exportação: $e");
      rethrow;
    }
  }

  // ========== [MÉTODOS AUXILIARES] ==========
  Future<String> buscarNomeUsuario(String? id, String colecao) async {
    if (id == null || id.isEmpty) return '';
    final doc = await FirebaseFirestore.instance
        .collection(colecao)
        .doc(id)
        .get();
    return doc.exists ? (doc.data()?['nome'] ?? id) : id;
  }

  Future<bool> _verificarPermissoesArmazenamento() async {
    if (!io.Platform.isAndroid) return true;

    // 1. Verifica versão do Android
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final isAndroid11OrHigher = androidInfo.version.sdkInt >= 30;

    // 2. Tenta com WRITE_EXTERNAL_STORAGE primeiro
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();

      // Se negado, mostra diálogo explicativo
      if (!status.isGranted) {
        bool? deveContinuar = await showDialog<bool>(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: Text("Permissão necessária"),
            content: Text(
              "Para salvar o arquivo, precisamos acessar o armazenamento. "
              "Isso não afeta seus arquivos pessoais.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Permitir"),
              ),
            ],
          ),
        );
        if (deveContinuar != true) return false;
        status = await Permission.storage.request();
      }
    }

    // 3. Para Android 11+, tenta MANAGE_EXTERNAL_STORAGE
    if (isAndroid11OrHigher && !status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    // 4. Se ainda negado, abre configurações
    if (!status.isGranted) {
      await openAppSettings();
      return false;
    }

    return true;
  }
}
