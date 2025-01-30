import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'dart:io';

class RecordComp extends StatefulWidget {
  const RecordComp({super.key});

  @override
  State<RecordComp> createState() => _RecordCompState();
}

class _RecordCompState extends State<RecordComp> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _filePath;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      color: Colors.amber,
      child: Column(
        children: <Widget>[
          const Text(
            'Record Component',
            style: TextStyle(color: Colors.red),
          ),
          ElevatedButton(
            onPressed: _isRecording ? _stopRecording : _startRecording,
            child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
          ),
          if (_filePath != null)
            ElevatedButton(
              onPressed: _isPlaying ? null : _playRecording,
              child: Text(_isPlaying ? 'Playing...' : 'Play Recording'),
            ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final randomString = _generateRandomString(10);
        final path = p.join(directory.path, '$randomString.m4a');

        // Add more detailed configuration
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
        });
        debugPrint('Recording started: $path');
      } else {
        debugPrint('No permission to record');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No permission to record')),
        );
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting recording: $e')),
      );
    }
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  Future<void> _stopRecording() async {
    try {
      _filePath = await _recorder.stop();
      setState(() {
        _isRecording = false;
      });

      // Verify file exists and has content
      if (_filePath != null) {
        final file = File(_filePath!);
        if (await file.exists()) {
          final fileSize = await file.length();
          debugPrint('Recording stopped. File saved at: $_filePath');
          debugPrint('File size: $fileSize bytes');
          if (fileSize == 0) {
            debugPrint('Warning: File is empty!');
          }
        } else {
          debugPrint('Error: File does not exist after recording!');
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  Future<void> _playRecording() async {
    if (_filePath != null && await File(_filePath!).exists()) {
      try {
        setState(() {
          _isPlaying = true;
        });

        await _audioPlayer.setFilePath(_filePath!);

        // Add listener for playback state
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
            });
          }
        });

        // Set volume to maximum
        await _audioPlayer.setVolume(1.0);

        await _audioPlayer.play();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playing recording...')),
        );
      } catch (e) {
        setState(() {
          _isPlaying = false;
        });
        debugPrint('Error playing recording: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing recording: $e')),
        );
      }
    } else {
      debugPrint('Recording file not found: $_filePath');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording file not found')),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recorder.dispose();
    super.dispose();
  }
}
