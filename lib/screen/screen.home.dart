import 'package:flutter/material.dart';
import 'package:reaproveita/models/carrinho.dart';
import 'package:reaproveita/models/itemCarrinho.dart';
import 'package:reaproveita/models/produto.dart';
import 'package:reaproveita/screen/screen.carrinho.dart';
import 'package:reaproveita/screen/screen.cadastro.dart';

class HomePage extends StatefulWidget {
  final List<Produto> produtos;
  final Carrinho carrinho;

  const HomePage({
    super.key,
    required this.produtos,
    required this.carrinho,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color verde = Color(0xFF2E7D32);

  final TextEditingController _buscaController = TextEditingController();
  String _busca = '';

  String _categoriaSelecionada = 'Todas';

List<String> get _categorias {
  final categorias = widget.produtos
      .map((p) => p.categoria.trim())
      .where((categoria) => categoria.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  return ['Todas', ...categorias];
}

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Lista filtrada pelo texto da pesquisa (nome, vendedor ou descrição)
List<Produto> get _produtosFiltrados {
  final termo = _busca.trim().toLowerCase();

  return widget.produtos.where((p) {
    final correspondeCategoria =
        _categoriaSelecionada == 'Todas' ||
        p.categoria.toLowerCase().trim() == _categoriaSelecionada;

    final correspondeTexto = termo.isEmpty ||
        p.nome.toLowerCase().contains(termo) ||
        p.vendedor.nome.toLowerCase().contains(termo) ||
        p.descricao.toLowerCase().contains(termo);

    return correspondeCategoria && correspondeTexto;
  }).toList();
}

  // Soma das quantidades de todos os itens do carrinho (para o selo do ícone)
  int get _totalItensCarrinho {
    return widget.carrinho.listagem
        .fold<int>(0, (soma, item) => soma + item.quantidade);
  }

  void _mostrarMensagem(String texto, {SnackBarAction? acao}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          duration: const Duration(seconds: 2),
          action: acao,
        ),
      );
  }

  // Cria um ItemCarrinho ao adicionar. Se o produto já está no carrinho,
  // apenas aumenta a quantidade (respeitando o estoque).
  void _adicionarAoCarrinho(Produto produto) {
    final listagem = widget.carrinho.listagem;
    final index = listagem.indexWhere((item) => item.produto == produto);

    if (index >= 0) {
      final item = listagem[index];

      if (item.quantidade >= produto.quantidadeDisponivel) {
        _mostrarMensagem(
          'Quantidade máxima disponível: ${produto.quantidadeDisponivel}',
        );
        return;
      }

      setState(() => item.quantidade++);
    } else {
      setState(() {
        widget.carrinho.adicionarProduto(ItemCarrinho(produto: produto));
      });
    }

    _mostrarMensagem(
      '${produto.nome} adicionado ao carrinho',
      acao: SnackBarAction(
        label: 'VER CARRINHO',
        textColor: Colors.white,
        onPressed: _abrirCarrinho,
      ),
    );
  }

  Future<void> _abrirCarrinho() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarrinhoPage(carrinho: widget.carrinho),
      ),
    );

    // Ao voltar, atualiza o selo do carrinho (itens podem ter mudado)
    if (mounted) setState(() {});
  }

  void _abrirLogin() {
    // TODO: quando existir a tela de login, abri-la aqui
    // e deixar o cadastro como link dentro dela.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produtos = _produtosFiltrados;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        titleSpacing: 12,
        title: _buildCampoBusca(),
        actions: [
          IconButton(
            tooltip: 'Carrinho',
            onPressed: _abrirCarrinho,
            icon: Badge(
              label: Text('$_totalItensCarrinho'),
              isLabelVisible: _totalItensCarrinho > 0,
              child: const Icon(Icons.shopping_cart),
            ),
          ),
          IconButton(
            tooltip: 'Entrar',
            onPressed: _abrirLogin,
            icon: const Icon(Icons.person),
          ),
          const SizedBox(width: 4),
        ],
      ),
body: Column(
  children: [
    _buildFiltroCategoria(),
    Expanded(
      child: produtos.isEmpty
          ? _buildSemResultados()
          : _buildLista(produtos),
    ),
  ],
),    );
  }

  Widget _buildCampoBusca() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _buscaController,
        onChanged: (valor) => setState(() => _busca = valor),
        style: const TextStyle(color: Colors.black87, fontSize: 15),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar produtos',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _busca.isEmpty
              ? null
              : IconButton(
            icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
            onPressed: () {
              _buscaController.clear();
              setState(() => _busca = '');
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFiltroCategoria() {
  final categorias = _categorias;

  return SizedBox(
    height: 60,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      itemCount: categorias.length,
      separatorBuilder: (_, __) =>
          const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final categoria = categorias[index];
        final selecionada =
            categoria == _categoriaSelecionada;

        return ChoiceChip(
          label: Text(categoria),
          selected: selecionada,
          selectedColor: const Color(0xFF2E7D32)
              .withOpacity(0.15),
          labelStyle: TextStyle(
            color: selecionada
                ? const Color(0xFF2E7D32)
                : Colors.black87,
            fontWeight: selecionada
                ? FontWeight.bold
                : FontWeight.normal,
          ),
          onSelected: (_) {
            setState(() {
              _categoriaSelecionada = categoria;
            });
          },
        );
      },
    ),
  );
}


  Widget _buildSemResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
          _busca.isEmpty &&
                  _categoriaSelecionada == 'Todas'
              ? 'Nenhum produto disponível'
              : 'Nenhum produto encontrado',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(List<Produto> produtos) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: produtos.length,
      itemBuilder: (context, index) => _buildProduto(produtos[index]),
    );
  }

  Widget _buildProduto(Produto produto) {
    final semEstoque = produto.quantidadeDisponivel <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 90,
                height: 90,
                child: _buildImagem(produto.imagem),
              ),
            ),
            const SizedBox(width: 12),
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
                    'Validade: ${produto.validade}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    semEstoque
                        ? 'Indisponível'
                        : 'Disponível: ${produto.quantidadeDisponivel} ${produto.unidadeMedida}',
                    style: TextStyle(
                      fontSize: 12,
                      color: semEstoque ? Colors.red : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${_formatarPreco(produto.preco)} / ${produto.unidadeMedida}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: verde,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verde,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed:
                        semEstoque ? null : () => _adicionarAoCarrinho(produto),
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                ],
              ),
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
}