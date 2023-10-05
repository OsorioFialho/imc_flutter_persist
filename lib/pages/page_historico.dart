import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HistoricoIMC extends StatefulWidget {
  final List<List<double>> historicoIMC;

  const HistoricoIMC({Key? key, required this.historicoIMC}) : super(key: key);

  @override
  _HistoricoIMCState createState() => _HistoricoIMCState();
}

class _HistoricoIMCState extends State<HistoricoIMC> {
  late Future<Database> _database;

  @override
  void initState() {
    super.initState();
    _database = _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'historico_imc.db');
    final database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
        '''
        CREATE TABLE historico_imc (
          id INTEGER PRIMARY KEY,
          peso REAL,
          altura REAL,
          imc REAL
        )
        ''',
      );
    });

    for (final registro in widget.historicoIMC) {
      await database.insert('historico_imc', {
        'peso': registro[0],
        'altura': registro[1],
        'imc': registro[2],
      });
    }
    widget.historicoIMC.clear();
    return database;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de IMC'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllRecords();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<Database>(
        future: _database,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return Text('Inicializando o banco de dados...');
          } else {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchRecords(snapshot.data!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return AlertDialog(
                    title: const Text('Histórico Vazio'),
                    content: const Text('Nenhum registro de IMC no histórico.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                } else {
                  final historico = snapshot.data!;
                  return ListView.builder(
                    itemCount: historico.length,
                    itemBuilder: (context, index) {
                      final registro = historico[index];
                      final peso = registro['peso'] as double;
                      final altura = registro['altura'] as double;
                      final imc = registro['imc'] as double;

                      return ListTile(
                        title: Text('Peso: ${peso.toStringAsFixed(2)} kg'),
                        subtitle:
                            Text('Altura: ${altura.toStringAsFixed(2)} m'),
                        trailing: Text('IMC: ${imc.toStringAsFixed(2)}'),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRecords(Database database) async {
    final historico = await database.query('historico_imc');
    return historico;
  }

  Future<void> _deleteAllRecords() async {
    final database = await _database;
    await database.delete('historico_imc');
    setState(() {});
  }
}
