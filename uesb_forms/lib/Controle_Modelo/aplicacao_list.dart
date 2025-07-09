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

    // Busca todas as questões do questionário
    final questoesSnapshot = await FirebaseFirestore.instance
        .collection('questionarios')
        .doc(questionario.id)
        .collection('questoes')
        .get();

    // Mapeia id da questão para enunciado
    final Map<String, String> idParaEnunciado = {
      for (var doc in questoesSnapshot.docs)
        doc.id: doc.data()['textoQuestao'] ?? doc.id,
    };

    // Mapeia alternativas a partir da subcoleção 'opcoes' de cada questão
    final Map<String, Map<String, String>> alternativasPorQuestao = {};

    for (var doc in questoesSnapshot.docs) {
      final opcoes = doc.data()['opcoes'];
      if (opcoes is List) {
        alternativasPorQuestao[doc.id] = {
          for (var i = 0; i < opcoes.length; i++) opcoes[i].toString(): opcoes[i].toString(),
          for (var i = 0; i < opcoes.length; i++) i.toString(): opcoes[i].toString(),
        };
      } else {
        alternativasPorQuestao[doc.id] = {};
      }
    }

    // Função local para formatar resposta com segurança
    String formatarResposta(dynamic resposta, Map<String, String>? alternativas) {
      if (resposta == null) return 'Sem resposta';

      if (resposta is Timestamp) {
        return resposta.toDate().toIso8601String();
      }

      if (resposta is String && resposta.contains('Timestamp')) {
        final regex = RegExp(r'seconds=(\d+),');
        final match = regex.firstMatch(resposta);
        if (match != null && match.group(1) != null) {
          final seconds = int.tryParse(match.group(1)!);
          if (seconds != null) {
            return DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toIso8601String();
          }
        }
        return resposta;
      }

      if (resposta is List && alternativas != null) {
        return resposta
            .map((r) => alternativas[r.toString()] ?? r.toString())
            .join(', ');
      }

      if (alternativas != null) {
        if (resposta is String && alternativas.containsKey(resposta)) {
          return alternativas[resposta]!;
        }
        if (resposta is int && alternativas.containsKey(resposta.toString())) {
          return alternativas[resposta.toString()]!;
        }
      }

      return resposta.toString();
    }

    // Criação do Excel
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['Dados'];

    // Descobrir todas as questões que possuem respostas
    final Set<String> idsQuestoes = {};
    for (var aplicacao in _aplicacoes) {
      for (var resposta in aplicacao.respostas) {
        idsQuestoes.add(resposta['idQuestao']);
      }
    }

    final List<String> questoesOrdenadas = idsQuestoes.toList()..sort();

    // Cabeçalho
    final cabecalho = [
      'Entrevistador',
      ...questoesOrdenadas.map((id) => idParaEnunciado[id] ?? id),
    ];
    sheet.appendRow(cabecalho.map((e) => TextCellValue(e)).toList());

    // Linhas de dados
    for (var aplicacao in _aplicacoes) {
      try {
        final Map<String, dynamic> mapaRespostas = {
          for (var r in aplicacao.respostas) r['idQuestao']: r['resposta'],
        };

        final nomeEntrevistador = await buscarNomeUsuario(
          aplicacao.idEntrevistador,
          'usuarios',
        );

        final linha = <String>[];
        linha.add(nomeEntrevistador);

        for (var id in questoesOrdenadas) {
          final resposta = mapaRespostas[id];
          final alternativasDaQuestao = alternativasPorQuestao[id];
          linha.add(formatarResposta(resposta, alternativasDaQuestao));
        }

        sheet.appendRow(linha.map((e) => TextCellValue(e)).toList());
      } catch (e, st) {
        print('Erro ao formatar linha da aplicação ${aplicacao.idAplicacao}: $e');
        print(st);
        // Continua exportando as outras linhas, adiciona uma linha com erro
        sheet.appendRow([
          TextCellValue('Erro na aplicação ${aplicacao.idAplicacao}'),
        ]);
      }
    }

    // Finalização e salvamento
    final fileBytes = excel.encode();
    if (fileBytes == null) throw Exception("Erro ao gerar Excel");

    final fileName = "aplicacoes_${questionario.nome}.xlsx";

    if (kIsWeb) {
      await exportarParaExcelWebDummy(fileBytes, fileName);
    } else if (io.Platform.isAndroid || io.Platform.isIOS) {
      final permissao = await _verificarPermissoesArmazenamento();
      if (!permissao) throw Exception("Permissão negada");

      final bytes = Uint8List.fromList(fileBytes);
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: "xlsx",
      );
    }
  } catch (e, st) {
    print("Erro na exportação: $e");
    print(st);
    rethrow;
  }
}


  // Método original de buscarNomeUsuario (mantido exatamente como está)
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

  // Sistema de permissões completo (como já havíamos desenvolvido)
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
