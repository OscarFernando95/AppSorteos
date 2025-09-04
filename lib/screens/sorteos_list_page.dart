import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'numbers_grid_page.dart';

class SorteosListPage extends StatefulWidget {
  @override
  _SorteosListPageState createState() => _SorteosListPageState();
}

class _SorteosListPageState extends State<SorteosListPage> {
  List<Map<String, dynamic>> sorteos = [];

  @override
  void initState() {
    super.initState();
    _loadSorteos();
  }

  Future<void> _loadSorteos() async {
    final data = await DatabaseHelper.instance.getAllSorteos();
    setState(() {
      sorteos = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sorteos')),
      body: ListView.builder(
        itemCount: sorteos.length,
        itemBuilder: (context, index) {
          final sorteo = sorteos[index];
          final fecha = sorteo['fecha'].toString(); // convertir a String

          return ListTile(
            title: Text('Sorteo ${sorteo['id']}'),
            subtitle: Text('Fecha: $fecha'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NumbersGridPage(
                    sorteoId: sorteo['id'],
                    fecha: fecha,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final now = DateTime.now().toString();
          await DatabaseHelper.instance.createNewSorteo(now);
          _loadSorteos();
        },
      ),
    );
  }
}
