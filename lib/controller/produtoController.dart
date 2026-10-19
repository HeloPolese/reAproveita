// ignore: file_names
import '../models/produto.dart';
import '../models/vendedor.dart';

class ProdutoController {
  final List<Produto> produtos = [];

  Produto cadastrar({
    required Vendedor vendedor,
    required String nome,
    required UnidadeMedida unidadeMedida,
    required String validade,
    required String fabricacao,
    required double preco,
    required int quantidadeDisponivel,
    required String descricao,
    String imagem = '',
  }) {
    if (nome.trim().isEmpty ||
        validade.trim().isEmpty ||
        fabricacao.trim().isEmpty ||
        descricao.trim().isEmpty) {
      throw Exception('Preencha todos os campos obrigatórios.');
    }

    if (!preco.isFinite || preco <= 0) {
      throw Exception('O preço deve ser maior que zero.');
    }

    if (quantidadeDisponivel <= 0) {
      throw Exception('A quantidade deve ser maior que zero.');
    }

    final produto = Produto(
      nome: nome.trim(),
      unidadeMedida: unidadeMedida,
      validade: validade.trim(),
      fabricacao: fabricacao.trim(),
      preco: preco,
      quantidadeDisponivel: quantidadeDisponivel,
      descricao: descricao.trim(),
      imagem: imagem.trim(),
      vendedor: vendedor,
    );

    produtos.add(produto);

    return produto;
  }
}
