import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Processing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageProcessingScreen(),
    );
  }
}

class ImageProcessingScreen extends StatefulWidget {
  @override
  _ImageProcessingScreenState createState() => _ImageProcessingScreenState();
}

class _ImageProcessingScreenState extends State<ImageProcessingScreen> {
  Uint8List? _pickedImageBytes; // 선택한 이미지 바이트
  Uint8List? _processedImageBytes; // 처리된 이미지 바이트
  String? _uploadedCoordinates; // 업로드된 좌표 (JSON)

  // 이미지 선택
  Future<void> _pickImage() async {
    print("Pick Image button pressed."); // 디버깅 로그
    final pickedFile =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (pickedFile != null) {
      print("Image selected: ${pickedFile.files.single.name}"); // 디버깅 로그
      setState(() {
        _pickedImageBytes = pickedFile.files.single.bytes;
      });
    } else {
      print("No image selected.");
    }
  }

  // JSON 파일 업로드
  Future<void> _uploadCoordinates() async {
    print("Upload Coordinates button pressed."); // 디버깅 로그
    final pickedFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['json']);

    if (pickedFile != null) {
      final fileBytes = pickedFile.files.single.bytes!;
      final fileName = pickedFile.files.single.name;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/upload-coordinates/'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        setState(() {
          _uploadedCoordinates =
              jsonDecode(responseBody)['coordinates'].toString();
        });
        print("Coordinates uploaded successfully!");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } else {
      print("No file selected.");
    }
  }

  // 서버로 이미지 처리 요청
  Future<void> _processImage() async {
    print("Process Image button pressed."); // 디버깅 로그
    if (_pickedImageBytes == null) {
      print("No image selected to process.");
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/process-image/'), // 서버 URL
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        _pickedImageBytes!,
        filename: 'uploaded_image.png',
      ),
    );

    try {
      final response = await request.send();

      print("Request sent to server...");
      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = await response.stream.toBytes();
        setState(() {
          _processedImageBytes = responseBody;
        });
        print("Image processed successfully.");
      } else {
        print("Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("HTTP request failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Processing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _uploadCoordinates,
              child: Text('Upload Coordinates (JSON)'),
            ),
            if (_uploadedCoordinates != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Uploaded Coordinates: $_uploadedCoordinates",
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            if (_pickedImageBytes != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("Selected Image:"),
                    Image.memory(
                      _pickedImageBytes!,
                      height: 200,
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: _processImage,
              child: Text('Process Image'),
            ),
            if (_processedImageBytes != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("Processed Image:"),
                    Image.memory(
                      _processedImageBytes!,
                      height: 200,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
