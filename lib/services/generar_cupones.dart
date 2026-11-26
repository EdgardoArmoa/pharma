import 'dart:convert'; // Necesario para jsonEncode

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<bool> asignarCuponParaCliente(int clienteId, int cuponId) async {
  final response = await http.post(
    Uri.parse('https://farma.staweno.com/cupones/asignar_cupon_cliente.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'cliente_id': clienteId, 'cupon_id': cuponId}),
  );

  debugPrint('ASIGNAR CUPON STATUS: ${response.statusCode}');
  debugPrint('ASIGNAR CUPON BODY: ${response.body}');

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    return decoded is Map && decoded['success'] == true;
  }

  return false;
}
