import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWithLocalAsset extends StatefulWidget {
  AudioPlayerWithLocalAsset({ Key? key }) : super(key: key);

  @override
  State<AudioPlayerWithLocalAsset> createState() => _AudioPlayerWithLocalAssetState();
}

class _AudioPlayerWithLocalAssetState extends State<AudioPlayerWithLocalAsset> {
  
  late AudioPlayer audioPlayer = AudioPlayer();
  late AudioCache audioCache = AudioCache();
  late PlayerState playerState = PlayerState.PAUSED;

  String path = 'A Sky Full of Stars.mp3';

  @override
  void initState() {
    super.initState();

    audioCache = AudioCache(fixedPlayer: audioPlayer);
    audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      setState(() {
        playerState = s;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.release();
    audioPlayer.dispose();
    audioCache.clearAll();
  }

  playMusic() async {
    await audioCache.play(path);
  }

  pauseMusic() async {
    await audioPlayer.pause();
  }

  // audioCache.play(path);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 50.0,
                  onPressed: () {
                    playerState == PlayerState.PLAYING
                    ? pauseMusic()
                    : playMusic();
                  },
                  icon: Icon(
                    playerState == PlayerState.PLAYING
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}