import 'package:flutter/material.dart';

class Alerta {
  final int codAlerta;
  final String statusAlerta;
  final String cidade;
  final String bairro;
  final String latitude;
  final String longitude;
  final bool ativo;
  final DateTime dataAlerta;

  Alerta({
    required this.codAlerta,
    required this.statusAlerta,
    required this.cidade,
    required this.bairro,
    required this.latitude,
    required this.longitude,
    required this.ativo,
    required this.dataAlerta,
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
      dataAlerta: DateTime.parse(json['dataAlerta']), // Converte string para DateTime
    );
  }
}
