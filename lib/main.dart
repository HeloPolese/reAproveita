import 'package:flutter/material.dart';
import 'controller/vendedorController.dart';
import 'views/cadastroVendedor.dart';

void main() {
  final vendedorController = VendedorController();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reaproveita',
      home: CadastroVendedor(
        controller: vendedorController,
      ),
    ),
  );
}