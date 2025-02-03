import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Alerta {
  final String statusAlerta;
  final String cidade;
  final String bairro;
  final double latitude;
  final double longitude;
  final bool ativo;

  Alerta({
    required this.statusAlerta,
    required this.cidade,
    required this.bairro,
    required this.latitude,
    required this.longitude,
    required this.ativo,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      statusAlerta: json['statusAlerta'],
      cidade: json['cidade'],
      bairro: json['bairro'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      ativo: json['ativo'],
    );
  }
}