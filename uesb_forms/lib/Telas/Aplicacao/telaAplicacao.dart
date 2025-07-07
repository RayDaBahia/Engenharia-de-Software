import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/aplicacao_list.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_provider.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';
import 'package:uesb_forms/Utils/cloudinary_service.dart';

class TelaAplicacao extends StatefulWidget {
  final String perfilUsuario;
  final String? idEntrevistador;

  const TelaAplicacao({
    Key? key,
    required this.perfilUsuario,
    this.idEntrevistador,
  }) : super(key: key);

  @override
  _TelaAplicacaoState createState() => _TelaAplicacaoState();
}

class _TelaAplicacaoState extends State<TelaAplicacao> {
  late Questionario _questionario;
  int _indiceAtual = 0;
  bool _isLoading = false;
  final List<int> _historicoNavegacao = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Questionario) {
        _carregarQuestionario(args);
        Provider.of<RespostaProvider>(context, listen: false).limparRespostas();
      }
    });
  }

  Future<void> _carregarQuestionario(Questionario questionario) async {
    setState(() => _isLoading = true);
    _questionario = questionario;
    await Provider.of<QuestionarioList>(
      context,
      listen: false,
    ).buscarQuestoes(questionario.id);
    if (mounted) setState(() => _isLoading = false);
  }

  void _avancar() {
    final questionarioList = Provider.of<QuestionarioList>(
      context,
      listen: false,
    );
    final questoes = questionarioList.listaQuestoes;
    final respostaProvider = Provider.of<RespostaProvider>(
      context,
      listen: false,
    );

    if (_isLoading || questoes.isEmpty) return;

    final questaoAtual = questoes[_indiceAtual];
    final resposta = respostaProvider.obterResposta(questaoAtual.id!);

    // Verificação de questão obrigatória
    if (questaoAtual.obrigatoria &&
        (resposta == null ||
            (resposta is String && resposta.trim().isEmpty) ||
            (resposta is List && resposta.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Essa questão é obrigatória! Por favor, responda antes de continuar.',
          ),
        ),
      );
      return;
    }

    // Validação de e-mail reforçada
    if (questaoAtual.tipoQuestao == QuestaoTipo.Email && resposta is String) {
      final email = resposta.trim();

      if (questaoAtual.obrigatoria && email.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('E-mail é obrigatório!')));
        return;
      }

      if (email.isNotEmpty && !isEmailValido(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, insira um e-mail válido.')),
        );
        return;
      }
    }

    _historicoNavegacao.add(_indiceAtual);

    // Lógica de navegação dinâmica
    if (resposta != null && questaoAtual.direcionamento != null) {
      String? respostaParaNavegacao;
      if (resposta is int && questaoAtual.opcoes != null) {
        if (resposta >= 0 && resposta < questaoAtual.opcoes!.length) {
          respostaParaNavegacao = questaoAtual.opcoes![resposta];
        }
      } else {
        respostaParaNavegacao = resposta.toString();
      }

      if (respostaParaNavegacao != null &&
          questaoAtual.direcionamento!.containsKey(respostaParaNavegacao)) {
        final nextId = questaoAtual.direcionamento![respostaParaNavegacao];
        final nextIndex = questoes.indexWhere((q) => q.id == nextId);
        if (nextIndex != -1) {
          setState(() => _indiceAtual = nextIndex);
          return;
        }
      }
    }

    if (_indiceAtual < questoes.length - 1) {
      setState(() => _indiceAtual++);
    } else {
      _finalizarQuestionario();
    }
  }

  void _voltar() {
    if (_historicoNavegacao.isNotEmpty) {
      setState(() => _indiceAtual = _historicoNavegacao.removeLast());
    } else if (_indiceAtual > 0) {
      setState(() => _indiceAtual--);
    }
  }

  Future<void> _finalizarQuestionario() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final respostaProvider = Provider.of<RespostaProvider>(
        context,
        listen: false,
      );
      final aplicacaoList = Provider.of<AplicacaoList>(context, listen: false);
      final questionarioList = Provider.of<QuestionarioList>(
        context,
        listen: false,
      );
      final questoes = questionarioList.listaQuestoes;

      final respostasMap = Map<String, dynamic>.from(
        respostaProvider.todasRespostas,
      );
      final cloudinary = CloudinaryService();

      for (final questao in questoes) {
        final resposta = respostasMap[questao.id];
        if (questao.tipoQuestao == QuestaoTipo.Captura &&
            resposta is Uint8List) {
          try {
            final fileName =
                'aplicacao_${aplicacaoList.aplicacaoAtual.idAplicacao}_${questao.id}.jpg';
            final result = await cloudinary.uploadImage(
              imageBytes: resposta,
              fileName: fileName,
              questionId: questao.id!,
            );
            if (result != null && result.url != null) {
              respostasMap[questao.id!] = result.url ?? '';
            }
          } catch (_) {
            // Se falhar, mantém a resposta original
          }
        }
      }

      aplicacaoList.aplicacaoAtual.respostas = respostasMap.entries
          .map((e) => {'idQuestao': e.key, 'resposta': e.value})
          .toList();

      await aplicacaoList.persistirNoFirebase();

      if (mounted) {
        Provider.of<QuestionarioList>(context, listen: false).limparQuestoes();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Questionário finalizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionarioList = Provider.of<QuestionarioList>(context);
    final questoes = questionarioList.listaQuestoes;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _questionario.nome,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 45, 12, 68),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questoes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _questionario.nome,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 45, 12, 68),
        ),
        body: const Center(child: Text('Nenhuma pergunta disponível')),
      );
    }

    final questaoAtual = questoes[_indiceAtual];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _questionario.nome,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_indiceAtual + 1) / questoes.length,
            backgroundColor: Colors.grey[300],
            color: const Color.fromARGB(255, 45, 12, 68),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Questão ${_indiceAtual + 1} de ${questoes.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  QuestaoWidgetForm(
                    questao: questaoAtual,
                    key: ValueKey(questaoAtual.id),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _voltar,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B0C2F),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.chevron_left, color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: _isLoading ? null : _avancar,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B0C2F),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _indiceAtual == questoes.length - 1
                          ? Icons.check
                          : Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isEmailValido(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
      caseSensitive: false,
    );
    return emailRegex.hasMatch(email);
  }
}
