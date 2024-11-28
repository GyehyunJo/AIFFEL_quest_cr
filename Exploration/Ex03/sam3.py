from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
import numpy as np
import cv2
from PIL import Image
from sam2.automatic_mask_generator import SAM2AutomaticMaskGenerator
import os
from fastapi.middleware.cors import CORSMiddleware
import json

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인에서의 요청 허용
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드 허용 (GET, POST 등)
    allow_headers=["*"],  # 모든 요청 헤더 허용
)


# SAM2 모델 초기화
mask_generator = SAM2AutomaticMaskGenerator.from_pretrained("facebook/sam2-hiera-large", device="cpu")

# 결과 이미지 저장 경로
output_dir = "output"
os.makedirs(output_dir, exist_ok=True)

# JSON 파일 저장 경로
json_dir = "json_files"
os.makedirs(json_dir, exist_ok=True)

@app.post("/upload-coordinates/")
async def upload_coordinates(file: UploadFile = File(...)):
    try:
        # JSON 파일 저장
        json_path = os.path.join(json_dir, file.filename)
        with open(json_path, "wb") as buffer:
            buffer.write(await file.read())

        # JSON 파일 내용 읽기
        with open(json_path, "r") as f:
            coordinates = json.load(f)

        print(f"Uploaded Coordinates: {coordinates}")  # 디버깅용 로그
        return {"message": "Coordinates uploaded successfully!", "coordinates": coordinates}

    except Exception as e:
        print(f"Error: {e}")  # 디버깅용 로그
        return {"error": str(e)}


@app.post("/process-image/")
async def process_image(file: UploadFile = File(...)):
    # 이미지 로드
    input_image_path = os.path.join(output_dir, file.filename)
    with open(input_image_path, "wb") as buffer:
        buffer.write(await file.read())
    
    image = np.array(Image.open(input_image_path).convert("RGB"))

    # JSON 파일 경로 지정 (마지막 업로드된 JSON 파일)
    json_files = sorted(os.listdir(json_dir), key=lambda x: os.path.getctime(os.path.join(json_dir, x)))
    if not json_files:
        return {"error": "No coordinates JSON file found. Please upload a JSON file first."}

    latest_json_path = os.path.join(json_dir, json_files[-1])

    # JSON 파일에서 좌표 읽기
    with open(latest_json_path, "r") as f:
        coordinates = json.load(f)
        points = coordinates.get("points", [])  # 좌표 리스트

    if not points:
        return {"error": "No valid points found in the JSON file."}

    print(f"Using points from JSON: {points}")

    # SAM2로 마스크 생성
    masks = mask_generator.generate(image)

    # 사람 영역 마스크 병합
    height, width, _ = image.shape
    people_mask = np.zeros((height, width), dtype=np.uint8)

    for mask in masks:
        mask_segmentation = mask["segmentation"]

        # 각 사각형 영역과 마스크가 겹치는지 확인
        for person in points:
            x1, y1 = person[0]
            x2, y2 = person[1]
            if np.any(mask_segmentation[y1:y2, x1:x2]):
                people_mask = np.logical_or(people_mask, mask_segmentation).astype(np.uint8)

    # 배경 마스크 생성
    background_mask = np.logical_not(people_mask)

    # 배경 블러 처리
    background_blur = cv2.GaussianBlur(image, (25, 25), 0)
    result_image = image.copy()
    result_image[background_mask] = background_blur[background_mask]

    # 결과 이미지 저장
    output_image_path = os.path.join(output_dir, f"processed_{file.filename}")
    Image.fromarray(result_image).save(output_image_path)

    # 결과 이미지 반환
    return FileResponse(output_image_path, media_type="image/png", filename=f"processed_{file.filename}")
