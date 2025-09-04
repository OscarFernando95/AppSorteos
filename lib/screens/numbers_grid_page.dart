import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class NumbersGridPage extends StatefulWidget {
  final int sorteoId;
  final String fecha;

  NumbersGridPage({required this.sorteoId, required this.fecha});

  @override
  _NumbersGridPageState createState() => _NumbersGridPageState();
}

class _NumbersGridPageState extends State<NumbersGridPage> {
  List<Map<String, dynamic>> numbers = [];

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  Future<void> _loadNumbers() async {
    final all = await DatabaseHelper.instance.getNumbersBySorteoId(widget.sorteoId);
    setState(() {
      numbers = all;
    });
  }

  Future<void> _editNumber(Map<String, dynamic> number) async {
    final TextEditingController celularController =
    TextEditingController(text: number['celular']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Número ${number['numero']}'),
        content: TextFormField(
          controller: celularController,
          decoration: InputDecoration(labelText: 'Celular'),
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Guardar'),
            onPressed: () async {
              await DatabaseHelper.instance.updateNumber(
                number['id'],
                celularController.text,
              );
              Navigator.pop(context);
              _loadNumbers();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sorteo ${widget.sorteoId} - ${widget.fecha}'),
      ),
      body: GridView.builder(
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        itemCount: numbers.length,
        itemBuilder: (context, index) {
          final number = numbers[index];
          final estado = number['estado'];
          final celular = number['celular'];

          return GestureDetector(
            onTap: () {
              _editNumber(number);
            },
            child: Container(
              margin: EdgeInsets.all(4),
              color: (estado == 'Disponible') ? Colors.green : Colors.red,
              child: Center(
                child: Text(
                  '${number['numero']}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
