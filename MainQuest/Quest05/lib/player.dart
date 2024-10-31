class Player {
  String name;
  String position; // GK, DF, MF, FW
  bool isStarter; // true면 주전, false면 벤치
  int number;
  int redCards;

  Player({
    required this.name,
    required this.position,
    required this.isStarter,
    required this.number,
    this.redCards = 0,
  });

  // JSON 데이터를 Player 객체로 변환
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      isStarter: json['is_starter'] ?? false,
      number: json['number'] ?? 0,
      redCards: json['red_cards'] ?? 0,
    );
  }

  // Player 객체를 JSON 데이터로 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'is_starter': isStarter,
      'number': number,
      'red_cards': redCards,
    };
  }

  // 레드카드 개수 증가
  void incrementRedCard() {
    redCards += 1;
  }

  // 레드카드 개수 초기화
  void resetRedCards() {
    redCards = 0;
  }
}
