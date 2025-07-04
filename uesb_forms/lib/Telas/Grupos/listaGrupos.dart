import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Componentes/Grupos/grupoCard.dart';
import 'package:uesb_forms/Componentes/menu_lateral.dart';
import 'package:uesb_forms/Controle_Modelo/grupo_list.dart';
import 'package:uesb_forms/Controle_Modelo/questionario_list.dart';
import 'package:uesb_forms/Modelo/grupo.dart';
import 'package:uesb_forms/Telas/Formulario/ConfigurarAcesso.dart';
import 'package:uesb_forms/Utils/rotas.dart';

class ListaGrupos extends StatefulWidget {
  final bool lider;
  final List<String> gruposIniciais;

  const ListaGrupos({
    Key? key,
    required this.lider,

    this.gruposIniciais = const [],
  }) : super(key: key);

  @override
  State<ListaGrupos> createState() => _ListaGruposState();
}

class _ListaGruposState extends State<ListaGrupos> {
  String filtroPesquisa = '';
  bool _gruposCarregados = false;
  final Set<String> _selecionados = {};
  final _debouncer = Debouncer(milliseconds: 300); // Para otimizar a pesquisa

  @override
  void initState() {
    super.initState();
    _selecionados.addAll(widget.gruposIniciais);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('🔍 ListaGrupos: widget.lider = ${widget.lider}');

    if (!_gruposCarregados) {
      final grupoList = Provider.of<GrupoList>(context, listen: false);
      final Future<void> carregamento = widget.lider
          ? grupoList.buscarGruposPorLider()
          : grupoList.buscarGruposPorEntrevistador();

      carregamento.then((_) {
        if (mounted) {
          setState(() {
            _gruposCarregados = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      body: Consumer2<GrupoList, QuestionarioList>(
        builder: (context, grupoList, questionarioList, _) {
          final todosGrupos = widget.lider
              ? grupoList.gruposLider
              : grupoList.gruposEntrevistador;

          List<Grupo> gruposVisiveis = todosGrupos.where((grupo) {
            final correspondePesquisa =
                filtroPesquisa.isEmpty ||
                grupo.nome.toLowerCase().contains(filtroPesquisa.toLowerCase());

            return correspondePesquisa;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Pesquisar grupos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (texto) {
                    _debouncer.run(() {
                      if (mounted) {
                        setState(() {
                          filtroPesquisa = texto;
                        });
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: gruposVisiveis.isEmpty
                    ? const Center(child: Text('Nenhum grupo encontrado'))
                    : ListView.builder(
                        itemCount: gruposVisiveis.length,
                        itemBuilder: (context, index) {
                          final grupo = gruposVisiveis[index];

                          return GrupoCard(grupo: grupo, isLider: widget.lider);
                        },
                      ),
              ),
              if (widget.lider) _botaoAdicionarGrupo(context),
            ],
          );
        },
      ),
    );
  }

  Widget _botaoAdicionarGrupo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, Rotas.CRIAR_GRUPO),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 45, 12, 68),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}

// Classe auxiliar para otimizar a pesquisa
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
