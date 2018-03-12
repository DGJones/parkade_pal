import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:parkade_pal/ParkadeInfo.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  _initializeLocale();
  runApp(new ParkadePalApp());
}

void _initializeLocale() {
  Intl.defaultLocale = "en_CA";
  var dateInitializationFuture = initializeDateFormatting("en_CA");
  Future.wait([dateInitializationFuture]);
}

class ParkadePalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "Parkade Pal",
        home: new MainScreen()
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ParkadeState();
  }
}

class ParkadeState extends State<MainScreen> {

  final Uri _url = Uri.parse("https://www.calgaryparking.com/parkadeRssFeed/availability/lot/feed.rss");
  final CalgaryParkades _calgaryParkades = new CalgaryParkades();

  Text _lastUpdate = new Text("Refresh to see updates");
  ListView _parkadesListView = new ListView(
    shrinkWrap: true,
    padding: const EdgeInsets.all(20.0),
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Parkade Pal"),
        actions: <Widget>[
          new IconButton( // action button
            icon: new Icon(Icons.refresh),
            onPressed: () { _refresh(); },
          )]),
      body: new Column(children: <Widget>[
        _parkadesListView,
        _lastUpdate
        ])
    );
  }

  Future _refresh() async {
    var responseBody = await _queryFeed();
    _calgaryParkades.initializeFromRssData(responseBody);
    var cards = _createCards();
    setState((){
      _parkadesListView = new ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20.0),
        children: cards.toList(),
      );
      _lastUpdate = new Text(new DateFormat.yMd().add_jms().format(_calgaryParkades.lastUpdate));
    });
  }

  Future _queryFeed() async {
    var client = new HttpClient();
    try {
      var request = await client.getUrl(_url);
      var response = await request.close();
      return response.transform(UTF8.decoder).join();
    } finally {
      client.close();
    }
  }

  Iterable<ParkadeCard> _createCards() {
    var cards = new List<ParkadeCard>();
    for (var parkade in _calgaryParkades.parkadesInfo) {
      cards.add(new ParkadeCard(parkadeInfo: parkade));
    }
    return cards;
  }
}

class ParkadeCard extends StatelessWidget {
  final ParkadeInfo info;

  ParkadeCard({ParkadeInfo parkadeInfo}): info = parkadeInfo;

  @override
  Widget build(BuildContext context) {
    return new Card(
        child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Row (children: <Widget> [
            new Align(
                alignment: Alignment.centerLeft,
                child: new Row ( children: <Widget> [
                  new Icon(Icons.local_parking),
                  new Text("${info.availableStalls}")
                ])
            ),
            new Expanded(
                child: new Center(child: new Text(info.name))
            ),
            new Align(
              alignment: Alignment.centerLeft,
              child: new Row ( children: <Widget> [
                new Text("${info.accessibleStalls}"),
                new Icon(Icons.accessible)
              ])
            )
          ]),
        ])
    );
  }
}

