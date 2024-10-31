from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import requests
import os

app = FastAPI()

class Player(BaseModel):
    name: str
    position: str
    is_starter: bool
    number: int
    red_cards: int = 0

players = []

@app.get("/players/", response_model=List[Player])
def get_players():
    return players

@app.post("/players/")
def add_player(player: Player):
    players.append(player)
    return {"message": f"Player {player.name} added successfully."}

@app.put("/players/{number}/redcard")
def increment_red_card(number: int):
    for player in players:
        if player.number == number:
            player.red_cards += 1
            return {"message": f"Red card for {player.name} incremented to {player.red_cards}."}
    raise HTTPException(status_code=404, detail="Player not found")

@app.put("/players/{number}/reset")
def reset_red_cards(number: int):
    for player in players:
        if player.number == number:
            player.red_cards = 0
            return {"message": f"Red cards for {player.name} reset to 0."}
    raise HTTPException(status_code=404, detail="Player not found")

def get_recommended_number(player):
    # Gemini API 호출 로직 구현
    gemini_api_url = 'https://generativelanguage.googleapis.com/v1beta/models/text-bison-001:generateText'
    gemini_api_key = os.getenv('GEMINI_API_KEY')  # 환경 변수에서 API 키 가져오기

    if not gemini_api_key:
        raise Exception("GEMINI_API_KEY is not set")

    prompt = f"축구 선수 {player.name}의 포지션은 {player.position}입니다. 이 선수에게 적합한 등번호를 추천해 주세요."

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {gemini_api_key}',
    }

    data = {
        'prompt': prompt,
        'max_tokens': 5,
    }

    response = requests.post(gemini_api_url, headers=headers, json=data)

    if response.status_code == 200:
        result = response.json()
        recommended_number = result['candidates'][0]['output'].strip()
        return recommended_number
    else:
        print(f"Gemini API error: {response.status_code} - {response.text}")
        return "N/A"

@app.post("/recommend_number")
def recommend_number(players_list: List[Player]):
    if not players_list:
        raise HTTPException(status_code=422, detail="Players list is empty.")

    recommendations = []
    for player in players_list:
        if not player.name or not player.position or player.number is None:
            raise HTTPException(status_code=422, detail="Player object missing required fields.")
        recommended_number = get_recommended_number(player)
        recommendations.append({"player_name": player.name, "recommended_number": recommended_number})
    return {"recommendations": recommendations}

