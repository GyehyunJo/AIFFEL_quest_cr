import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = "";
  final String apiUrl =
      "https://3c0a-121-129-161-110.ngrok-free.app"; // 서버의 엔드포인트

  Future<void> fetchPrediction() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictedClass = data['class'];
        final confidence = data['confidence'];

        // 예측 결과와 확률을 각각 다른 버튼으로 출력
        print("Predicted Class: $predictedClass");
        print("Confidence: $confidence");

        setState(() {
          result = "Prediction: $predictedClass\nConfidence: $confidence";
        });
      } else {
        setState(() {
          result = "Failed to fetch data. Status Code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jellyfish Classifier"),
        leading: Icon(Icons.image), // 해파리 아이콘 위치
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'sample_data/jellyfish.jpg', // 이미지 표시
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchPrediction,
              child: Text("예측 결과 출력"),
            ),
            ElevatedButton(
              onPressed: () async {
                await fetchPrediction();
                // 확률만 출력
                final data = jsonDecode(result);
                print("Confidence Only: ${data['confidence']}");
              },
              child: Text("예측 확률 출력"),
            ),
            SizedBox(height: 20),
            Text(
              result,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
