import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/aplicacao_list.dart';
import 'package:uesb_forms/Modelo/AplicacaoQuestionario.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';

// Função auxiliar para buscar nome do usuário
Future<String> buscarNomeUsuario(String? id) async {
  if (id == null || id.isEmpty) return '';
  final doc = await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(id)
      .get();
  if (doc.exists && doc.data() != null) {
    return doc.data()!['nome'] ?? id;
  }
  return id;
}

// Função auxiliar para buscar enunciados das questões
Future<Map<String, String>> buscarEnunciadosQuestoes(
  String questionarioId,
) async {
  final questoesSnapshot = await FirebaseFirestore.instance
      .collection('questionarios')
      .doc(questionarioId)
      .collection('questoes')
      .get();

  return {
    for (var doc in questoesSnapshot.docs)
      doc.id: doc['textoQuestao'] ?? doc.id,
  };
}

class Dados extends StatelessWidget {
  final Questionario questionario;

  const Dados({super.key, required this.questionario});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Provider_aplicacao = Provider.of<AplicacaoList>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            ),
            onPressed: () async {
              try {
                await Provider_aplicacao.exportarParaExcelWeb(questionario);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Exportado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao exportar: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              "Exportar para excel",
              style: TextStyle(
                color: const Color.fromARGB(255, 1, 21, 37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        title: const Text(
          'Visualizar Questionário',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
      ),
      body: FutureBuilder<List<Aplicacaoquestionario>>(
        future: Provider_aplicacao.buscarAplicacoes(questionario.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando dados...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: colorScheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Falha ao carregar dados',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final aplicacoes = snapshot.data ?? [];
          final Set<String> idsQuestoes = {};
          final Set<String> idsUsuarios = {};

          for (var aplicacao in aplicacoes) {
            if (aplicacao.idEntrevistador != null)
              idsUsuarios.add(aplicacao.idEntrevistador!);
            if (aplicacao.idEntrevistado != null)
              idsUsuarios.add(aplicacao.idEntrevistado!);
            for (var resposta in aplicacao.respostas) {
              idsQuestoes.add(resposta['idQuestao']);
            }
          }

          final questoesOrdenadas = idsQuestoes.toList()..sort();

          // FutureBuilder para buscar nomes e enunciados
          return FutureBuilder<Map<String, dynamic>>(
            future: () async {
              final nomes = <String, String>{};
              for (var id in idsUsuarios) {
                nomes[id] = await buscarNomeUsuario(id);
              }
              final enunciados = await buscarEnunciadosQuestoes(
                questionario.id,
              );
              return {'nomes': nomes, 'enunciados': enunciados};
            }(),
            builder: (context, snapshot2) {
              if (!snapshot2.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final nomes = snapshot2.data!['nomes'] as Map<String, String>;
              final enunciados =
                  snapshot2.data!['enunciados'] as Map<String, String>;

              final cabecalho = [
                'ID Aplicação',
                'Entrevistador',
                'Entrevistado',
                ...questoesOrdenadas.map((id) => enunciados[id] ?? id),
              ];

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        maxWidth: 2000,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.all(16),
                          child: PaginatedDataTable(
                            header: _TableHeader(
                              questionario: questionario,
                              totalAplicacoes: aplicacoes.length,
                            ),
                            rowsPerPage: 10,
                            columnSpacing: 24,
                            horizontalMargin: 20,
                            headingRowHeight: 96,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 60,
                            dividerThickness: 1.2,
                            showCheckboxColumn: false,
                            showFirstLastButtons: true,
                            availableRowsPerPage: const [10, 20, 50],
                            onRowsPerPageChanged: (value) {},
                            columns: cabecalho
                                .map(
                                  (titulo) => DataColumn(
                                    label: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          45,
                                          12,
                                          68,
                                        ),
                                      ),
                                      child: Text(
                                        titulo,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onPrimary,
                                            ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            source: _DataSource(
                              aplicacoes,
                              questoesOrdenadas,
                              nomes,
                              enunciados,
                              theme: theme,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final Questionario questionario;
  final int totalAplicacoes;

  const _TableHeader({
    required this.questionario,
    required this.totalAplicacoes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final int meta = questionario.meta ?? 0;
    final double progresso = meta > 0
        ? (totalAplicacoes / meta).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: progresso,
                backgroundColor: colorScheme.surfaceVariant,
                color: colorScheme.primary,
                minHeight: 8,
              ),
              const SizedBox(height: 6),
              Text(
                meta > 0
                    ? '$totalAplicacoes / $meta aplicados'
                    : '$totalAplicacoes aplicados (Meta não definida)',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DataSource extends DataTableSource {
  final List<Aplicacaoquestionario> aplicacoes;
  final List<String> questoesOrdenadas;
  final Map<String, String> nomes;
  final Map<String, String> enunciados;
  final ThemeData theme;

  _DataSource(
    this.aplicacoes,
    this.questoesOrdenadas,
    this.nomes,
    this.enunciados, {
    required this.theme,
  });

  @override
  DataRow getRow(int index) {
    final aplicacao = aplicacoes[index];
    final isEvenRow = index.isEven;
    final colorScheme = theme.colorScheme;

    final Map<String, dynamic> mapaRespostas = {
      for (var r in aplicacao.respostas) r['idQuestao']: r['resposta'],
    };

    String formatarResposta(dynamic resposta) {
      if (resposta == null) return 'Sem dados';

      if (resposta is Timestamp) {
        return resposta.toDate().toIso8601String();
      }

      final raw = resposta.toString();
      final regex = RegExp(r'seconds=(\d+)');
      final match = regex.firstMatch(raw);

      if (match != null) {
        try {
          final seconds = int.parse(match.group(1)!);
          final data = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
          return data.toIso8601String();
        } catch (_) {
          return raw;
        }
      }

      try {
        final data = DateTime.parse(raw);
        return data.toIso8601String();
      } catch (_) {
        return raw;
      }
    }

    final dadosLinha = [
      aplicacao.idAplicacao,
      nomes[aplicacao.idEntrevistador] ?? aplicacao.idEntrevistador ?? '',
      nomes[aplicacao.idEntrevistado] ?? aplicacao.idEntrevistado ?? '',
      ...questoesOrdenadas.map((id) => formatarResposta(mapaRespostas[id])),
    ];

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.hovered)) {
          return colorScheme.primary.withOpacity(0.1);
        }
        return isEvenRow
            ? colorScheme.surfaceVariant.withOpacity(0.3)
            : colorScheme.surface;
      }),
      cells: dadosLinha
          .map(
            (dado) => DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  dado.toString(),
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  int get rowCount => aplicacoes.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}