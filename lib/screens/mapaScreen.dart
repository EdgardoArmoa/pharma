import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapaScreen extends StatefulWidget {
  final String direccion;
  final Function(Map<String, dynamic>) onUbicacionConfirmada;

  const MapaScreen({
    required this.direccion,
    required this.onUbicacionConfirmada,
    super.key,
  });

  @override
  MapaScreenState createState() => MapaScreenState();
}

class MapaScreenState extends State<MapaScreen> {
  double latitud = -25.2637; // Coordenadas iniciales predeterminadas
  double longitud = -57.5759; // Coordenadas iniciales predeterminadas

  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _obtenerCoordenadas(widget.direccion);
  }

  Future<void> _obtenerCoordenadas(String direccion) async {
    if (direccion.isEmpty || !direccion.contains(',')) {
      debugPrint(
        'Error: La dirección debe incluir ciudad y calle separadas por una coma.',
      );
      setState(() {
        latitud = -25.2637;
        longitud = -57.5759;
      });
      return;
    }

    try {
      final queryCodificada = Uri.encodeComponent(direccion);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$queryCodificada&format=json&limit=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'farmacia_app/1.0 (armoanet@gmail.com)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        if (data.isNotEmpty) {
          final nuevaLatitud = double.parse(data[0]['lat']);
          final nuevaLongitud = double.parse(data[0]['lon']);

          setState(() {
            latitud = nuevaLatitud;
            longitud = nuevaLongitud;
          });

          _mapController.move(LatLng(nuevaLatitud, nuevaLongitud), 17);
        } else {
          debugPrint('No se encontraron coordenadas para la dirección.');
        }
      } else {
        throw Exception('Error al obtener coordenadas: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        latitud = -25.2637;
        longitud = -57.5759;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicar en Mapa')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(latitud, longitud),
          zoom: 16,
          onTap: (tapPosition, point) {
            setState(() {
              latitud = point.latitude;
              longitud = point.longitude;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.ejemplo.farmacia_app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitud, longitud),
                builder:
                    (ctx) => const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Confirmar'),
        icon: const Icon(Icons.check),
        onPressed: () {
          final partesDireccion = widget.direccion.split(',');
          if (partesDireccion.length >= 2) {
            widget.onUbicacionConfirmada({
              'ciudad': partesDireccion[0].trim(),
              'calle': partesDireccion[1].trim(),
              'latitud': latitud,
              'longitud': longitud,
            });
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'La dirección debe incluir ciudad y calle separadas por una coma.',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
