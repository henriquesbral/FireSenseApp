// ignore_for_file: deprecated_member_use
import 'package:aps/model/app-bar-rotas.dart';
import 'package:aps/model/usuario.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aps/services/storage_service.dart';
import 'package:aps/model/alerta_model.dart'; // Importação da classe Alerta

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
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final LatLng _initialPosition = LatLng(-23.5505, -46.6333); // São Paulo, Brasil

  @override
  void initState() {
    super.initState();
    _fetchAlertas();
  }

  Future<void> _fetchAlertas() async {
    const String apiUrl =
        'https://firesenseapi-gdg2fze3ath6gpa2.brazilsouth-01.azurewebsites.net/api/BuscarAlertas';

    String? token = await StorageService.getToken();
    if (token == null) {
      _showSnackBar('Usuário não autenticado. Faça login novamente.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        List<Alerta> alertas = jsonList.map((json) => Alerta.fromJson(json)).toList();
        _addMarkers(alertas);
      } else {
        _showSnackBar('Erro ao carregar alertas.');
      }
    } catch (e) {
      _showSnackBar('Falha na conexão com o servidor.');
    }
  }

  void _addMarkers(List<Alerta> alertas) {
    Set<Marker> markers = {};

    for (var alerta in alertas) {
      markers.add(
        Marker(
          markerId: MarkerId(alerta.codAlerta.toString()), // Usa o CodAlerta como ID único
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
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  void _mostrarDetalhes(Alerta alerta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detalhes do Alerta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🆔 Código: ${alerta.codAlerta}"),
            Text("🔴 Status: ${alerta.statusAlerta}"),
            Text("🏙 Cidade: ${alerta.cidade}"),
            Text("📍 Bairro: ${alerta.bairro}"),
            Text("🌍 Latitude: ${alerta.latitude}"),
            Text("🌍 Longitude: ${alerta.longitude}"),
            Text("🟢 Ativo: ${alerta.ativo ? 'Sim' : 'Não'}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fechar"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(usuario: usuarioAtual),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 5,
            ),
            mapType: MapType.hybrid,
            markers: _markers,
          ),
          Positioned(
            bottom: 80,
            left: 20,
            child: FloatingActionButton.extended(
              onPressed: _fetchAlertas,
              icon: Icon(Icons.refresh),
              label: Text("Atualizar Alertas"),
            ),
          ),
        ],
      ),
    );
  }
}
