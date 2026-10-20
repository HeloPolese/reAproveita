import 'package:flutter/material.dart';
import 'package:reaproveita/models/carrinho.dart';
import 'package:reaproveita/models/itemCarrinho.dart';
import 'package:reaproveita/models/produto.dart';
import 'package:reaproveita/models/vendedor.dart';
import 'package:reaproveita/screen/screen.carrinho.dart';
import 'package:reaproveita/screen/screen.cadastro.dart';
import 'package:reaproveita/screen/screen.produto.dart';

class HomePage extends StatefulWidget {
  final List<Produto> produtos;
  final Carrinho carrinho;

  const HomePage({super.key, required this.produtos, required this.carrinho});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color verde = Color(0xFF027333);

  final TextEditingController _buscaController = TextEditingController();

  String _busca = '';
  Vendedor? _usuarioLogado;

  String _categoriaSelecionada = 'Todas';

  List<String> get _categorias {
    final categorias =
        widget.produtos
            .map((p) => p.categoria.trim())
            .where((categoria) => categoria.isNotEmpty && categoria != 'Todas')
            .toSet()
            .toList()
          ..sort();

    return ['Todas', ...categorias];
  }

  // Se a categoria desaparecer após uma edição ou exclusão,
  // volta a mostrar todas.
  String get _categoriaAtiva {
    return _categorias.contains(_categoriaSelecionada)
        ? _categoriaSelecionada
        : 'Todas';
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarUnidade(Object unidade) {
    switch (unidade.toString().split('.').last.toLowerCase()) {
      case 'unidade':
        return 'un';
      case 'quilo':
        return 'kg';
      case 'grama':
        return 'g';
      case 'litro':
        return 'L';
      case 'mililitro':
        return 'mL';
      default:
        return unidade.toString();
    }
  }

  List<Produto> get _produtosFiltrados {
    final termo = _busca.trim().toLowerCase();
    final categoria = _categoriaAtiva;

    return widget.produtos.where((produto) {
      final correspondeCategoria =
          categoria == 'Todas' || produto.categoria.trim() == categoria;

      final correspondeBusca =
          termo.isEmpty ||
          produto.nome.toLowerCase().contains(termo) ||
          produto.vendedor.nome.toLowerCase().contains(termo) ||
          produto.descricao.toLowerCase().contains(termo);

      return correspondeCategoria && correspondeBusca;
    }).toList();
  }

  int get _totalItensCarrinho {
    return widget.carrinho.listagem.fold<int>(
      0,
      (soma, item) => soma + item.quantidade,
    );
  }

  // Confere se o produto pertence ao vendedor desta sessão.
  bool _meuProduto(Produto produto) {
    return _usuarioLogado != null &&
        identical(produto.vendedor, _usuarioLogado);
  }

  void _mostrarMensagem(String texto, {SnackBarAction? acao}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          duration: const Duration(seconds: 3),
          action: acao,
        ),
      );
  }

  void _adicionarAoCarrinho(Produto produto) {
    if (produto.quantidadeDisponivel <= 0) return;

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

    if (mounted) setState(() {});
  }

  // Recebe o vendedor devolvido pela tela de cadastro.
  Future<void> _abrirCadastro() async {
    final usuario = await Navigator.push<Vendedor>(
      context,
      MaterialPageRoute(builder: (_) => const CadastroPage()),
    );

    if (!mounted || usuario == null) return;

    setState(() {
      _usuarioLogado = usuario;
    });

    _mostrarMensagem(
      'Olá, ${usuario.nome}! Use o + para cadastrar um produto.',
    );
  }

  Future<void> _editarPerfil() async {
    final usuario = _usuarioLogado;
    if (usuario == null) return;

    final atualizado = await Navigator.push<Vendedor>(
      context,
      MaterialPageRoute(builder: (_) => CadastroPage(vendedorAtual: usuario)),
    );

    if (!mounted || atualizado == null) return;

    setState(() {
      _usuarioLogado = atualizado;
    });
  }

  // Sem sessão: abre cadastro.
  // Com sessão: mostra editar perfil e sair.
  Future<void> _abrirConta() async {
    final usuario = _usuarioLogado;

    if (usuario == null) {
      await _abrirCadastro();
      return;
    }

    final acao = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (contextoMenu) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF2E857),
                child: Icon(Icons.person, color: verde),
              ),
              title: Text(usuario.nome),
              subtitle: Text(usuario.email),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: verde),
              title: const Text('Editar meus dados'),
              onTap: () => Navigator.pop(contextoMenu, 'editar'),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: verde),
              title: const Text('Sair da conta'),
              onTap: () => Navigator.pop(contextoMenu, 'sair'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (acao == 'editar') {
      await _editarPerfil();
    } else if (acao == 'sair') {
      setState(() {
        _usuarioLogado = null;
      });

      _mostrarMensagem('Você saiu da sessão.');
    }
  }

  Future<void> _cadastrarProduto() async {
    final usuario = _usuarioLogado;

    if (usuario == null) {
      _mostrarMensagem('Cadastre-se para adicionar produtos.');
      return;
    }

    final produto = await Navigator.push<Produto>(
      context,
      MaterialPageRoute(builder: (_) => CadastroProdutoPage(vendedor: usuario)),
    );

    if (!mounted || produto == null) return;

    setState(() {
      widget.produtos.add(produto);

      // Limpa a pesquisa para o produto novo aparecer na listagem.
      _busca = '';
      _buscaController.clear();
    });

    _mostrarMensagem('${produto.nome} cadastrado!');
  }

  Future<void> _editarProduto(Produto produto) async {
    final usuario = _usuarioLogado;

    if (usuario == null || !_meuProduto(produto)) return;

    final atualizado = await Navigator.push<Produto>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CadastroProdutoPage(vendedor: usuario, produtoAtual: produto),
      ),
    );

    if (!mounted || atualizado == null) return;

    setState(() {
      // Se o estoque foi reduzido, ajusta esse produto no carrinho.
      for (final item in widget.carrinho.listagem) {
        if (identical(item.produto, produto) &&
            item.quantidade > produto.quantidadeDisponivel) {
          item.quantidade = produto.quantidadeDisponivel;
        }
      }

      widget.carrinho.listagem.removeWhere((item) => item.quantidade <= 0);
    });

    _mostrarMensagem('Produto atualizado.');
  }

  Future<void> _excluirProduto(Produto produto) async {
    if (!_meuProduto(produto)) return;

    final estaNoCarrinho = widget.carrinho.listagem.any(
      (item) => identical(item.produto, produto),
    );

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text(
          'Deseja excluir "${produto.nome}"?'
          '${estaNoCarrinho ? '\nEle também será removido do carrinho.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contextoDialogo, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!mounted || confirmar != true || !_meuProduto(produto)) return;

    setState(() {
      widget.produtos.remove(produto);

      widget.carrinho.listagem.removeWhere(
        (item) => identical(item.produto, produto),
      );
    });

    _mostrarMensagem('Produto excluído.');
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

          // O ícone de pessoa continua aparecendo.
          IconButton(
            tooltip: _usuarioLogado == null ? 'Criar conta' : 'Meu perfil',
            onPressed: _abrirConta,
            icon: const Icon(Icons.person),
          ),

          // O + aparece ao lado apenas quando há um usuário conectado.
          if (_usuarioLogado != null)
            IconButton(
              tooltip: 'Cadastrar produto',
              onPressed: _cadastrarProduto,
              icon: const Icon(Icons.add),
            ),

          const SizedBox(width: 4),
        ],
      ),
      body: produtos.isEmpty
          ? Column(
              children: [
                _buildFiltroCategoria(),
                Expanded(child: _buildSemResultados()),
              ],
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildBannerDestaque()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      'Categorias',
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildFiltroCategoria()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nossos produtos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF24452B),
                          ),
                        ),
                        Text(
                          '${produtos.length} ${produtos.length == 1 ? 'produto' : 'produtos'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final largura = constraints.crossAxisExtent;
                      final colunas = largura >= 700 ? 4 : largura >= 500 ? 3 : 2;
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: colunas,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: largura < 370 ? 0.53 : 0.59,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildProdutoGrade(produtos[index]),
                          childCount: produtos.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBannerDestaque() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 14, 12, 4),
      height: 158,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF075C2B), Color(0xFF48A34A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -18,
            child: Icon(
              Icons.eco,
              size: 150,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Do produtor para você',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                const SizedBox(
                  width: 245,
                  child: Text(
                    'Encontre alimentos fresquinhos e valorize os produtores locais.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _categoriaSelecionada = 'Todas';
                      _busca = '';
                      _buscaController.clear();
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF2E857),
                    foregroundColor: const Color(0xFF174522),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Explorar produtos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          contentPadding: const EdgeInsets.only(top: 5),
        ),
      ),
    );
  }

  String _imagemCategoria(String categoria) {
    final nome = categoria.toLowerCase();

    // Imagens remotas ilustrativas. Para funcionamento offline,
    // substitua esses endereços por imagens locais em assets.
    if (nome == 'todas') {
      return 'https://images.openai.com/static-rsc-4/i5zoprJBgPEwhYDCnusnMcQzgoSUTvZIq90L4mAXwf6vyDH_qM4Q3KNP7AvUhqXDTL81vNUD6LlNA0e7IPfcW8zH63Wl_3tnCHk9YSyYPaixO5oHCuE588kjUqnsYvc_cmzg3hKfrzfF_bKPD_YNoj_GciRlVeJo1UkDabWlIA7hACjme3_T96y9xGnUjjPx?purpose=fullsize';
    }
    if (nome.contains('frut')) {
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrCFhtZcP9L3wZWkkSZC4yJ-67OYgceegkE60tgHJoMg&s=10';
    }
    if (nome.contains('legum')) {
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR0W2h1FgdrOHLUqIJGRIH8uqTWjXM3MJDayLHMG_JFlg&s=10';
    }
    if (nome.contains('lat')) {
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQYL-p59jkvXoNPq5wT3d8ZbdoGxvdgGyHKFtdObCPZNg&s=10';
    }
    if (nome.contains('pada')) {
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS55RrL98vbCrguqb1F-tyYqUndFPYMH9h8tTMgpSk3vA&s=10';
    }
    if (nome.contains('carn')) {
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbdVKAwseAdTDoo-dDjiL8b4mZqbCbajRbT9vYQ3HnSQ&s=10';
    }
    if (nome.contains('bebidas')) {
      return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSSxuXz6gQHTFflVexqI6lzYsrrHpZ-kliQmUC4Kxb2bA&s=10';
    }

    return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=240&h=240&fit=crop';
  }

  Widget _buildFiltroCategoria() {
    final categorias = _categorias;

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final selecionada = categoria == _categoriaAtiva;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _categoriaSelecionada = categoria;
              });
            },
            child: SizedBox(
              width: 76,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selecionada ? verde : Colors.grey.shade300,
                        width: selecionada ? 3 : 1,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        _imagemCategoria(categoria),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE8F5E9),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.eco_outlined,
                            color: verde,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    categoria,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: selecionada ? verde : Colors.black87,
                      fontWeight:
                          selecionada ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.58,
      ),
      itemCount: produtos.length,
      itemBuilder: (context, index) => _buildProdutoGrade(produtos[index]),
    );
  }

  Widget _buildProdutoGrade(Produto produto) {
    final semEstoque = produto.quantidadeDisponivel <= 0;
    final unidade = _formatarUnidade(produto.unidadeMedida);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1.5,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImagem(produto.imagem),
                if (semEstoque)
                  Container(
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: const Text(
                      'Indisponível',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_meuProduto(produto))
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (acao) {
                          if (acao == 'editar') {
                            _editarProduto(produto);
                          } else if (acao == 'excluir') {
                            _excluirProduto(produto);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'editar',
                            child: Text('Editar'),
                          ),
                          PopupMenuItem(
                            value: 'excluir',
                            child: Text('Excluir'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (produto.descricao.trim().isNotEmpty)
                    Text(
                      produto.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 3),
                  Text(
                    'Validade: ${produto.validade}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  Text(
                    '${_formatarPreco(produto.preco)} / $unidade',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: verde,
                    ),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verde,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      onPressed: semEstoque
                          ? null
                          : () => _adicionarAoCarrinho(produto),
                      icon: const Icon(Icons.add_shopping_cart, size: 15),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Adicionar'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    semEstoque
                        ? 'Sem estoque'
                        : '${produto.quantidadeDisponivel} $unidade disponíveis',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: semEstoque ? Colors.red : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
