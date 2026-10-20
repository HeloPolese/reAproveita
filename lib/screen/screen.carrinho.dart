import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reaproveita/models/carrinho.dart';
import 'package:reaproveita/models/itemCarrinho.dart';

class CarrinhoPage extends StatefulWidget {
  final Carrinho carrinho;

  const CarrinhoPage({super.key, required this.carrinho});

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  static const Color verde = Color(0xFF2E7D32);

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _aumentarQuantidade(ItemCarrinho item) {
    if (item.quantidade < item.produto.quantidadeDisponivel) {
      setState(() => item.quantidade++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Quantidade máxima disponível: ${item.produto.quantidadeDisponivel}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _diminuirQuantidade(ItemCarrinho item) {
    if (item.quantidade > 1) {
      setState(() => item.quantidade--);
    }
  }

  void _removerItem(ItemCarrinho item) {
    setState(() => widget.carrinho.retirarProduto(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.produto.nome} removido do carrinho'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmarLimpar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar carrinho'),
        content: const Text('Deseja remover todos os itens do carrinho?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => widget.carrinho.limparCarrinho());
    }
  }

  @override
  Widget build(BuildContext context) {
    final itens = widget.carrinho.listagem;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: verde,
        foregroundColor: Colors.white,
          title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/reaproveita.jpeg',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          const Text('Meu Carrinho'),
        ],
      ),
        centerTitle: true,
        actions: [
          if (itens.isNotEmpty)
            IconButton(
              tooltip: 'Limpar carrinho',
              icon: const Icon(Icons.delete_sweep),
              onPressed: _confirmarLimpar,
            ),
        ],
      ),
      body: itens.isEmpty ? _buildCarrinhoVazio() : _buildLista(itens),
      bottomNavigationBar: itens.isEmpty ? null : _buildResumo(),
    );
  }

  Widget _buildCarrinhoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 90, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Seu carrinho está vazio',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(List<ItemCarrinho> itens) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: itens.length,
      itemBuilder: (context, index) => _buildItem(itens[index]),
    );
  }

  Widget _buildItem(ItemCarrinho item) {
    final produto = item.produto;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: _buildImagem(produto.imagem),
              ),
            ),
            const SizedBox(width: 12),

            // Informações do produto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vendedor: ${produto.vendedor.nome}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatarPreco(produto.preco)} / ${produto.unidadeMedida}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildControleQuantidade(item),
                      Text(
                        _formatarPreco(item.subtotal),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: verde,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botão remover
            IconButton(
              tooltip: 'Remover',
              icon: const Icon(Icons.close, color: Colors.red),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _removerItem(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagem(String caminho) {
    final placeholder = Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );

    if (caminho.isEmpty) return placeholder;

    if (caminho.startsWith('http')) {
      return Image.network(
        caminho,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return Image.asset(
      caminho,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  Widget _buildControleQuantidade(ItemCarrinho item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: item.quantidade > 1 ? () => _diminuirQuantidade(item) : null,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.remove,
                size: 20,
                color: item.quantidade > 1 ? verde : Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${item.quantidade}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: () => _aumentarQuantidade(item),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.add, size: 20, color: verde),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumo() {
    final carrinho = widget.carrinho;
    final totalItens =
    carrinho.listagem.fold<int>(0, (soma, item) => soma + item.quantidade);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Itens ($totalItens)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  _formatarPreco(carrinho.valorTotal),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatarPreco(carrinho.valorTotal),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: verde,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: verde,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
               onPressed: _finalizarCompra,
                child: const Text(
                  'Finalizar compra',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _mostrarMensagemPix() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // só fecha pelo botão OK
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle, color: verde, size: 56),
        title: const Text('Pedido realizado!'),
        content: const Text(
          'Chave Pix enviada por email',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: verde)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    setState(() => widget.carrinho.limparCarrinho());
  }

  Future<void> _finalizarCompra() async {
  final itens = widget.carrinho.listagem;

  if (itens.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seu carrinho está vazio.')),
    );
    return;
  }

  // Confere todos os itens antes de alterar o estoque.
  for (final item in itens) {
    if (item.quantidade <= 0 ||
        item.quantidade > item.produto.quantidadeDisponivel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Confira a quantidade de ${item.produto.nome}. '
            'Estoque disponível: ${item.produto.quantidadeDisponivel}.',
          ),
        ),
      );
      return;
    }
  }

  setState(() {
    // Desconta do estoque a quantidade comprada.
    for (final item in itens) {
      item.produto.quantidadeDisponivel -= item.quantidade;
    }

    // Esvazia o carrinho depois da compra.
    itens.clear();
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Compra finalizada com sucesso!'),
    ),
  );

  // Exibe a mensagem do Pix antes de sair da tela.
  await _mostrarMensagemPix();

  if (!mounted) return;

  // Volta para a Home, que atualiza a lista.
  Navigator.pop(context);
}
}

