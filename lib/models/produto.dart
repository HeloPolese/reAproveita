
import 'vendedor.dart';

class Produto {
  String nome;
  String categoria;
  String unidadeMedida;
  String validade;
  String fabricacao;
  double preco;
  int quantidadeDisponivel;
  String descricao;
  String imagem;
  bool adicionarAoCarrinho;
  Vendedor vendedor;

  Produto({
    required this.nome,
    required this.categoria,
    required this.unidadeMedida,
    required this.validade,
    required this.fabricacao,
    required this.preco,
    required this.quantidadeDisponivel,
    required this.descricao,
    required this.imagem,
    required this.vendedor,
    this.adicionarAoCarrinho = false,
  });
}
