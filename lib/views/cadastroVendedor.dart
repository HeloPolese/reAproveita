import 'package:flutter/material.dart';
import '../controller/vendedorController.dart';

class CadastroVendedor extends StatefulWidget {
  final VendedorController controller;

  const CadastroVendedor({
    super.key,
    required this.controller,
  });

  @override
  State<CadastroVendedor> createState() => _CadastroVendedorState();
}

class _CadastroVendedorState extends State<CadastroVendedor> {
  final nomeController = TextEditingController();
  final pixController = TextEditingController();
  final enderecoController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();

  void cadastrar() {
    try {
      final vendedor = widget.controller.cadastrar(
        nome: nomeController.text,
        pix: pixController.text,
        endereco: enderecoController.text,
        email: emailController.text,
        telefone: telefoneController.text,
        senha: senhaController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${vendedor.nome} foi cadastrado na lista!'),
        ),
      );

      nomeController.clear();
      pixController.clear();
      enderecoController.clear();
      emailController.clear();
      telefoneController.clear();
      senhaController.clear();
    } catch (erro) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    pixController.dispose();
    enderecoController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de vendedor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome',
            ),
          ),
          TextField(
            controller: pixController,
            decoration: const InputDecoration(
              labelText: 'Chave PIX',
            ),
          ),
          TextField(
            controller: enderecoController,
            decoration: const InputDecoration(
              labelText: 'Endereço',
            ),
          ),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-mail',
            ),
          ),
          TextField(
            controller: telefoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefone',
            ),
          ),
          TextField(
            controller: senhaController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha',
              helperText: 'Use pelo menos 8 caracteres.',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: cadastrar,
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }
}