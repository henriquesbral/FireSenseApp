// ignore_for_file: deprecated_member_use

import 'package:aps/model/app-bar-rotas.dart';
import 'package:aps/model/usuario.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aps/services/storage_service.dart';

void main() {
  runApp(MaterialApp(
    home: MapScreen(),
  ));
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  final LatLng _initialPosition = LatLng(-23.5505, -46.6333);
  Map<String, dynamic>? _locationData;
  bool _locationCaptured = false;

  final List<String> _alertTypes = ['Preventivo', 'Atenção', 'Emergência', 'Crítico'];
  String _selectedAlertType = 'Preventivo';

  final Map<String, Color> _alertColors = {
    'Preventivo': Colors.green,
    'Atenção': Colors.yellow,
    'Emergência': Colors.orange,
    'Crítico': Colors.red,
  };

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Por favor, habilite o serviço de localização.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Permissão de localização negada.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Permissão de localização negada permanentemente.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentLocation!,
          infoWindow: InfoWindow(title: 'Você está aqui'),
        ),
      );

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );

      _locationData = {
        'StatusAlerta': _selectedAlertType,
        'Latitude': position.latitude.toString(),
        'Longitude': position.longitude.toString(),
        'Cidade': 'São Paulo',
        'Estado': 'SP',
        'Endereco': 'Rua Exemplo, 123',
        'Bairro': 'Centro',
        'NomeLocalizacao': 'Local Atual',
        'Usuario': usuarioAtual.usuario,
      };

      _locationCaptured = true;
    });
  }

  void _showAlertTypeSelection() {
    if (!_locationCaptured) {
      _showSnackBar('Por favor, capture a localização antes de continuar.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: _alertColors[_selectedAlertType],
              title: Text(
                "Selecione o Tipo de Alerta",
                style: TextStyle(color: Colors.white),
              ),
              content: DropdownButton<String>(
                value: _selectedAlertType,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedAlertType = newValue;
                      _locationData!['StatusAlerta'] = _selectedAlertType;
                    });
                    setStateDialog(() {});
                  }
                },
                items: _alertTypes.map((String alertType) {
                  return DropdownMenuItem<String>(
                    value: alertType,
                    child: Text(alertType),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showConfirmDialog();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: Text(
                    "Confirmar",
                    style: TextStyle(color: _alertColors[_selectedAlertType]),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _alertColors[_selectedAlertType],
        title: Text("Confirmar Localização", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cidade: ${_locationData!['Cidade']}", style: TextStyle(color: Colors.white)),
            Text("Estado: ${_locationData!['Estado']}", style: TextStyle(color: Colors.white)),
            Text("Endereço: ${_locationData!['Endereco']}", style: TextStyle(color: Colors.white)),
            Text("Bairro: ${_locationData!['Bairro']}", style: TextStyle(color: Colors.white)),
            Text("Latitude: ${_locationData!['Latitude']}", style: TextStyle(color: Colors.white)),
            Text("Longitude: ${_locationData!['Longitude']}", style: TextStyle(color: Colors.white)),
            Text("Status do Alerta: ${_locationData!['StatusAlerta']}", style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendLocationToAPI();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: Text("Confirmar e Enviar", style: TextStyle(color: _alertColors[_selectedAlertType])),
          ),
        ],
      ),
    );
  }

  Future<void> _sendLocationToAPI() async {
    if (_locationData == null) {
      _showSnackBar('Erro: Localização não foi capturada.');
      return;
    }

    const String apiUrl =
        'https://firesenseapi-gdg2fze3ath6gpa2.brazilsouth-01.azurewebsites.net/api/EnviarAlerta';

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
        body: jsonEncode(_locationData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Alerta enviado com sucesso!');
      } else {
        _showSnackBar('Erro ao enviar alerta: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Falha na conexão com o servidor.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(usuario: usuarioAtual),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? _initialPosition,
              zoom: 5,
            ),
            mapType: MapType.hybrid,
            markers: _markers,
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Row(
              children: [
                Expanded(
                  child: FloatingActionButton.extended(
                    onPressed: _getCurrentLocation,
                    icon: Icon(Icons.my_location),
                    label: Text("Capturar Localização"),
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: FloatingActionButton.extended(
                    onPressed: _showAlertTypeSelection,
                    icon: Icon(Icons.send),
                    label: Text("Enviar Localização"),
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
