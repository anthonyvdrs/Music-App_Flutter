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
    new Musique('Rêve bizarre', 'Orelsan ft Damso', 'assets/revebiz.jpg', 'https://www.matieuio.fr/tutoriels/musiques/grave.mp3'),
    new Musique('Congratulation', 'Post Malone', 'assets/congratulation.jpg', 'https://www.matieuio.fr/tutoriels/musiques/nuvole_bianche.mp3'),
    new Musique('Better Now', 'Post Malone', 'assets/betternow.jpg', 'https://www.matieuio.fr/tutoriels/musiques/these_days.mp3'),
  ];

  AudioPlayer audioPlayer;
  StreamSubscription positiionSubscription;
  StreamSubscription stateSubscription;

  Musique actuelMusic;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 30);
  PlayerState statut = PlayerState.STOPPED;
  int index = 0;
  bool mute = false;
  int maxVol = 0, currentVol = 0;

  @override
  void initState() {
    super.initState();
    actuelMusic = musicList[index];
    configAudioPlayer();
    initPlatformState();
    updateVolume();
  }

  @override
  Widget build(BuildContext context) {
    double largeur = MediaQuery.of(context).size.width;
    //int newVol = getVolumePourcent().toInt();
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
              child: new Image.asset(actuelMusic.imagePath),
            ),
            new Container(
              margin: EdgeInsets.only(top: 20.0),
              child: new Text(
                actuelMusic.title,
                textScaleFactor: 2,
              ),
            ),
                        new Container(
              margin: EdgeInsets.only(top: 5.0),
              child: new Text(
                actuelMusic.author,
              ),
            ),
            new Container(
              height: largeur / 5,
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new IconButton(icon: new Icon(Icons.fast_rewind), onPressed: rewind),
                  new IconButton(
                    icon: (statut != PlayerState.PLAYING) ? new Icon(Icons.play_arrow) : new Icon(Icons.pause), 
                  onPressed: (statut != PlayerState.PLAYING) ? play : pause,
                  iconSize: 50),
                  new IconButton(icon: (mute) ? new Icon(Icons.headset_off) : new Icon(Icons.headset), onPressed: muted),
                  new IconButton(icon: new Icon(Icons.fast_forward), onPressed: forward),
                ],
              ),
            ),
            new Container(
              margin:  EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  textStyle(fromDuration(position), 0.8),
                  textStyle(fromDuration(duree), 0.8)
                ],
              ),
            ),
            new Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: duree.inSeconds.toDouble(),
                inactiveColor: Colors.grey[500],
                activeColor: Colors.deepPurpleAccent,
                onChanged: (double d){
                  setState(() {
                   audioPlayer.seek(d);
                  });
                },)
            ),
            new Container(
              height: largeur /5,
              margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 0.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new IconButton(
                  icon: new Icon(Icons.remove),
                  iconSize: 18,
                  onPressed: () {
                    if (!mute) {
                      Volume.volDown();
                      updateVolume();

                    }
                  }
                  ),
                  new Slider(
                    value: (mute) ? 0.0
                  )
                  //new Text((mute) ? 'Mute' : '$newVol%'),
                  new IconButton(
                  icon: new Icon(Icons.add),
                  iconSize: 18,
                  onPressed: () {
                    if (!mute) {
                      Volume.volUp();
                      updateVolume();

                    }
                  }
                  )
                ],
                )
              ),
            
          ],
        ),
        
      ),
     
    );
  }



  double getVolumePourcent() {
    return (currentVol / maxVol) * 100;
  }
  //Initializser le Volume
  Future<void> initPlatformState() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }

  //Update le Volume
  updateVolume() async {
    maxVol = await Volume.getMaxVol;
    currentVol = await Volume.getVol;
    setState(() { });
  }

  // Définir le Volume
  setVol (int i) async {
    await Volume.setVol(i);
  }

  // gestion des text/style

  Text textStyle(String data, double scale) {
    return new Text(data,
    textScaleFactor: scale,
    textAlign: TextAlign.center,
    style: new TextStyle(
      color: Colors.black,
      fontSize: 15.0
    ),
    );
  }

  // Gestion des Boutons
  IconButton bouton(IconData icone, double taille, ActionMusic action) {
    return new IconButton(
      icon: new Icon(icone),
      iconSize: taille,
      color: Colors.white,
      onPressed: () {
        switch(action) {
          case ActionMusic.PLAY:
          play();
          break;
          case ActionMusic.PAUSE:
          pause();
          break;
          case ActionMusic.REWIND:
          rewind();
          break;
          case ActionMusic.FORWARD:
          forward();
          break;
          default: break;
        }
      }
      );
  }

  // Configuration de l'audioPlayer

  void configAudioPlayer() {
  audioPlayer = new AudioPlayer();
  positiionSubscription = audioPlayer.onAudioPositionChanged.listen((pos) {
    setState(() {
      position = pos;
    });
    if (position >= duree) {
      position = new Duration(seconds: 0);
      // PASSER A LA MUSIQUE SUIVANTE (forward);
    }
  });
  stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
    if (state == AudioPlayerState.PLAYING) {
      setState(() {
       duree =  audioPlayer.duration;
      });
    } else if (state == AudioPlayerState.STOPPED) {
      setState(() {
       statut = PlayerState.STOPPED;
      });
    }
  }, onError: (message) {
    print(message);
    setState(() {
     statut = PlayerState.STOPPED;
     duree = new Duration(seconds: 0);
     position = new Duration(seconds: 0); 
    });
  });
  }

  Future play() async {
    await audioPlayer.play(actuelMusic.musicURL);
    setState(() {
     statut = PlayerState.PLAYING; 
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
     statut = PlayerState.PAUSED; 
    });
  }

  Future muted() async {
    await audioPlayer.mute(!mute);
    setState(() {
     mute = !mute; 
    });
  }

  // Passer à la musique suivante


  void forward() {
    if (index == musicList.length - 1) {
      index = 0;
    } else {
      index++;
    }
    actuelMusic = musicList[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
  }
 
 //Retour à la musique précédente
  
  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if (index == 0) {
        index = musicList.length -1;
      } else {
        index--;
      }
    }
  }

  String fromDuration (Duration duree) {
    return duree.toString().split('.').first;
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