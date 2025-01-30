import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'dart:io';

class RecordComp extends StatefulWidget {
  final Function(MultipartFile?) onFileChanged;

  const RecordComp({
    super.key,
    required this.onFileChanged,
  });

  @override
  State<RecordComp> createState() => _RecordCompState();
}

class _RecordCompState extends State<RecordComp> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _filePath;
  bool _isPlaying = false;
  int _recordingTime = 0;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingTime++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? Colors.redAccent[200] : Colors.white,
              border: Border.all(
                color: _isRecording ? Colors.red : Colors.grey,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 32,
                        color: _isRecording ? Colors.red : Colors.grey[700],
                      ),
                      if (_isRecording || _recordingTime > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _formatTime(_recordingTime),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _isRecording ? Colors.red : Colors.grey[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_filePath != null && !_isRecording)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton.icon(
                onPressed: _isPlaying ? null : _playRecording,
                icon: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow),
                label: Text(_isPlaying ? 'Playing...' : 'Play Recording'),
              ),
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
          _recordingTime = 0;
        });
        widget.onFileChanged(null); // Clear previous file
        _startTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No permission to record'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting recording: $e'),
          backgroundColor: Colors.red,
        ),
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
      _stopTimer();

      if (_filePath != null) {
        final file = File(_filePath!);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recording failed: Empty file'),
                backgroundColor: Colors.red,
              ),
            );
            widget.onFileChanged(null);
          } else {
            // Convert File to MultipartFile
            final bytes = await file.readAsBytes();
            final multipartFile = MultipartFile.fromBytes(
              'audio_note',
              bytes,
              filename: 'audio_note.m4a',
            );
            widget.onFileChanged(multipartFile);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recording saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      widget.onFileChanged(null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error stopping recording: $e'),
          backgroundColor: Colors.red,
        ),
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
        await _audioPlayer.setVolume(1.0);

        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
            });
          }
        });

        await _audioPlayer.play();
      } catch (e) {
        setState(() {
          _isPlaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording file not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _recorder.dispose();
    super.dispose();
  }
}
