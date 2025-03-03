import 'package:flutter/material.dart';
import 'package:Fire_Sense/model/app-bar-rotas.dart';
import 'package:Fire_Sense/model/usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Fire_Sense/services/storage_service.dart';
import 'package:Fire_Sense/model/alerta_model.dart';

class ListaAlertasScreen extends StatefulWidget {
  final Usuario usuarioAtual;

  ListaAlertasScreen({required this.usuarioAtual});

  @override
  _ListaAlertasScreenState createState() => _ListaAlertasScreenState();
}

class _ListaAlertasScreenState extends State<ListaAlertasScreen> {
  List<Alerta> _alertas = [];
  List<Alerta> _alertasFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final Map<String, Color> _coresAlertas = {
    'Preventivo': Colors.green,
    'Atenção': Colors.yellow,
    'Emergência': Colors.orange,
    'Crítico': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _verificarAcesso();
    _searchController.addListener(_filtrarAlertas);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarAlertas);
    _searchController.dispose();
    super.dispose();
  }

  void _verificarAcesso() {
    if (widget.usuarioAtual.perfil != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Acesso negado. Apenas administradores podem visualizar esta tela."),
          ),
        );
      });
    } else {
      _buscarAlertas();
    }
  }

  Future<void> _buscarAlertas() async {
    setState(() {
      _isLoading = true;
    });

    const String apiUrl =
        'https://firesenseapi-gdg2fze3ath6gpa2.brazilsouth-01.azurewebsites.net/api/BuscarAlertas';

    String? token = await StorageService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário não autenticado. Faça login novamente.'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Alerta> alertasRecebidos =
            jsonResponse.map((json) => Alerta.fromJson(json)).toList();

        setState(() {
          _alertas = alertasRecebidos;
          _alertasFiltrados = List.from(_alertas);
          _isLoading = false;
        });
      } else {
        _mostrarErro("Erro ao carregar alertas.");
      }
    } catch (e) {
      _mostrarErro("Erro de conexão com o servidor.");
    }
  }

  Future<void> _desativarAlerta(int codAlerta) async {
    bool confirmacao = await _mostrarConfirmacao(
        "Tem certeza que deseja desativar este alerta?");
    if (!confirmacao) return;

    bool confirmacaoFinal = await _mostrarConfirmacao(
        "Esta ação não pode ser desfeita. Deseja continuar?");
    if (!confirmacaoFinal) return;

    const String apiUrl =
        'https://firesenseapi-gdg2fze3ath6gpa2.brazilsouth-01.azurewebsites.net/api/DesativarAlerta';

    String? token = await StorageService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário não autenticado. Faça login novamente.'),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'codAlerta': codAlerta}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _alertas.removeWhere((alerta) => alerta.codAlerta == codAlerta);
          _alertasFiltrados = List.from(_alertas);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alerta desativado com sucesso.")),
        );
      } else {
        _mostrarErro("Erro ao desativar o alerta.");
      }
    } catch (e) {
      _mostrarErro("Erro de conexão com o servidor.");
    }
  }

  Future<bool> _mostrarConfirmacao(String mensagem) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirmação"),
            content: Text(mensagem),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Confirmar"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _filtrarAlertas() {
    setState(() {
      String pesquisa = _searchController.text.toLowerCase();
      _alertasFiltrados = _alertas.where((alerta) {
        return alerta.statusAlerta.toLowerCase().contains(pesquisa) ||
            alerta.cidade.toLowerCase().contains(pesquisa) ||
            alerta.bairro.toLowerCase().contains(pesquisa);
      }).toList();
    });
  }

  void _mostrarErro(String mensagem) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(
        usuario: widget.usuarioAtual,
        tituloInicial: "Lista de Alertas",
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Pesquisar alerta",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _buscarAlertas,
                    child: _alertasFiltrados.isEmpty
                        ? Center(child: Text("Nenhum alerta encontrado."))
                        : ListView.builder(
                            padding: EdgeInsets.all(10),
                            itemCount: _alertasFiltrados.length,
                            itemBuilder: (context, index) {
                              Alerta alerta = _alertasFiltrados[index];

                              Color cor = _coresAlertas[alerta.statusAlerta] ??
                                  Colors.grey;

                              return Card(
                                color: cor.withOpacity(0.3),
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.warning,
                                    color: cor,
                                  ),
                                  title: Text(
                                    "Código: ${alerta.codAlerta}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Status: ${alerta.statusAlerta}"),
                                      Text("Cidade: ${alerta.cidade}"),
                                      Text("Bairro: ${alerta.bairro}"),
                                      Text(
                                          "Data: ${alerta.dataAlerta.toLocal()}"),
                                    ],
                                  ),
                                  trailing: alerta.ativo
                                      ? IconButton(
                                          icon:
                                              Icon(Icons.close, color: Colors.black),
                                          onPressed: () =>
                                              _desativarAlerta(alerta.codAlerta),
                                        )
                                      : Icon(Icons.check, color: Colors.green),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
