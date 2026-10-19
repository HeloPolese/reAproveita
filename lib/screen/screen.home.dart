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

  const HomePage({
    super.key,
    required this.produtos,
    required this.carrinho,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color verde = Color(0xFF027333);

  final TextEditingController _buscaController = TextEditingController();

  String _busca = '';
  Vendedor? _usuarioLogado;

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

    if (termo.isEmpty) return widget.produtos;

    return widget.produtos.where((produto) {
      return produto.nome.toLowerCase().contains(termo) ||
          produto.vendedor.nome.toLowerCase().contains(termo) ||
          produto.descricao.toLowerCase().contains(termo);
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
    final index = listagem.indexWhere(
      (item) => item.produto == produto,
    );

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
        widget.carrinho.adicionarProduto(
          ItemCarrinho(produto: produto),
        );
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
      MaterialPageRoute(
        builder: (_) => const CadastroPage(),
      ),
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
      MaterialPageRoute(
        builder: (_) => CadastroPage(vendedorAtual: usuario),
      ),
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
      MaterialPageRoute(
        builder: (_) => CadastroProdutoPage(vendedor: usuario),
      ),
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
        builder: (_) => CadastroProdutoPage(
          vendedor: usuario,
          produtoAtual: produto,
        ),
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

      widget.carrinho.listagem.removeWhere(
        (item) => item.quantidade <= 0,
      );
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
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
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
            tooltip: _usuarioLogado == null
                ? 'Criar conta'
                : 'Meu perfil',
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
          ? _buildSemResultados()
          : _buildLista(produtos),
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
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    _buscaController.clear();
                    setState(() => _busca = '');
                  },
                ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
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
            _busca.isEmpty
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
    final unidade = _formatarUnidade(produto.unidadeMedida);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Validade: ${produto.validade}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    semEstoque
                        ? 'Indisponível'
                        : 'Disponível: ${produto.quantidadeDisponivel} $unidade',
                    style: TextStyle(
                      fontSize: 12,
                      color: semEstoque ? Colors.red : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${_formatarPreco(produto.preco)} / $unidade',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: verde,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verde,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: semEstoque
                            ? null
                            : () => _adicionarAoCarrinho(produto),
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          size: 18,
                        ),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),

                  // Gerenciamento apenas dos produtos do usuário da sessão.
                  if (_meuProduto(produto)) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: () => _editarProduto(produto),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: verde,
                            size: 18,
                          ),
                          label: const Text(
                            'Editar',
                            style: TextStyle(color: verde),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _excluirProduto(produto),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                          label: const Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
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
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
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