import 'package:reaproveita/models/ItemCarrinho.dart';

class Carrinho {
  List<ItemCarrinho> listagem;

  Carrinho({
    required this.listagem,
  });

  double get valorTotal {
    double total = 0;

    for (ItemCarrinho item in listagem) {
      total += item.produto.preco * item.quantidade;
    }

    return total;
  }

  void retirarProduto(ItemCarrinho item) {
    listagem.remove(item);
  }

  void limparCarrinho(){
    listagem.clear();
  }

  void adicionarProduto(ItemCarrinho item){
    this.listagem.add(item);
  }
}