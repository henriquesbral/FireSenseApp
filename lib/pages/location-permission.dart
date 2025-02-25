import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Fire_Sense/pages/mapa-dashboard.dart';

void main() {
  runApp(MaterialApp(
    home: LocationPermissionScreen(),
  ));
}

class LocationPermissionScreen extends StatefulWidget {
  @override
  _LocationPermissionScreenState createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkLocationService();
  }

  // Verifica se o serviço de localização está habilitado
  Future<void> _checkLocationService() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      _showEnableLocationDialog();
    } else {
      setState(() {
        _isLocationEnabled = true;
      });
    }
  }

  // Exibe um diálogo solicitando que o usuário habilite a localização
  void _showEnableLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Impede que o usuário feche o diálogo sem habilitar a localização
      builder: (context) => AlertDialog(
        title: Text('Localização Desabilitada'),
        content: Text(
            'Para usar este aplicativo, habilite a localização nas configurações do dispositivo.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Fecha o diálogo
              await Geolocator
                  .openLocationSettings(); // Abre as configurações de localização
              _checkLocationService();
            },
            child: Text('Habilitar Localização'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habilitar Localização'),
      ),
      body: Center(
        child: _isLocationEnabled
            ? Text('Localização habilitada. Você pode usar o aplicativo.')
            : Text('Aguardando habilitação da localização...'),
      ),
    );
  }
}
