import 'package:flutter/material.dart';

// Para testar este arquivo sem alterar seu main.dart:
// flutter run -d chrome -t lib/screen/cadastro_usuario_screen.dart
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Reaproveita | Cadastro',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF027333),
      ).copyWith(
        primary: const Color(0xFF027333),
        secondary: const Color(0xFF63BF21),
        tertiary: const Color(0xFF66A638),
        surface: const Color(0xFFF2F2F2),
      ),
      scaffoldBackgroundColor: const Color(0xFFF2F2F2),
    ),
    home: const CadastroUsuarioScreen(),
  ));
}

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  // Paleta enviada: #027333, #63BF21, #66A638, #F2E857 e #F2F2F2.
  static const verde = Color(0xFF027333);
  static const verdeEscuro = Color(0xFF027333);
  final formulario = GlobalKey<FormState>();
  final nome = TextEditingController();
  final telefone = TextEditingController();
  final email = TextEditingController();
  final pix = TextEditingController();
  final endereco = TextEditingController();
  final senha = TextEditingController();
  final confirmarSenha = TextEditingController();
  bool ocultarSenha = true;
  bool ocultarConfirmacao = true;

  // Protótipo: dados pessoais apenas na memória desta tela.
  // A senha é validada, mas não é salva nesta lista.
  // Para criar contas e fazer login reais, integrar um serviço de autenticação.
  final List<Map<String, String>> usuarios = [];

  @override
  void dispose() {
    for (final campo in [nome, telefone, email, pix, endereco, senha, confirmarSenha]) {
      campo.dispose();
    }
    super.dispose();
  }

  String? obrigatorio(String? valor) {
    return valor == null || valor.trim().isEmpty
        ? 'Preencha este campo.'
        : null;
  }

  Future<void> cadastrar() async {
    if (!formulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final nomeCadastrado = nome.text.trim();
    setState(() {
      usuarios.add({
        'nome': nomeCadastrado,
        'telefone': telefone.text.trim(),
        'email': email.text.trim().toLowerCase(),
        'pix': pix.text.trim(),
        'endereco': endereco.text.trim(),
      });
    });

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, color: verde, size: 44),
        title: const Text('Dados cadastrados!'),
        content: Text(
          '$nomeCadastrado foi adicionado à lista desta sessão.\n\n'
          'Este protótipo ainda não cria uma conta de acesso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    formulario.currentState!.reset();
    for (final campo in [nome, telefone, email, pix, endereco, senha, confirmarSenha]) {
      campo.clear();
    }
    setState(() {
      ocultarSenha = true;
      ocultarConfirmacao = true;
    });
  }

  // Mesmo estilo para todos os campos, sem repetir a decoração.
  Widget campo({
    required String titulo,
    required String dica,
    required TextEditingController controller,
    required IconData icone,
    TextInputType teclado = TextInputType.text,
    String? Function(String?)? validar,
    bool ocultar = false,
    Widget? botao,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(
          color: verdeEscuro, fontSize: 14, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: teclado,
          obscureText: ocultar,
          validator: validar ?? obrigatorio,
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: const TextStyle(color: Color(0xFF758276), fontSize: 14),
            prefixIcon: Icon(icone, color: verde, size: 20),
            suffixIcon: botao,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0x8066A638)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0x8066A638)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: verde, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Duas colunas no computador e uma coluna nas telas menores.
  Widget colunas(List<Widget> campos) {
    return LayoutBuilder(builder: (context, limites) {
      final largura = limites.maxWidth >= 640
          ? (limites.maxWidth - 24) / 2
          : limites.maxWidth;
      return Wrap(
        spacing: 24,
        runSpacing: 22,
        children: campos.map((item) => SizedBox(width: largura, child: item)).toList(),
      );
    });
  }

  Widget secao(String titulo, String descricao, Widget conteudo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(
            color: verde, fontSize: 23, fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 7),
          Container(width: 48, height: 3, color: const Color(0xFF63BF21)),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4066A638)),
              boxShadow: const [BoxShadow(
                color: Color(0x0C027333), blurRadius: 16, offset: Offset(0, 5),
              )],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(descricao, style: const TextStyle(
                  color: Color(0xFF627064), height: 1.5,
                )),
                const SizedBox(height: 22),
                conteudo,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 76,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFF2E857),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(9),
                child: Icon(Icons.eco_outlined, color: verde, size: 31),
              ),
            ),
            SizedBox(width: 10),
            Text('Reaproveita', style: TextStyle(
              color: verdeEscuro, fontWeight: FontWeight.bold, fontSize: 23,
            )),
          ],
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0x4066A638)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Form(
                key: formulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FAÇA PARTE DA COMUNIDADE', style: TextStyle(
                      color: verde, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, fontSize: 11,
                    )),
                    const SizedBox(height: 10),
                    const Text('Seu cadastro começa aqui.', style: TextStyle(
                      color: verdeEscuro, fontSize: 32, fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 10),
                    const Text(
                      'Preencha seus dados para participar do Reaproveita.',
                      style: TextStyle(color: Color(0xFF627064), fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    secao('Informações pessoais', 'Conte um pouco sobre você. Todos os campos são obrigatórios.',
                      colunas([
                        campo(titulo: 'Nome completo', dica: 'Digite seu nome',
                          controller: nome, icone: Icons.person_outline),
                        campo(titulo: 'Telefone', dica: '(27) 99999-9999',
                          controller: telefone, icone: Icons.phone_outlined,
                          teclado: TextInputType.phone, validar: (valor) {
                            final vazio = obrigatorio(valor);
                            if (vazio != null) return vazio;
                            final digitos = valor!.replaceAll(RegExp(r'\D'), '');
                            return digitos.length == 10 || digitos.length == 11
                                ? null : 'Informe o telefone com DDD (10 ou 11 dígitos).';
                          }),
                        campo(titulo: 'E-mail', dica: 'voce@exemplo.com',
                          controller: email, icone: Icons.mail_outline,
                          teclado: TextInputType.emailAddress, validar: (valor) {
                            final texto = valor?.trim() ?? '';
                            if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(texto)) {
                              return 'Digite um e-mail válido.';
                            }
                            if (usuarios.any((usuario) => usuario['email'] == texto.toLowerCase())) {
                              return 'Este e-mail já foi cadastrado nesta sessão.';
                            }
                            return null;
                          }),
                        campo(titulo: 'Chave PIX', dica: 'CPF, e-mail, telefone ou chave aleatória',
                          controller: pix, icone: Icons.payments_outlined),
                      ]),
                    ),
                    secao('Endereço', 'Informe o endereço que deseja usar no cadastro.',
                      campo(titulo: 'Endereço completo', dica: 'Rua, número, bairro, cidade e estado',
                        controller: endereco, icone: Icons.location_on_outlined,
                        teclado: TextInputType.streetAddress),
                    ),
                    secao('Senha de acesso', 'Escolha uma senha com pelo menos 8 caracteres.',
                      colunas([
                        campo(titulo: 'Senha', dica: 'Digite sua senha',
                          controller: senha, icone: Icons.lock_outline,
                          ocultar: ocultarSenha, validar: (valor) {
                            if (valor == null || valor.trim().isEmpty || valor.length < 8) {
                              return 'Use pelo menos 8 caracteres.';
                            }
                            return null;
                          },
                          botao: IconButton(
                            tooltip: ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                            onPressed: () => setState(() => ocultarSenha = !ocultarSenha),
                            icon: Icon(ocultarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          )),
                        campo(titulo: 'Confirmar senha', dica: 'Digite a senha novamente',
                          controller: confirmarSenha, icone: Icons.lock_outline,
                          ocultar: ocultarConfirmacao,
                          validar: (valor) => valor == null || valor.isEmpty
                              ? 'Confirme sua senha.'
                              : valor != senha.text ? 'As senhas precisam ser iguais.' : null,
                          botao: IconButton(
                            tooltip: ocultarConfirmacao ? 'Mostrar confirmação' : 'Ocultar confirmação',
                            onPressed: () => setState(() => ocultarConfirmacao = !ocultarConfirmacao),
                            icon: Icon(ocultarConfirmacao ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          )),
                      ]),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 300,
                        child: ElevatedButton.icon(
                          onPressed: cadastrar,
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                          label: const Text('Cadastrar usuário'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: verde,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 56),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Demonstração: os dados ficam apenas nesta sessão; '
                      'o login ainda não está conectado.',
                      style: TextStyle(color: Color(0xFF627064), fontSize: 12, height: 1.5),
                    ),
                    if (usuarios.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Usuários cadastrados nesta sessão: ${usuarios.length}',
                        style: const TextStyle(color: verde, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
