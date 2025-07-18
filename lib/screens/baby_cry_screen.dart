import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import '../services/auth_service.dart';
import 'dart:typed_data';


class BabySoundScreen extends StatefulWidget {
  final AuthService authService;

  const BabySoundScreen({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  State<BabySoundScreen> createState() => _BabySoundScreenState();
}


class _CryAnalysisResult {
  final String reason;
  final DateTime time;
  _CryAnalysisResult(this.reason, this.time);
}

class _BabySoundScreenState extends State<BabySoundScreen> {
  final List<_CryAnalysisResult> _history = [];
  final recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  File? _lastRecordedFile;

  final Map<String, IconData> _reasonIcons = {
    'belly pain': Icons.favorite,
    'burping': Icons.air,
    'cold_hot': Icons.ac_unit,
    'discomfort': Icons.sentiment_dissatisfied,
    'tired': Icons.bedtime,
  };

  _CryAnalysisResult? _latestResult;

  @override
  void initState() {
    super.initState();
    recorder.openRecorder();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      await Permission.microphone.request();
      await Permission.storage.request();
    }
  }

  Future<String> _getTempFilePath() async {
    final dir = await getTemporaryDirectory();
    return path.join(dir.path, 'recorded.wav');
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await recorder.stopRecorder();
      setState(() => _isRecording = false);

      final filePath = await _getTempFilePath();
      _lastRecordedFile = File(filePath);

      await _analyzeCry(_lastRecordedFile!);
    } else {
      final path = await _getTempFilePath();
      await recorder.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
      );
      setState(() => _isRecording = true);
    }
  }

  Future<void> _analyzeCry(File file) async {
  try {
    final url = Uri.parse('http://127.0.0.1:8000/analyze-cry/');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final decoded = jsonDecode(responseBody);
      final predicted = decoded['predicted_label'];
      final result = _CryAnalysisResult(predicted, DateTime.now());

      if (mounted) {
        setState(() {
          _latestResult = result;
          _history.insert(0, result);
        });
      }

      await _saveAnalysisToBackend(predicted);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("التنبؤ: $predicted")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to analyze crying")),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: ${e.toString()}")),
      );
    }
  }
}

  Future<void> _pickAudioFile() async {
    if (kIsWeb) {
      _pickAudioFileWeb();
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _analyzeCry(file);
      }
    }
  }

void _pickAudioFileWeb() {
  final input = html.InputElement()..type = 'file'..accept = 'audio/*';
  input.click();
  input.onChange.listen((event) async {
    try {
      final file = input.files!.first;
      final reader = html.FileReader();
      
      reader.onError.listen((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File read error")),
          );
        }
        print("FileReader error: $error");
      });

      reader.readAsArrayBuffer(file);
      await reader.onLoadEnd.first;

      if (reader.result != null) {
        final bytes = Uint8List.fromList(reader.result as List<int>);
        await _analyzeCryWeb(bytes, file.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: ${e.toString()}")),
        );
      }
      print("Upload error: $e");
    }
  });
}

Future<void> _analyzeCryWeb(Uint8List bytes, String fileName) async {
  try {
    final url = Uri.parse('http://127.0.0.1:8000/analyze-cry/');
    final request = http.MultipartRequest('POST', url);
    
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
    ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final decoded = jsonDecode(responseBody);
      final predicted = decoded['predicted_label'];
      final result = _CryAnalysisResult(predicted, DateTime.now());

      if (mounted) {
        setState(() {
          _latestResult = result;
          _history.insert(0, result);
        });
      }

      await _saveAnalysisToBackend(predicted);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("The Prediction is: $predicted")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Analysis failure: ${response.statusCode}")),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: ${e.toString()}")),
      );
    }
    print("Error details: $e"); //  سيطبع التفاصيل في الكونسول
  }
}


Future<void> _saveAnalysisToBackend(String reason) async {
  final token = widget.authService.token;
  final babyId = widget.authService.selectedBabyId;

  if (token == null || babyId == null) {
    print("Token أو Baby ID un avilable");
    return;
  }

  try {
    final url = Uri.parse('http://localhost:3000/api/babies/cry-analysis/$babyId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      print("تم حفظ التحليل في قاعدة البيانات");
    } else {
      print("فشل في حفظ التحليل: ${response.body}");
      throw Exception('Failed to save analysis');
    }
  } catch (e) {
    print('Error saving to backend: $e');
    rethrow;
  }
}

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل بكاء الطفل'),
        backgroundColor: primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: "اختيار تسجيل صوتي",
            onPressed: _pickAudioFile,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleRecording,
        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
        label: Text(_isRecording ? "إيقاف التسجيل" : "تسجيل"),
        backgroundColor: primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_latestResult != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _reasonIcons[_latestResult!.reason] ?? Icons.help,
                      size: 40,
                      color: primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "التحليل الأخير: ${_latestResult!.reason}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'التاريخ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text("لا يوجد تحليل سابق"))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final entry = _history[index];
                        return ListTile(
                          leading: Icon(
                            _reasonIcons[entry.reason] ?? Icons.help_outline,
                            color: primary,
                          ),
                          title: Text(entry.reason),
                          subtitle: Text(
                            "${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')} - ${entry.time.day}/${entry.time.month}/${entry.time.year}",
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
