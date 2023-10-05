import 'package:flutter/material.dart';
import 'package:imc_flutter_persist/classes/calculo_imc.dart';
import 'package:imc_flutter_persist/pages/page_historico.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeuImc());
}

class UserData {
  String name = '';
  double height = 0.0;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'height': height,
    };
  }

  void fromMap(Map<String, dynamic> map) {
    name = map['name'] ?? '';
    height = map['height'] ?? 0.0;
  }
}

class MeuImc extends StatelessWidget {
  const MeuImc({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController pesoController = TextEditingController();
  TextEditingController alturaController = TextEditingController();
  String resultado = '';
  String classificacao = '';

  List<List<double>> historicoIMC = [];

  UserData userData = UserData();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('name') ?? '';
    final storedHeight = prefs.getDouble('height') ?? 0.0;

    setState(() {
      userData.name = storedName;
      userData.height = storedHeight;
    });
  }

  _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', userData.name);
    await prefs.setDouble('height', userData.height);
  }

  void calcularIMC() {
    double peso = double.tryParse(pesoController.text) ?? 0.0;
    double altura = userData.height;

    CalculoIMC calculadora = CalculoIMC();
    double imc = calculadora.calcularIMC(peso, altura);

    if (peso > 0 && altura > 0) {
      List<double> registroIMC = [peso, altura, imc];
      setState(() {
        resultado = 'Seu IMC é ${imc.toStringAsFixed(2)}';
        classificacao =
            'Sua classificação: ${calculadora.getClassificacao(imc)}';
        historicoIMC.add(registroIMC);
        pesoController.clear();
      });
    } else {
      setState(() {
        resultado = 'Por favor, insira valores válidos para peso e altura.';
        classificacao = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculadora de IMC"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: pesoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: calcularIMC,
              child: const Text('Calcular IMC'),
            ),
            const SizedBox(height: 16.0),
            Text(
              resultado,
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              classificacao,
              style: const TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //if (historicoIMC.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoricoIMC(historicoIMC: historicoIMC),
            ),
          );
        },
        child: const Icon(Icons.history),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
              onChanged: (value) {
                userData.name = value;
              },
              controller: TextEditingController(text: userData.name),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Altura (m)',
              ),
              onChanged: (value) {
                userData.height = double.tryParse(value) ?? 0.0;
              },
              controller:
                  TextEditingController(text: userData.height.toString()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveUserData();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Dados Salvos'),
                      content: const Text('Os dados foram salvos com sucesso!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
