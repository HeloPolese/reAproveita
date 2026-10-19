import 'package:reaproveita/models/itemCarrinho.dart';

class Carrinho {
  List<ItemCarrinho> listagem;

  Carrinho({
    required this.listagem,
  });

  double get valorTotal {
    double total = 0;

    for (ItemCarrinho item in listagem) {
      total += item.subtotal;
    }

    return total;
  }

  void adicionarProduto(ItemCarrinho item) {
    listagem.add(item);
  }

  void retirarProduto(ItemCarrinho item) {
    listagem.remove(item);
  }
  void limparCarrinho(){
    listagem.clear();
  }
}