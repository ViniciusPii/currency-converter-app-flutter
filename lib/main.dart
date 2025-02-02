import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance";

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
          primaryColor: Colors.green,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green)),
              hintStyle: TextStyle(color: Colors.green))),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dollar;
  double euro;

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChange(String text) {
    double real = double.parse(text.replaceAll(',', '.'));
    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dollarChange(String text) {
    double dollar = double.parse(text.replaceAll(',', '.'));
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
  }

  void _euroChange(String text) {
    double euro = double.parse(text.replaceAll(',', '.'));
    realController.text = (euro * this.euro).toStringAsFixed(2);
    realController.text = (euro * this.euro / dollar).toStringAsFixed(2);
  }

  void _resetFields() {
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Conversor de Moedas"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetFields)
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snap) {
          switch (snap.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carragando Dados",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snap.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados!",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dollar = snap.data["results"]["currencies"]["USD"]["buy"];
                euro = snap.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Icon(
                          Icons.monetization_on,
                          size: 100,
                          color: Colors.green,
                        ),
                      ),
                      buildTextField(
                          "Reais", "R\$ ", realController, _realChange),
                      buildTextField(
                          "Dólares", "US\$ ", dollarController, _dollarChange),
                      buildTextField(
                          "Euros", "€ ", euroController, _euroChange),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function function) {
  return Padding(
    padding: EdgeInsets.only(top: 15),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green,
          ),
        ),
        prefix: Text(prefix),
      ),
      style: TextStyle(color: Colors.black54, fontSize: 20),
      onChanged: function,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
