import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'player.dart';
import 'add.dart';

final String baseUrl = 'https://41a8-121-129-161-110.ngrok-free.app';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Player> players = [];

  // 서버에서 선수 목록 가져오기
  Future<void> fetchPlayers() async {
    final response = await http.get(Uri.parse('$baseUrl/players/'));
    if (response.statusCode == 200) {
      setState(() {
        players = (json.decode(response.body) as List)
            .map((data) => Player.fromJson(data))
            .toList();
      });
    } else {
      print("Failed to load players: ${response.statusCode}");
    }
  }

  // 레드카드 개수 증가 - 선수별 업데이트
  Future<void> incrementRedCard(int number) async {
    final response =
        await http.put(Uri.parse('$baseUrl/players/$number/redcard'));
    if (response.statusCode == 200) {
      setState(() {
        final player = players.firstWhere((p) => p.number == number);
        player.redCards += 1; // 레드카드 수만 부분적으로 업데이트
      });
    } else {
      print(
          "Failed to increment red card for player $number: ${response.statusCode}");
    }
  }

  // 레드카드 개수 초기화 - 선수별 업데이트
  Future<void> resetRedCards(int number) async {
    final response =
        await http.put(Uri.parse('$baseUrl/players/$number/reset'));
    if (response.statusCode == 200) {
      setState(() {
        final player = players.firstWhere((p) => p.number == number);
        player.redCards = 0; // 레드카드 수만 부분적으로 업데이트
      });
    } else {
      print(
          "Failed to reset red cards for player $number: ${response.statusCode}");
    }
  }

  // 서버에 선수 리스트를 보내서 등번호 추천 받기
  Future<void> recommendJerseyNumbers() async {
    final playerData = players.map((player) => player.toJson()).toList();
    print("Request Body: ${json.encode(playerData)}");
    final response = await http.post(
      Uri.parse('$baseUrl/recommend_number'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(playerData),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final recommendations = responseData['recommendations'];

      // 추천 결과를 사용자에게 보여줍니다.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("추천 등번호"),
            content: SingleChildScrollView(
              child: ListBody(
                children: recommendations.map<Widget>((recommendation) {
                  return Text(
                      "${recommendation['player_name']}: ${recommendation['recommended_number']}");
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                child: Text("닫기"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      print("Failed to get recommendation: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Football Player Management"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _navigateToAddEditPlayer(),
          ),
        ],
      ),
      body: players.isEmpty
          ? Center(child: Text("No players added yet."))
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return ListTile(
                  title: Text(player.name),
                  subtitle: Text(
                      "Position: ${player.position} | Number: ${player.number}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.warning, color: Colors.red),
                        onPressed: () {
                          incrementRedCard(player.number);
                        },
                      ),
                      Text("${player.redCards}"),
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.blue),
                        onPressed: () {
                          resetRedCards(player.number);
                        },
                      ),
                    ],
                  ),
                  onTap: () => _navigateToAddEditPlayer(player),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: recommendJerseyNumbers,
          child: Text("등번호 추천"),
        ),
      ),
    );
  }

  // 선수 추가 및 수정 화면으로 이동
  void _navigateToAddEditPlayer([Player? player]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPlayerPage(
          player: player,
          onSave: (updatedPlayer) {
            setState(() {
              if (player == null) {
                players.add(updatedPlayer);
              } else {
                int index = players.indexOf(player);
                players[index] = updatedPlayer;
              }
            });
          },
        ),
      ),
    );
  }
}
