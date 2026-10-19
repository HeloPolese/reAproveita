import 'package:flutter/material.dart';
import 'controller/vendedorController.dart';
import 'views/cadastroVendedor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final vendedorController = VendedorController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reaproveita',
      home: CadastroVendedor(
        controller: vendedorController,
      ),
    );
  }
}