// ignore_for_file: deprecated_member_use
import 'package:Fire_Sense/model/app-bar-rotas.dart';
import 'package:Fire_Sense/model/usuario.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Fire_Sense/services/storage_service.dart';
import 'package:Fire_Sense/model/alerta_model.dart'; // Importação da classe Alerta

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
  LatLng _initialPosition = LatLng(-23.5505, -46.6333); // Posição padrão de São Paulo

  final Map<String, Color> _alertColors = {
    'Preventivo': Colors.green,
    'Atenção': Colors.yellow,
    'Emergência': Colors.orange,
    'Crítico': Colors.red,
  };

  List<Alerta> _alertas = [];

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
        _alertas = jsonList.map((json) => Alerta.fromJson(json)).toList();

        if (_alertas.isNotEmpty) {
          double lat = double.tryParse(_alertas.first.latitude) ?? -23.5505;
          double lng = double.tryParse(_alertas.first.longitude) ?? -46.6333;
          setState(() {
            _initialPosition = LatLng(lat, lng);
          });
        }

        _addMarkers(_alertas);
        _mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition));
      } else {
        _showSnackBar('Erro ao carregar alertas.');
      }
    } catch (e) {
      _showSnackBar('Falha na conexão com o servidor.');
    }
  }

  // Retorna o valor de hue do marcador conforme o status do alerta.
  double _getMarkerHue(List<Alerta> alerts) {
    // Se existir pelo menos um alerta com status "Crítico", retorna hueRed.
    if (alerts.any((a) => a.statusAlerta == "Crítico")) {
      return BitmapDescriptor.hueRed;
    }
    // Caso contrário, utiliza o status do primeiro alerta
    switch (alerts.first.statusAlerta) {
      case "Preventivo":
        return BitmapDescriptor.hueGreen;
      case "Atenção":
        return BitmapDescriptor.hueYellow;
      case "Emergência":
        return BitmapDescriptor.hueOrange;
      default:
        return BitmapDescriptor.hueBlue; // valor padrão se o status não corresponder
    }
  }

  void _addMarkers(List<Alerta> alertas) {
    Set<Marker> markers = {};

    // Agrupa alertas pela mesma latitude e longitude
    Map<String, List<Alerta>> groupedAlerts = {};

    for (var alerta in alertas) {
      String key = "${alerta.latitude},${alerta.longitude}";
      if (!groupedAlerts.containsKey(key)) {
        groupedAlerts[key] = [];
      }
      groupedAlerts[key]!.add(alerta);
    }

    groupedAlerts.forEach((key, alerts) {
      double lat = double.tryParse(alerts.first.latitude) ?? 0.0;
      double lng = double.tryParse(alerts.first.longitude) ?? 0.0;
      double markerHue = _getMarkerHue(alerts);

      markers.add(
        Marker(
          markerId: MarkerId(key),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
          onTap: () => _mostrarListaAlertas(alerts, lat, lng),
        ),
      );
    });

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  void _mostrarListaAlertas(List<Alerta> alerts, double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Alertas na Mesma Localização"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: alerts.map((alerta) {
            return ListTile(
              leading: Icon(Icons.warning, color: _alertColors[alerta.statusAlerta] ?? Colors.blueGrey),
              title: Text(alerta.statusAlerta),
              subtitle: Text("Código: ${alerta.codAlerta}"),
              onTap: () {
                Navigator.pop(context);
                _mostrarDetalhes(alerta, lat, lng);
              },
            );
          }).toList(),
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

  void _mostrarDetalhes(Alerta alerta, double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
    );

    Color alertColor = _alertColors[alerta.statusAlerta] ?? Colors.blueGrey;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: alertColor,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 10),
            Text("Detalhes do Alerta", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Código: ${alerta.codAlerta}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text("Status: ${alerta.statusAlerta}", style: TextStyle(color: Colors.white)),
            Text("Cidade: ${alerta.cidade}", style: TextStyle(color: Colors.white)),
            Text("Bairro: ${alerta.bairro}", style: TextStyle(color: Colors.white)),
            Text("Latitude: ${alerta.latitude}", style: TextStyle(color: Colors.white)),
            Text("Longitude: ${alerta.longitude}", style: TextStyle(color: Colors.white)),
            Text("Data: ${alerta.dataAlerta.toLocal()}", style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarListaAlertas(
                  _alertas.where((a) => a.latitude == alerta.latitude && a.longitude == alerta.longitude).toList(),
                  lat,
                  lng);
            },
            child: Text("Voltar para Lista", style: TextStyle(color: Colors.white)),
          ),
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
              zoom: 10,
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
