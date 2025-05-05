import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/questaoWidget.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_opcoes_questao.dart';

import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Modelo/Banco.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/questaoWidget.dart';
import 'package:uesb_forms/Componentes/BancoDeQuestoes/widget_opcoes_questao.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/banco_list.dart';
import 'package:uesb_forms/Modelo/questao.dart';
import 'package:uesb_forms/Modelo/questao_tipo.dart';
import 'package:uesb_forms/Modelo/Banco.dart';

class CrudBancoQuestoes extends StatefulWidget {
  const CrudBancoQuestoes({super.key});

  @override
  State<CrudBancoQuestoes> createState() => _CrudBancoQuestoesState();
}

class _CrudBancoQuestoesState extends State<CrudBancoQuestoes> {
  Banco? banco;
  bool _isLoaded = false;

  late TextEditingController _descricaoBancoController;
  late TextEditingController _nomeBancoController;
  late TextEditingController _questaoFiltro;

  @override
  void initState() {
    super.initState();
    _descricaoBancoController = TextEditingController();
    _nomeBancoController = TextEditingController();
    _questaoFiltro = TextEditingController();

    // Adicione um listener ao controlador de filtro
    _questaoFiltro.addListener(() {
      setState(() {}); // Atualiza a UI quando o filtro muda
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Banco) {
        banco = args;
        Provider.of<BancoList>(context, listen: false)
            .buscarQuestoesBancoNoBd(banco!.id);

        _descricaoBancoController.text = banco!.descricao;
        _nomeBancoController.text = banco!.nome;
      } else {
        Provider.of<BancoList>(context, listen: false).limparListaQuestoes();
      }

      _isLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bancoList = Provider.of<BancoList>(context, listen: true);

    // Filtrar questões com base na entrada de pesquisa
    final filtroTexto = _questaoFiltro.text.toLowerCase();
    final questoesFiltradas = bancoList.filtrarQuestoes(filtroTexto);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 45, 12, 68),
        title: TextField(
          controller: _questaoFiltro,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(255, 45, 12, 68),
            labelText: '',
            labelStyle:
                TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
            prefixIcon:
                Icon(Icons.search, color: Color.fromARGB(255, 251, 253, 254)),
          ),
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[botaoSalvar(bancoList)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Campos de texto para nome e descrição do banco
            TextField(
              controller: _nomeBancoController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText:
                    _nomeBancoController.text.isEmpty ? 'Banco Sem Título' : '',
                labelStyle: TextStyle(
                  color: Color.fromARGB(255, 27, 7, 80),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: TextField(
                controller: _descricaoBancoController,
                maxLines:
                    null, // Permite que o campo de descrição cresça conforme necessário
                maxLength: 150, // Limite de 150 caracteres
                decoration: InputDecoration(
                  labelText: _descricaoBancoController.text.isEmpty
                      ? 'adicione uma descrição ao banco'
                      : '',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  setState(
                      () {}); // Atualiza a UI para o contador de caracteres
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: questoesFiltradas.length,
                itemBuilder: (context, index) {
                  final questao = questoesFiltradas[index];
                  return QuestaoWidget(
                    questao: questao,
                    bancoId: banco?.id ?? '',
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WidgetOpcoesQuestao(),
                const SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descricaoBancoController.dispose();
    _nomeBancoController.dispose();
    _questaoFiltro.dispose();
    super.dispose();
  }

  Widget botaoSalvar(BancoList bancoList) {
    return TextButton(
      onPressed: () async {
        if (banco == null) {
          try {
            await bancoList.SalvarBanco(
              _nomeBancoController.text,
              _descricaoBancoController.text,   );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Banco criado com sucesso!")),
            );
            Navigator.of(context).pop();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro ao criar banco: $e")),
            );
          }
        } else {
          try {
            banco!.nome = _nomeBancoController.text;
            banco!.descricao = _descricaoBancoController.text;
            await bancoList.AtualizarBanco(banco!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Banco atualizado com sucesso!")),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro ao atualizar banco: $e")),
            );
          }
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 37, 7, 88),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: banco == null ? const Text('Salvar') : const Text('Atualizar'),
    );
  }
}
