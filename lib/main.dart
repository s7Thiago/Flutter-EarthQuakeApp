import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

main() {
  Intl.defaultLocale = 'pt_BR';
  runApp(App());
}

//App
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.red,
        accentColor: Colors.redAccent,
      ),
      home: Home(title: 'Terremoto App'),
    );
  }
}

//Home
class Home extends StatelessWidget {
  final String title;

  const Home({
    Key key,
    this.title = 'Flutter Application',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Ocurrencies(),
    );
  }
}

//Ocurrencies Widget
class Ocurrencies extends StatefulWidget {
  @override
  _OcurrenciesState createState() => _OcurrenciesState();
}

class _OcurrenciesState extends State<Ocurrencies> {
  Future<Map> _getData() async {
    http.Response data = await http.get(
        'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson');

    return await json.decode(data.body);
  }

  _buildList({Map data}) {
    initializeDateFormatting('pt_BR');

    return data == null
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : ListView.builder(
            itemCount: data['features'].length,
            itemBuilder: (BuildContext context, int index) => Column(
              children: [
                ListTile(
                  onTap: () {
                    {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Terremotos'),
                              content: Text(
                                data['features'][index]['properties']['title'],
                              ),
                            );
                          });
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).accentColor,
                    child: Text(
                      data['features'][index]['properties']['mag'].toString(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    (DateFormat('yMMMMEEEEd')
                        .format(
                          DateTime.fromMillisecondsSinceEpoch(
                            data['features'][index]['properties']['time'],
                          ),
                        )
                        .toString()),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text(data['features'][index]['properties']['place']),
                ),
                Divider(
                  height: 1,
                  indent: 70,
                )
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> data) {
        return _buildList(data: data.data);
      },
    );
  }
}
