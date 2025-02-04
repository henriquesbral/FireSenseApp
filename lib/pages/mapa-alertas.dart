// ignore_for_file: deprecated_member_use
import 'package:aps/model/app-bar-rotas.dart';
import 'package:aps/model/usuario.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:aps/model/alerta_model.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MapaAlertas(),
  ));
}

class MapaAlertas extends StatefulWidget {
  @override
  _MapaAlertasState createState() => _MapaAlertasState();
}

class _MapaAlertasState extends State<MapaAlertas> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  static const LatLng _initialPosition = LatLng(-23.55052, -46.633308); // São Paulo

  @override
  void initState() {
    super.initState();
    _fetchAlertas();
  }

  Future<void> _fetchAlertas() async {
    final response = await http.get(Uri.parse('https://api.exemplo.com/alertas'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      List<Alerta> alertas = jsonList.map((json) => Alerta.fromJson(json)).toList();
      _addMarkers(alertas);
    } else {
      throw Exception('Erro ao carregar alertas');
    }
  }

  void _addMarkers(List<Alerta> alertas) {
    Set<Marker> markers = {};

    for (var alerta in alertas) {
      markers.add(
        Marker(
          markerId: MarkerId('${alerta.latitude}${alerta.longitude}'),
          position: LatLng(alerta.latitude, alerta.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              alerta.ativo ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: alerta.cidade,
            snippet: alerta.bairro,
            onTap: () => _mostrarDetalhes(alerta),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _mostrarDetalhes(Alerta alerta) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detalhes do Alerta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("🔴 Status: ${alerta.statusAlerta}"),
              Text("🏙 Cidade: ${alerta.cidade}"),
              Text("📍 Bairro: ${alerta.bairro}"),
              Text("🌍 Latitude: ${alerta.latitude}"),
              Text("🌍 Longitude: ${alerta.longitude}"),
              Text("🟢 Ativo: ${alerta.ativo ? 'Sim' : 'Não'}"),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Fechar"),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(usuario: usuarioAtual), // Adicionando a MenuAppBar
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 12),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            mapType: MapType.hybrid,
            markers: _markers,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.map),
            ),
          ),
        ],
      ),
    );
  }
}
