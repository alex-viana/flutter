import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=6cf55e46";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
      )
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double dollar;
  double euro;

  void _realChanged(String text){
    if(text.isEmpty){
      clearAll();
      return;
    }

    double real = double.parse(text);
    dollarController.text = (real/dollar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dollarChanged(String text){
    if(text.isEmpty){
      clearAll();
      return;
    }

    double dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty){
      clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
  }

  void clearAll(){
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...", style: TextStyle(color: Colors.amber, fontSize: 25.0),textAlign: TextAlign.center,),
              );
            default :
              if(snapshot.hasError){
                return Center(
                  child: Text("Error ao carregar dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0
                  ),
                  textAlign: TextAlign.center,),
                );
              }else{
                dollar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber,),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "US\$", dollarController, _dollarChanged),
                      Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged)
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

Widget buildTextField(String label, String prefix, TextEditingController controller, Function changed){
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: "$prefix ", prefixStyle: TextStyle(color: Colors.amber, fontSize: 25.0)
    ),
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25.0
    ),
    onChanged: changed,
    keyboardType: TextInputType.number,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);

  print(response.body);

  return json.decode(response.body);
}
