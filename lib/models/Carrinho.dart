import 'produto.dart';

class Carrinho {
  List<Produto> listagem;

  Carrinho({
    required this.listagem,
  });

  double get valorTotal {
    double total = 0;

    for (Produto produto in listagem) {
      total += produto.preco;
    }

    return total;
  }

  void adicionarProduto(Produto produto) {
    listagem.add(produto);
  }

  void retirarProduto(Produto produto) {
    listagem.remove(produto);
  }
}