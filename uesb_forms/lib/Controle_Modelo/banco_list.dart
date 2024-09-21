import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_list.dart'; 
import 'Modelo/Banco.dart';

class BancoList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
  // pega o usuário logado 
  final AuthList _authList;

  BancoList(this._authList);

  // Método para adicionar um banco já existente
  Future<void> addBanco(Banco banco) async {
    final user = _authList.usuario; // Obtém o usuário logado através do provider
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Adiciona o banco à coleção de bancos do usuário no Firestore
      await _firestore
          .collection('usuarios') // Coleção dos usuários
          .doc(user.id) // ID do usuário
          .collection('bancos') // Subcoleção 'bancos' do usuário
          .add({
        'nome': banco.nome,
        'descricao': banco.descricao,
        'questoes': banco.questoes?.map((q) => q.toMap()).toList() ?? [],
      });

      notifyListeners();
    } catch (error) {
      throw Exception('Erro ao adicionar o banco: $error');
    }
  }

  // Método para criar um banco, passa parâmetro de nome e descrição (espero que o ID gere automático kkkkkk)
  Future<void> criarBanco(String nome, String descricao) async {
    final user = _authList.usuario; // Obtém o usuário logado
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    // Cria um novo objeto Banco
    final novoBanco = Banco(
      id: '', // espero que o firestore gere o ID kkkkkkkkk
      nome: nome,
      descricao: descricao,
    );

    // Chama o método addBanco para adicionar o banco criado
    await addBanco(novoBanco);
  }

  // Método para retornar os bancos do usuário l
  Future<List<Banco>> getBancos() async {
    final user = _authList.usuario; // Obtém o usuário através do provider
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Busca todos os bancos do usuário no Firestore
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('usuarios')
          .doc(user.id)
          .collection('bancos')
          .get();

      // Converte os documentos retornados em uma lista de objetos Banco
      return snapshot.docs.map((doc) {
        return Banco(
          id: doc.id,
          nome: doc['nome'],
          descricao: doc['descricao'],
          questoes: (doc['questoes'] as List?)
              ?.map((q) => Questao.fromMap(q))
              .toList(),
        );
      }).toList();
    } catch (error) {
      throw Exception('Erro ao obter bancos: $error');
    }
  }
}

