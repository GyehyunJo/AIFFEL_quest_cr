import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quest3',
      home: const FirstPage(),
    );
  }
}

// 첫 번째 페이지
class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool isCat = true; // 고양이 상태를 나타내는 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0), // 앱바 높이 설정
        child: Container(
          color: Colors.white, // 앱바 배경색을 흰색으로 설정
          child: Row(
            children: [
              // 아이콘 상자
              Container(
                width: 70, // 아이콘 컨테이너의 너비
                height: 70, // 아이콘 컨테이너의 높이

                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/cat_icon.jpg'), // 고양이 아이콘 이미지 경로
                    fit: BoxFit.cover, // 이미지가 컨테이너를 꽉 채우도록 설정
                  ),
                ),
              ),
              // 아이콘과 텍스트 사이 검은 선
              Container(
                height: 70, // 아이콘과 같은 높이
                width: 2, // 선의 너비
                color: Colors.black, // 검은색 선
              ),
              const SizedBox(width: 10), // 아이콘과 제목 사이 여백
              // 중앙 제목
              const Expanded(
                // 남은 공간 최대한 활용
                child: Text(
                  'First Page',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  textAlign: TextAlign.center, // 제목을 중앙 정렬
                ),
              ),
              const SizedBox(width: 10), // 우측에 빈 공간 추가
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // 좌우 여백 추가
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 버튼과 이미지를 세로 가운데에 배치
          crossAxisAlignment: CrossAxisAlignment.center, // 좌우 가운데 정렬
          children: [
            // 버튼을 좌우 가운데 정렬
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isCat = false; // isCat 변수를 false로 변경
                  });
                  // 두 번째 페이지로 이동하고 결과를 기다림
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecondPage(isCat: isCat),
                    ),
                  );
                  // 두 번째 페이지에서 돌아올 때 isCat을 true로 재설정
                  if (result == true) {
                    setState(() {
                      isCat = true;
                    });
                  }
                },
                child: const Text('Next'),
              ),
            ),
            const SizedBox(height: 20), // 버튼과 이미지 사이 간격
            // 이미지를 좌우 중앙에 정렬
            Center(
              child: GestureDetector(
                onTap: () {
                  print('isCat: $isCat');
                },
                child: Image.asset(
                  'images/cat.png', // 고양이 이미지
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 두 번째 페이지
class SecondPage extends StatelessWidget {
  final bool isCat;

  const SecondPage({Key? key, required this.isCat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0), // 앱바 높이 설정
        child: Container(
          color: Colors.white, // 앱바 배경색을 흰색으로 설정
          child: Row(
            children: [
              // 좌측 아이콘을 상자에 꽉 채우기
              Container(
                width: 70, // 아이콘 컨테이너의 너비
                height: 70, // 아이콘 컨테이너의 높이

                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/dog_icon.png'), // 강아지 아이콘 이미지 경로
                    fit: BoxFit.cover, // 이미지가 컨테이너를 꽉 채우도록 설정
                  ),
                ),
              ),
              // 아이콘과 텍스트 사이 검은 선
              Container(
                height: 70, // 아이콘과 같은 높이
                width: 2, // 선의 너비
                color: Colors.black, // 검은색 선
              ),
              const SizedBox(width: 10), // 아이콘과 제목 사이 여백
              // 중앙 제목
              const Expanded(
                child: Text(
                  'Second Page',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  textAlign: TextAlign.center, // 제목을 중앙 정렬
                ),
              ),
              const SizedBox(width: 10), // 우측에 빈 공간 추가
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // 좌우 여백 추가
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 버튼과 이미지를 세로 가운데에 배치
          crossAxisAlignment: CrossAxisAlignment.center, // 좌우 가운데 정렬
          children: [
            // 버튼을 좌우 가운데 정렬
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 돌아갈 때 isCat을 true로 전달
                  Navigator.pop(context, true);
                },
                child: const Text('Back'),
              ),
            ),
            const SizedBox(height: 20), // 버튼과 이미지 사이 간격
            // 이미지를 좌우 중앙에 정렬
            Center(
              child: GestureDetector(
                onTap: () {
                  print('isCat: $isCat');
                },
                child: Image.asset(
                  'images/dog.jpg', // 강아지 이미지
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//회고: 중앙에 이미지랑 버튼을 좀 더 아래로 내리고 싶은데 잘 안된다. 아이콘과 앱바를 구분하는 줄이 더 깔끔했으면 좋겠다. 