import 'package:flutter/material.dart';
import 'package:audioplayer2/audioplayer2.dart';
import 'package:volume/volume.dart';
import 'music.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Musique ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Application Musique'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  List<Musique> musicList = [
    new Musique('Rêve bizarre', 'Orelsan ft Damso', 'assets/revebiz.jpg', 'https://soundcloud.com/orelsan-official/reves-bizarres-feat-damso'),
    new Musique('Congratulation', 'Post Malone', 'assets/congratulation.jpg', 'https://soundcloud.com/postmalone/congratulations'),
    new Musique('Better Now', 'Post Malone', 'assets/betternox.jpg', 'https://soundcloud.com/postmalone/better-now'),
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positiionSub;
  StreamSubscription StateSubscription;

  Musique actuelMusic;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 30);
  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey,
        elevation: 20.0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              width: 200,
              color: Colors.red,
              margin: EdgeInsets.only(top: 20.0),
              child: new Image.asset('assets/revebiz.jpg'),
            ),
            new Container(
              margin: EdgeInsets.only(top: 20.0),
              child: new Text(
                'TITRE DE LA CHANSON',
                textScaleFactor: 2,
              ),
            ),
                        new Container(
              margin: EdgeInsets.only(top: 5.0),
              child: new Text(
                'AUTEUR',
              ),
            )
          ],
        ),
        
      ),
     
    );
  }
}

enum ActionMusic {
  PLAY,
  PAUSE,
  REWIND,
  FORWARD
}

enum PlayerState {
  PLAYING,
  STOPPED,
  PAUSED
}