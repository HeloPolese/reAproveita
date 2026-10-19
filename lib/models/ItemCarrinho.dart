
import '../models/produto.dart';

class ItemCarrinho {
  Produto produto;
  int quantidade;

  ItemCarrinho({
    required this.produto,
    this.quantidade = 1,
  });

  double get subtotal {
    return produto.preco * quantidade;
  }

  Produto get getProduto{
    return this.produto;
  }

}
