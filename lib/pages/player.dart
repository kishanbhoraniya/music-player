import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:musify/api/player_state.dart';
import 'package:musify/style/appColors.dart';

String status = 'hidden';
AudioPlayer audioPlayer;
PlayerState playerState;

typedef void OnError(Exception exception);
enum PlayerState { stopped, playing, paused }

class AudioApp extends StatefulWidget {
  @override
  _AudioAppState createState() => _AudioAppState();
}

class _AudioAppState extends State<AudioApp> {
  Duration duration;
  Duration position;
  String localFilePath;
  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;

  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initAudioPlayer() {
    if (audioPlayer == null) {
      audioPlayer = AudioPlayer();
    }
    setState(() {
      if (checker == "Haa") {
        stop();
        play();
      } else{
        play();
      }
    });

    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => {if (mounted) setState(() => position = p)});

    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        {
          if (mounted) setState(() => duration = audioPlayer.duration);
        }
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        if (mounted)
          setState(() {
            position = duration;
          });
      }
    }, onError: (msg) {
      if (mounted)
        setState(() {
          playerState = PlayerState.stopped;
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
    });
  }

  Future play() async {
    await audioPlayer.play(kUrl);
    MediaNotification.showNotification(
        title: title, author: artist, artUri: image, isPlaying: true);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    MediaNotification.showNotification(
        title: title, author: artist, artUri: image, isPlaying: false);
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Color(0xff87b6568),
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: CachedNetworkImageProvider(image),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            title,
                            textScaleFactor: 2.5,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              album + "  |  " + artist,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: accentLight,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(child: _buildPlayer()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer() => Container(
        padding: EdgeInsets.only(top: 15.0, left: 16, right: 16, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (duration != null)
              Slider(
                  activeColor: accent,
                  inactiveColor: Colors.green[50],
                  value: position?.inMilliseconds?.toDouble() ?? 0.0,
                  onChanged: (double value) {
                    return audioPlayer.seek((value / 1000).roundToDouble());
                  },
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble()),
            if (position != null) _buildProgressView(),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isPlaying
                          ? Container()
                          : Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff4db6ac),
                                      //Color(0xff00c754),
                                      Color(0xff61e88a),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(100)),
                              child: IconButton(
                                onPressed: isPlaying ? null : () => play(),
                                iconSize: 40.0,
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 2.2),
                                  child: Icon(Icons.play_arrow),
                                ),
                                color: Color(0xff263238),
                              ),
                            ),
                      isPlaying
                          ? Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff4db6ac),
                                      //Color(0xff00c754),
                                      Color(0xff61e88a),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(100)),
                              child: IconButton(
                                onPressed: isPlaying ? () => pause() : null,
                                iconSize: 40.0,
                                icon: Icon(Icons.pause),
                                color: Color(0xff263238),
                              ),
                            )
                          : Container()
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Builder(builder: (context) {
                      return FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0)),
                          color: Colors.black12,
                          onPressed: () {
                            showBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xff212c31),
                                          borderRadius: BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(18.0),
                                              topRight:
                                                  const Radius.circular(18.0))),
                                      height: 400,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Row(
                                              children: <Widget>[
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.arrow_back_ios,
                                                      color: accent,
                                                      size: 20,
                                                    ),
                                                    onPressed: () => {
                                                          Navigator.pop(context)
                                                        }),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 42.0),
                                                    child: Center(
                                                      child: Text(
                                                        "Lyrics",
                                                        style: TextStyle(
                                                          color: accent,
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          lyrics != "null"
                                              ? Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Center(
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Text(
                                                            lyrics,
                                                            style: TextStyle(
                                                              fontSize: 16.0,
                                                              color:
                                                                  accentLight,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      )),
                                                )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 120.0),
                                                  child: Center(
                                                    child: Container(
                                                      child: Text(
                                                        "No Lyrics available ;(",
                                                        style: TextStyle(
                                                            color: accentLight,
                                                            fontSize: 25),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ));
                          },
                          child: Text(
                            "Lyrics",
                            style: TextStyle(color: accent),
                          ));
                    }),
                  )
                ],
              ),
            ),
          ],
        ),
      );

  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          position != null
              ? "${positionText ?? ''} ".replaceFirst("0:0", "0")
              : duration != null
                  ? durationText
                  : '',
          style: TextStyle(fontSize: 18.0, color: Colors.green[50]),
        ),
        Spacer(),
        Text(
          position != null
              ? "${durationText ?? ''}".replaceAll("0:", "")
              : duration != null
                  ? durationText
                  : '',
          style: TextStyle(fontSize: 18.0, color: Colors.green[50]),
        )
      ]);
}
