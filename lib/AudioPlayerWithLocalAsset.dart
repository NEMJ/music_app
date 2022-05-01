import 'dart:io';

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

  int timeProgress = 0;
  int audioDuration = 0;

  Widget slider() {
    return Container(
      width: 300,
      child: Slider.adaptive(
        value: (timeProgress/1000).floorToDouble(),
        max: (audioDuration/1000).floorToDouble(),
        onChanged: (value) {
          seekToSec(value.toInt());
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    audioCache = AudioCache(fixedPlayer: audioPlayer);
    audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      setState(() {
        playerState = s;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      setState(() {
        timeProgress = p.inMilliseconds;
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(getTimeString(timeProgress)),
                      SizedBox(width: 20),
                      slider(),
                      SizedBox(width: 20),
                      audioDuration == 0
                        ? getFileAudioDuration()
                        : Text(getTimeString(audioDuration)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget getFileAudioDuration() {
    return FutureBuilder(
      future: _getAudioDuration(),
      builder: (
        BuildContext context,
        AsyncSnapshot<int> snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return Text(getTimeString(snapshot.data!));
          }
          return Text('');
        });
  }

  Future<int> _getAudioDuration() async {
    File audioFile = await audioCache.load(path) as File;
    await audioPlayer.setUrl(audioFile.path);
    audioDuration = await Future.delayed(Duration(seconds: 2), () => audioPlayer.getDuration());
    return audioDuration;
  }

  String getTimeString(int milliseconds) {
    if(milliseconds == null) milliseconds = 0;
    String minutes =
      '${(milliseconds / 60000).floor() < 10 ? 0 : ''}${(milliseconds / 60000).floor()}';
    String seconds = 
      '${(milliseconds / 1000).floor() % 60 < 10 ? 0 : ''}${(milliseconds / 1000).floor() % 60}';
    return '$minutes:$seconds';
  }

  void seekToSec(int sec) {
    Duration newPosition = Duration(seconds: sec);
    audioPlayer.seek(newPosition);
  }
}