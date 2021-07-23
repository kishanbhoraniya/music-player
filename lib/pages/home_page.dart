import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:musify/api/player_state.dart';
import 'package:musify/api/saavn.dart';
import 'package:musify/pages/player.dart';
import 'package:musify/style/appColors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;
  bool showPlayer = false;

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
    ),
    Text(
      'Index 1: Business',
    ),
  ];

  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xff1c252a),
      statusBarColor: Colors.transparent,
    ));

    MediaNotification.setListener('play', () {
      setState(() {
        playerState = PlayerState.playing;
        status = 'play';
        audioPlayer.play(kUrl);
      });
    });

    MediaNotification.setListener('pause', () {
      setState(() {
        status = 'pause';
        audioPlayer.pause();
      });
    });

    MediaNotification.setListener("close", () {
      audioPlayer.stop();
      dispose();
      checker = "Nahi";
      setState(() {
        showPlayer = false;
      });
      MediaNotification.hideNotification();
    });
  }

  void dispose(){
    audioPlayer.stop();
    super.dispose();
  }

  getSongDetails(String id, var context) async {
    try {
      await fetchSongDetails(id);
      print(kUrl);
    } catch (e) {
      artist = "Unknown";
      print(e);
    }
    setState(() {
      showPlayer = true;
      checker = "Haa";
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioApp(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
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
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 25.0,
                  ),
                  Center(
                    child: Text(
                      "Musify.",
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _widgetOptions.elementAt(_page),
                  FutureBuilder(
                    future: topSongs(),
                    builder: (context, data) {
                      if (data.hasData)
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 30.0, bottom: 10, left: 8),
                                child: Text(
                                  "Top 15 Songs",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                //padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                                height: 185.0,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 15,
                                  itemBuilder: (context, index) {
                                    return getTopSong(
                                        data.data[index]["image"],
                                        data.data[index]["title"],
                                        data.data[index]["more_info"]
                                        ["artistMap"]
                                        ["primary_artists"][0]["name"],
                                        data.data[index]["id"]);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(35.0),
                            child: CircularProgressIndicator(
                              valueColor:
                              new AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ));
                    },
                  ),

                ],
              ),
            ),
          ),
         showPlayer ?
          Positioned(
            bottom: 0.5,
            child: GestureDetector(
              onTap: (){
                checker = "Nahi";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AudioApp(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: bottomNavColor,
                ),
                width: MediaQuery.of(context).size.width,
                height: 60.0,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: accent,
                        size: 26,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        album,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.play_arrow,
                        color: accent,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ) : Container(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: bottomNavColor,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _page,
          onTap: (int index) {
            setState(() {
              this._page = index;
            });
          },
          unselectedItemColor: Color(0xffb0b5b1),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search')
          ],
        ),
      ),
    );
  }

  Widget getTopSong(String image, String title, String subtitle, String id) {
    return InkWell(
      onTap: () {
        getSongDetails(id, context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.0),
        // height: MediaQuery.of(context).size.height * 0.30,
        child: Column(
          children: [
            Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: Colors.transparent,
                child: SizedBox(
                  height: 100.0,
                  width: 100.0,
                  child: Image(
                    image: NetworkImage(image),
                    fit: BoxFit.fitHeight,
                  ),
                )),
            SizedBox(
              height: 2,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(
                title
                    .split("(")[0]
                    .replaceAll("&amp;", "&")
                    .replaceAll("&#039;", "'")
                    .replaceAll("&quot;", "\""),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
