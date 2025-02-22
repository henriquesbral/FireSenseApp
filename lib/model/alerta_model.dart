import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Alerta {
  final int codAlerta;
  final String statusAlerta;
  final String cidade;
  final String bairro;
  final String latitude;
  final String longitude;
  final bool ativo;

  Alerta({
    required this.codAlerta,
    required this.statusAlerta,
    required this.cidade,
    required this.bairro,
    required this.latitude,
    required this.longitude,
    required this.ativo,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      codAlerta: json['codAlerta'],
      statusAlerta: json['statusAlerta'],
      cidade: json['cidade'],
      bairro: json['bairro'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      ativo: json['ativo'] == 1, // Converte 1 para true e 0 para false
    );
  }
}

