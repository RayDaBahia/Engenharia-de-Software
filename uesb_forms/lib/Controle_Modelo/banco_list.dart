import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uesb_forms/Modelo/banco.dart';
import 'auth_list.dart';

class BancoList with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pega o usuário logado
  final AuthList? _authList;

  BancoList([this._authList]);

  // Método para adicionar um banco existente
  Future<void> addBancoOuAtualizar(Banco banco) async {


    final user = _authList?.usuario; // Obtém o usuário logado
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

   
      // Se o id não está vazio, usa o set com o ID fornecido, senão usa add
  if (banco.id.isNotEmpty) {
    await _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .doc(banco.id) // Usando o ID fornecido
        .set({
      'nome': banco.nome,
      'descricao': banco.descricao,
    });
  } else {
    await _firestore
        .collection('usuarios')
        .doc(user.id)
        .collection('bancos')
        .add({
      'nome': banco.nome,
      'descricao': banco.descricao,
    });
  }

  notifyListeners();
  }

  // Método para criar um banco, passando nome e descrição
 Future<void> SalvarBanco(String nome, String descricao, [String? id]) async {
  final user = _authList?.usuario; // Obtém o usuário logado
  if (user == null) {
    throw Exception('Usuário não autenticado');
  }

  // Cria um novo objeto Banco
  final novoBanco = Banco(
    id: id ?? '', // Se id for null, usa uma string vazia
    nome: nome,
    descricao: descricao,
  );

  // Chama o método addBanco para adicionar o banco criado



  await addBancoOuAtualizar(novoBanco);

  

  notifyListeners();
}


  // Método para retornar os bancos do usuário
  Future<List<Banco>> getBancos() async {
    final user = _authList?.usuario; //Obtém o usuário logado
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

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
        );
      }).toList();

  
    
    
  }
}