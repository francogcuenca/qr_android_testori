import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GruposScreen extends StatefulWidget {
  const GruposScreen({super.key});

  @override
  State<GruposScreen> createState() => _GruposScreenState();
}

class _GruposScreenState extends State<GruposScreen> {
  List grupos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarGrupos();
  }

  cargarGrupos() async {
    final data = await ApiService.getGrupos();
    setState(() {
      grupos = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Grupos recibidos")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: grupos
                  .map(
                    (g) => ListTile(
                      title: Text("Grupo: ${g['grupo']}"),
                      subtitle: Text("Items: ${g['items'].length}"),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
