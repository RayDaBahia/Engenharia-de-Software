import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uesb_forms/Controle_Modelo/auth_list.dart';
import 'package:uesb_forms/Modelo/grupo.dart';

class GrupoList extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthList? _authList;

  GrupoList(this._authList);

  List<Grupo> _gruposLider = [];
  List<Grupo> _gruposEntrevistador = [];

  List<Grupo> get gruposLider => [..._gruposLider];
  List<Grupo> get gruposEntrevistador => [..._gruposEntrevistador];

  /// Adicionar novo grupo
Future<void> addGrupo(String nome, String? descricao, List<String>? entrevistadores) async {
  try {
    final usuario = _authList?.usuario;
    if (usuario != null && usuario.id != null) {
      Grupo grupo = Grupo(
        nome: nome,
        idLider: usuario.id!,
        descricao: descricao ?? '', // usa string vazia se for null
        idEntrevistadores: entrevistadores ?? [], // usa lista vazia se for null
      );

      await _firestore.collection('grupos').add(grupo.toMap());
      await buscarGruposPorLider(); // atualiza a lista após inserção
    }
  } catch (e) {
    debugPrint('Erro ao adicionar grupo: $e');
  }
}


  /// Buscar grupos do líder atual
  Future<void> buscarGruposPorLider() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('grupos')
          .where('idLider', isEqualTo: user.uid)
          .get();

      _gruposLider = snapshot.docs
          .map((doc) => Grupo.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar grupos por líder: $e');
    }
  }

  /// Buscar grupos onde o usuário é entrevistador
  Future<void> buscarGruposPorEntrevistador() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore.collection('grupos').get();

      _gruposEntrevistador = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final entrevistadores = List<String>.from(data['idEntrevistadores'] ?? []);
            return entrevistadores.contains(user.email); // ou user.uid
          })
          .map((doc) => Grupo.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar grupos por entrevistador: $e');
    }
  }

  /// Atualizar grupo
 Future<void> atualizarGrupo(Grupo grupoAtualizado) async {
  try {
    await _firestore.collection('grupos').doc(grupoAtualizado.id).update(grupoAtualizado.toMap());

    // Atualiza localmente a lista, buscando o índice do grupo e substituindo o objeto
    int index = _gruposLider.indexWhere((g) => g.id == grupoAtualizado.id);
    if (index != -1) {
      _gruposLider[index] = grupoAtualizado;
      notifyListeners();
      return;
    }

    index = _gruposEntrevistador.indexWhere((g) => g.id == grupoAtualizado.id);
    if (index != -1) {
      _gruposEntrevistador[index] = grupoAtualizado;
      notifyListeners();
      return;
    }
  } catch (e) {
    debugPrint('Erro ao atualizar grupo: $e');
  }
}

  /// Apagar grupo
  Future<void> apagarGrupo(String grupoId) async {
    try {
      await _firestore.collection('grupos').doc(grupoId).delete();

      _gruposLider.removeWhere((grupo) => grupo.id == grupoId);

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao apagar grupo: $e');
    }
  }

  /// Adicionar ou remover entrevistador
  Future<void> modificarEntrevistador(String grupoId, String entrevistadorId,
      {required bool adicionar}) async {
    try {
      final docRef = _firestore.collection('grupos').doc(grupoId);
      final doc = await docRef.get();

      if (doc.exists) {
        List<String> entrevistadores =
            List<String>.from(doc['idEntrevistadores'] ?? []);

        if (adicionar && !entrevistadores.contains(entrevistadorId)) {
          entrevistadores.add(entrevistadorId);
        } else if (!adicionar && entrevistadores.contains(entrevistadorId)) {
          entrevistadores.remove(entrevistadorId);
        }

        await docRef.update({'idEntrevistadores': entrevistadores});
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao modificar entrevistador: $e');
    }
  }


/// Buscar grupos por uma lista de IDs
Future<List<Grupo>> buscarGruposPorIds(List<String> grupoIds) async {
  if (grupoIds.isEmpty) return [];

  try {
    // Firestore não permite uma query com whereIn com mais que 10 elementos,
    // então se a lista for maior que 10, precisamos dividir em lotes
    final List<Grupo> grupos = [];

    const int batchSize = 10;
    for (var i = 0; i < grupoIds.length; i += batchSize) {
      final end = (i + batchSize > grupoIds.length) ? grupoIds.length : i + batchSize;
      final batchIds = grupoIds.sublist(i, end);

      final snapshot = await _firestore
          .collection('grupos')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      grupos.addAll(snapshot.docs.map((doc) => Grupo.fromMap(doc.data(), doc.id)));
    }

    return grupos;
  } catch (e) {
    debugPrint('Erro ao buscar grupos por IDs: $e');
    return [];
  }
}

Future<Grupo?> buscarGrupoPorId(String grupoId) async {
  if (grupoId.isEmpty) return null;

  try {
    final doc = await _firestore.collection('grupos').doc(grupoId).get();

    if (doc.exists) {
      return Grupo.fromMap(doc.data()!, doc.id);
    } else {
      return null;
    }
  } catch (e) {
    debugPrint('Erro ao buscar grupo por ID: $e');
    return null;
  }
}

/// Buscar grupos por nome (prefixo)
// Em GrupoList
Future<List<Grupo>> buscarGruposPorNome(String nome) async {
  try {
    final snapshot = await _firestore
        .collection('grupos')
        .where('nome', isGreaterThanOrEqualTo: nome)
        .where('nome', isLessThan: nome + 'z')
        .get();

    return snapshot.docs.map((doc) => Grupo.fromMap(doc.data(), doc.id)).toList();
  } catch (e) {
    debugPrint('Erro na busca de grupos: $e');
    return [];
  }
}



}
