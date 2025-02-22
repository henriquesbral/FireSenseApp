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

  final Map<String, Color> _alertColors = {
    'Preventivo': Colors.green,
    'Atenção': Colors.yellow,
    'Emergência': Colors.orange,
    'Crítico': Colors.red,
  };

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

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_initialPosition, 5),
        );

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
      double lat = double.tryParse(alerta.latitude) ?? 0.0;
      double lng = double.tryParse(alerta.longitude) ?? 0.0;

      markers.add(
        Marker(
          markerId: MarkerId(alerta.codAlerta.toString()),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              alerta.ativo ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed),
          onTap: () => _mostrarDetalhes(alerta, lat, lng),
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  void _mostrarDetalhes(Alerta alerta, double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
    );

    Color alertColor = _alertColors[alerta.statusAlerta] ?? Colors.blueGrey;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: alertColor,
        title: Text("Detalhes do Alerta", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🆔 Código: ${alerta.codAlerta}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text("🔴 Status: ${alerta.statusAlerta}", style: TextStyle(color: Colors.white)),
            Text("🏙 Cidade: ${alerta.cidade}", style: TextStyle(color: Colors.white)),
            Text("📍 Bairro: ${alerta.bairro}", style: TextStyle(color: Colors.white)),
            Text("🌍 Latitude: ${alerta.latitude}", style: TextStyle(color: Colors.white)),
            Text("🌍 Longitude: ${alerta.longitude}", style: TextStyle(color: Colors.white)),
            Text("🟢 Ativo: ${alerta.ativo ? 'Sim' : 'Não'}", style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fechar", style: TextStyle(color: Colors.white)),
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
