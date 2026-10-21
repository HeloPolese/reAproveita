
import 'package:flutter/material.dart';
import 'package:reaproveita/models/carrinho.dart';
import 'package:reaproveita/models/itemCarrinho.dart';
import 'package:reaproveita/models/produto.dart';
import 'package:reaproveita/models/vendedor.dart';
import 'package:reaproveita/screen/screen.carrinho.dart';

String categoriaSelecionada = 'Todas';

final List<String> categorias = [
  'Todas',
  'Frutas',
  'Legumes',
  'Padaria',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color verde = Color(0xFF2E7D32);

  final CarrinhoPage carrinho = CarrinhoPage(carrinho: []);

  final TextEditingController pesquisaController =
      TextEditingController();

  late final Vendedor vendedor;
  late final List<Produto> produtos;

  String pesquisa = '';

  @override
  void initState() {
    super.initState();

    vendedor = Vendedor(
      nome: 'Mercado Reaproveita',
      pix: 'reaproveita@email.com',
      endereco: 'Centro',
      email: 'reaproveita@email.com',
      telefone: '21999999999',
      senha: '',
    );

    produtos = [
      Produto(
        nome: 'Banana',
        categoria: 'Frutas',
        unidadeMedida: 'kg',
        validade: '30/10/2026',
        fabricacao: '19/10/2026',
        preco: 3.50,
        quantidadeDisponivel: 20,
        descricao: 'Bananas frescas para consumo.',
        imagem: '',
        vendedor: vendedor,
      ),
      Produto(
        nome: 'Maçã',
        categoria: 'Frutas',
        unidadeMedida: 'kg',
        validade: '05/11/2026',
        fabricacao: '18/10/2026',
        preco: 5.90,
        quantidadeDisponivel: 15,
        descricao: 'Maçãs selecionadas.',
        imagem: '',
        vendedor: vendedor,
      ),
      Produto(
        nome: 'Pão artesanal',
        categoria: 'Frutas',
        unidadeMedida: 'unidade',
        validade: '21/10/2026',
        fabricacao: '19/10/2026',
        preco: 4.00,
        quantidadeDisponivel: 10,
        descricao: 'Pão artesanal feito no dia.',
        imagem: '',
        vendedor: vendedor,
      ),
    ];
  }

  List<Produto> get produtosFiltrados {
  return produtos.where((produto) {
    final correspondePesquisa = produto.nome
        .toLowerCase()
        .contains(pesquisa.trim().toLowerCase());

    final correspondeCategoria =
        categoriaSelecionada == 'Todas' ||
        produto.categoria == categoriaSelecionada;

    return correspondePesquisa && correspondeCategoria;
  }).toList();
}

  String formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void adicionarAoCarrinho(Produto produto) {
    if (produto.quantidadeDisponivel <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto indisponível.'),
        ),
      );
      return;
    }

    final index = carrinho.listagem.indexWhere(
      (item) => identical(item.produto, produto),
    );

    if (index >= 0) {
      final item = carrinho.listagem[index];

      if (item.quantidade >= produto.quantidadeDisponivel) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Quantidade máxima disponível atingida.',
            ),
          ),
        );
        return;
      }

      item.quantidade++;
    } else {
      carrinho.adicionarProduto(
        ItemCarrinho(produto: produto),
      );
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${produto.nome} adicionado ao carrinho!',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void abrirLoginFuturamente() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A página de login será implementada em breve.',
        ),
      ),
    );
  }

  Future<void> abrirCarrinho() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarrinhoPage(carrinho: carrinho),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lista = produtosFiltrados;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // APPBAR
      appBar: AppBar(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        titleSpacing: 12,

        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.eco,
                  size: 36,
                  color: Colors.white,
                );
              },
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Reaproveita',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
          ],
        ),

        // ÍCONES DO CARRINHO E DO UTILIZADOR
        actions: [
          IconButton(
            tooltip: 'Meu carrinho',
            onPressed: abrirCarrinho,
            icon: Badge(
              label: Text('${carrinho.totalItens}'),
              isLabelVisible: carrinho.totalItens > 0,
              child: const Icon(
                Icons.shopping_cart_outlined,
              ),
            ),
          ),

          IconButton(
            tooltip: 'Login',
            onPressed: abrirLoginFuturamente,
            icon: const Icon(
              Icons.person_outline,
            ),
          ),
        ],
      ),

      // CONTEÚDO DA HOME
      body: Column(
        children: [
          // CAMPO DE PESQUISA
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: pesquisaController,
              onChanged: (valor) {
                setState(() {
                  pesquisa = valor;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar produtos...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: verde,
                ),
                suffixIcon: pesquisa.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          pesquisaController.clear();

                          setState(() {
                            pesquisa = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // TÍTULO DA LISTAGEM
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Produtos disponíveis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // LISTAGEM DE PRODUTOS
          Expanded(
            child: lista.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum produto encontrado.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      return _buildProduto(lista[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // CARTÃO DO PRODUTO
  Widget _buildProduto(Produto produto) {
    return Card(
      color: Colors.white,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEM
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: produto.imagem.isEmpty
                  ? Container(
                      color: Colors.green[50],
                      child: const Icon(
                        Icons.eco,
                        size: 64,
                        color: verde,
                      ),
                    )
                  : _buildImagem(produto.imagem),
            ),
          ),

          // INFORMAÇÕES DO PRODUTO
          Padding(
            padding: const EdgeInsets.fromLTRB(
              10,
              8,
              10,
              10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Por ${produto.vendedor.nome}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${formatarPreco(produto.preco)} / '
                  '${produto.unidadeMedida}',
                  style: const TextStyle(
                    color: verde,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // BOTÃO ADICIONAR AO CARRINHO
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => adicionarAoCarrinho(produto),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      size: 18,
                    ),
                    label: const Text('Adicionar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TRATAMENTO DAS IMAGENS
  Widget _buildImagem(String caminho) {
    final placeholder = Container(
      color: Colors.green[50],
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: verde,
      ),
    );

    if (caminho.startsWith('http')) {
      return Image.network(
        caminho,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return Image.asset(
      caminho,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
