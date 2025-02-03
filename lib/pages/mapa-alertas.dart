// ignore_for_file: deprecated_member_use

import 'package:aps/model/app-bar-rotas.dart';
import 'package:aps/model/mapStyles.dart';
import 'package:aps/model/usuario.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:aps/model/alerta_model.dart';

void main() {
  runApp(MaterialApp(
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
  static const LatLng _initialPosition =
      LatLng(-23.55052, -46.633308); // Posição inicial (São Paulo)
  final String _mapStyle = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
  ''';

  @override
  void initState() {
    super.initState();
    _fetchAlertas();
  }

  // Buscar dados da API
  Future<void> _fetchAlertas() async {
    final response =
        await http.get(Uri.parse('https://api.exemplo.com/alertas'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      List<Alerta> alertas =
          jsonList.map((json) => Alerta.fromJson(json)).toList();

      _addMarkers(alertas);
    } else {
      throw Exception('Erro ao carregar alertas');
    }
  }

  // Adicionar marcadores personalizados
  void _addMarkers(List<Alerta> alertas) {
    Set<Marker> markers = {};

    for (var alerta in alertas) {
      markers.add(
        Marker(
          markerId: MarkerId(
              alerta.latitude.toString() + alerta.longitude.toString()),
          position: LatLng(alerta.latitude, alerta.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(alerta.ativo
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: alerta.cidade,
            snippet: alerta.bairro,
            onTap: () {
              _mostrarDetalhes(alerta);
            },
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  // Exibir modal com detalhes do alerta
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
              Text("Detalhes do Alerta",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      appBar: MenuAppBar(usuario: usuarioAtual),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _initialPosition, zoom: 12),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              mapController!.setMapStyle(_mapStyle);
            },
            markers: _markers,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: (){},
              child: Icon(Icons.my_location),
            ),
          )
        ],
      ),
    );
  }
}
