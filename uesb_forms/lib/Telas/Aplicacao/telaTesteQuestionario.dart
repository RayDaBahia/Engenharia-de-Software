import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Controle_Modelo/resposta_provider.dart';
import 'package:uesb_forms/Modelo/Questionario.dart';
import 'package:uesb_forms/Componentes/Formulario/QuestaoWidgetForm.dart';

class TelaTesteQuestionario extends StatefulWidget {
  final String perfilUsuario;
  final String? idEntrevistador;

  const TelaTesteQuestionario({
    Key? key,
    required this.perfilUsuario,
    this.idEntrevistador,
  }) : super(key: key);

  @override
  _TelaTesteQuestionarioState createState() => _TelaTesteQuestionarioState();
}

class _TelaTesteQuestionarioState extends State<TelaTesteQuestionario> {
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
    await Provider.of<QuestionarioList>(context, listen: false)
        .buscarQuestoes(questionario.id);
    if (mounted) setState(() => _isLoading = false);
  }

  void _avancar() {
    final questionarioList =
        Provider.of<QuestionarioList>(context, listen: false);
    final questoes = questionarioList.listaQuestoes;
    final respostaProvider =
        Provider.of<RespostaProvider>(context, listen: false);

    if (_isLoading || questoes.isEmpty) return;

    final questaoAtual = questoes[_indiceAtual];
    final resposta = respostaProvider.obterResposta(questaoAtual.id!);

    // Verificação de questão obrigatória
    if (questaoAtual.obrigatoria && resposta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Essa questão é obrigatória! Por favor, responda antes de continuar.')),
      );
      return;
    }

    _historicoNavegacao.add(_indiceAtual);

    // Lógica de navegação dinâmica (usando apenas opcoes)
    if (resposta != null && questaoAtual.direcionamento != null) {
      String? respostaParaNavegacao;

      // 1. Se for índice (resposta int) e tiver opcoes
      if (resposta is int && questaoAtual.opcoes != null) {
        if (resposta >= 0 && resposta < questaoAtual.opcoes!.length) {
          respostaParaNavegacao = questaoAtual.opcoes![resposta];
        }
      }
      // 2. Se já for texto direto
      else {
        respostaParaNavegacao = resposta.toString();
      }

      // Navegação dinâmica
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

    // Navegação padrão (próxima questão na lista)
    if (_indiceAtual < questoes.length - 1) {
      setState(() => _indiceAtual++);
    } else {
      _finalizarTeste();
    }
  }

  void _voltar() {
    if (_historicoNavegacao.isNotEmpty) {
      setState(() => _indiceAtual = _historicoNavegacao.removeLast());
    } else if (_indiceAtual > 0) {
      setState(() => _indiceAtual--);
    }
  }

  void _finalizarTeste() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teste Concluído'),
        content: const Text('Você concluiu o teste do questionário.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) {
      Navigator.of(context).pop(); // Fecha o diálogo
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionarioList = Provider.of<QuestionarioList>(context);
    final questoes = questionarioList.listaQuestoes;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Teste: ${_questionario.nome}',
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
            'Teste: ${_questionario.nome}',
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
          'Teste: ${_questionario.nome}',
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
             Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Espaçamento da borda
                    child: GestureDetector(
                      onTap: _isLoading ? null : _avancar,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(
                              0xFF1B0C2F), // Cor de fundo (ajuste conforme desejar)
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(12),
                        child: _indiceAtual == questoes.length - 1
                            ? Icon(
                                  Icons.check,

                                color: Colors.white,
                              )
                            : Icon(
                              Icons.chevron_right,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
