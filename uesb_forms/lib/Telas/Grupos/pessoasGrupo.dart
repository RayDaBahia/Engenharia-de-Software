import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Modelo/grupo.dart';
import 'package:uesb_forms/Modelo/usuario.dart';


class PessoasGrupo extends StatefulWidget{

Grupo grupo;

PessoasGrupo(this.grupo);


  @override
  State<PessoasGrupo> createState() => _PessoasGrupoState();
}

class _PessoasGrupoState extends State<PessoasGrupo>{

List<Usuario> entrevistadores = [];
  List<Usuario> entrevistadoresFiltrados = [];
  late Usuario lider;
  bool carregando = true;
  final TextEditingController _pesquisaController = TextEditingController();

      int _selectedIndex = 0;

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> buscarUsuarios(BuildContext context, Grupo grupo) async {
    final authList = Provider.of<AuthList>(context, listen: false);
    final usuarioLider = await authList.buscarUsuarioPorId(grupo.idLider);

    List<Usuario> listaEntrevistadores = [];
    if (grupo.idEntrevistadores != null) {
      final futures = grupo.idEntrevistadores!.map((email) async {
        final usuariosStream = authList.buscarUsuariosPorEmail(email, entrevistador: 'entrevistador');
        final usuarios = await usuariosStream.first;
        return usuarios.isNotEmpty ? usuarios.first : null;
      });

      final resultado = await Future.wait(futures);
      listaEntrevistadores = resultado.whereType<Usuario>().toList();
    }

    setState(() {
      lider = usuarioLider!;
      entrevistadores = listaEntrevistadores;
      entrevistadoresFiltrados = listaEntrevistadores;
      carregando = false;
    });
  }

  void _filtrarEntrevistadores(String query) {
    final listaFiltrada = entrevistadores.where((usuario) {
      return usuario.nome!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      entrevistadoresFiltrados = listaFiltrada;
    });
  }

  @override
  Widget build(BuildContext context) {


    if (carregando) {
      buscarUsuarios(context, widget.grupo);
    }

    return Scaffold(
   
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.grupo.nome,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(widget.grupo.descricao ?? '',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildSectionTitle("Líder"),
                _buildUserTile(
                  nome: lider.nome!,
                  email: lider.email!,
                  cor: Colors.green,
                ),
                const Divider(height: 16),
                _buildSectionTitle("Entrevistador"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _pesquisaController,
                    decoration: InputDecoration(
                      labelText: 'Pesquisar entrevistador',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: _filtrarEntrevistadores,
                  ),
                ),
                const SizedBox(height: 8),
                ...entrevistadoresFiltrados.map((e) => _buildUserTile(
                      nome: e.nome!,
                      email: e.email!,
                      cor: _corAleatoria(e.nome!),
                    )),
              ],
            ),
  
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildUserTile(
      {required String nome, required String email, required Color cor}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cor,
        child: Text(nome.isNotEmpty ? nome[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white)),
      ),
      title: Text(nome),
      subtitle: Text(email),
    );
  }



Color _corAleatoria(String nome) {
  final cores = [Colors.red, Colors.blue, Colors.purple, Colors.teal];

  if (nome.isEmpty) return Colors.grey; // cor padrão segura

  return cores[nome.codeUnitAt(0) % cores.length];
}


}