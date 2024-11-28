import os
import cv2
import json
import argparse
import numpy as np
from glob import glob
from pathlib import Path
from PySide6.QtCore import QSettings

# QSettings 초기화
setting = QSettings("test", "test")
print(f"마지막으로 저장한 Index: {setting.value('CurrentIndex')}")

# 명령줄 인수 처리
parser = argparse.ArgumentParser()
parser.add_argument("-g", "--go", dest="go", action="store_true")
args = parser.parse_args()

# 초기화
drawing = False
ix, iy = -1, -1
img_copy = None
if args.go:
    current_img_index = setting.value("CurrentIndex") - 1
else:
    current_img_index = 0
point_list = []
polygon_points = []
object_point = []
erase_mode = False
polygon_mode = False


# 거리 계산 함수
def distance(pt1, pt2):
    return np.sqrt((pt1[0] - pt2[0]) ** 2 + (pt1[1] - pt2[1]) ** 2)


# 마우스 콜백 함수
def draw_point(event, x, y, flags, param):
    global ix, iy, drawing, img_copy, point_list, object_point

    if polygon_mode:
        if event == cv2.EVENT_LBUTTONDOWN:
            polygon_points.append([x, y])
            cv2.circle(img, (x, y), 1, (0, 255, 0), 2)
            cv2.imshow('image', img)

            if len(polygon_points) > 1:
                for i in range(len(polygon_points) - 1):
                    pt1 = tuple(polygon_points[i])
                    pt2 = tuple(polygon_points[i + 1])
                    cv2.line(img, pt1, pt2, (0, 255, 0), 1)
            cv2.imshow('image', img)
            if len(polygon_points) == 4:
                cv2.line(img, tuple(polygon_points[-1]), tuple(polygon_points[0]), (0, 255, 0), 1)
                height, width, _ = img.shape
                normalized_points = [0, ]
                for point in polygon_points:
                    x = round(point[0] / width, 6)
                    y = round(point[1] / height, 6)
                    normalized_points.extend([x, y])
                print(normalized_points)
                cv2.imshow('image', img)

    elif erase_mode:
        if event == cv2.EVENT_LBUTTONDOWN:
            click_point = (x, y)
            threshold = 8

            for points in point_list:
                for point in points:
                    dist = distance(click_point, point)
                    if dist <= threshold:
                        print(f"Point: {points}")
    else:
        if event == cv2.EVENT_LBUTTONDOWN:
            drawing = True
            ix, iy = x, y
            img_copy = img.copy()

        elif event == cv2.EVENT_LBUTTONUP:
            drawing = False
            object_point.extend([[ix, iy]])
            if len(object_point) % 2 == 0:
                point_list.append(object_point)
                object_point = []
            cv2.circle(img, (ix, iy), 1, (0, 0, 255), 1)
            cv2.imshow('image', img)


# 이미지 경로 설정
base_path = "/Users/gyehyun/Desktop/flutter1/flutter2/dlthon/dlthon/sample_data"
result_folders = glob(os.path.join(base_path, "result_*"))
result_folders.sort()

image_files = []
for folder in result_folders:
    images = []
    for ext in ['*.jpg', '*.jpeg', '*.png', '*.bmp']:
        images.extend(glob(os.path.join(folder, ext)))
    image_files.extend(sorted(images))

if not image_files:
    print("No images found in the specified directories")
    exit()

# OpenCV 창 초기화
cv2.namedWindow('image', cv2.WINDOW_FULLSCREEN)
cv2.setMouseCallback('image', draw_point)


# 현재 이미지 표시
def show_current_image():
    global img, img_copy, point_list

    img = cv2.imread(image_files[current_img_index])
    img_copy = img.copy()
    print(f"\nCurrent image: {image_files[current_img_index]}")

    # Path 객체 사용
    current_path = Path(image_files[current_img_index])
    folder_name = current_path.parent.name  # 상위 디렉토리 이름
    timestamp = folder_name.split("_")[-1]  # 디렉토리 이름에서 timestamp 추출

    if os.path.isfile(f"{result_folders[current_img_index]}/{timestamp}.json"):
        isfile = "O"
        with open(f"{result_folders[current_img_index]}/{timestamp}.json", "r") as f:
            pt = json.load(f)
            points = pt["points"]
            point_list = points
        for point in points:
            for x, y in point:
                cv2.circle(img, (x, y), 1, (0, 0, 255), 2)
            text_size, _ = cv2.getTextSize(f"{x, y}", cv2.FONT_ITALIC, 0.4, 1)
            text_w, text_h = text_size
            cv2.rectangle(img, (x, y), (x + text_w, y - text_h), (255, 255, 255), -1)
            cv2.putText(img, f"{x, y}", (x, y), cv2.FONT_ITALIC, 0.4, (0, 0, 255), 1)

    else:
        isfile = "X"

    print(f"Image {current_img_index + 1}/{len(image_files)} [{isfile}]")

    cv2.imshow('image', img)
    image_name = folder_name
    cv2.imwrite(f"images/{image_name}.jpg", img)


def save_point():
    global data, point_list

    timestamp = Path(image_files[current_img_index]).parent.name.split("_")[-1]
    data = {"points": point_list}
    path = Path(image_files[current_img_index]).parent

    with open(f"{path}/{timestamp}.json", "w") as f:
        json.dump(data, f, indent=4)
    print('Saved boxes')

    setting.setValue("CurrentIndex", current_img_index + 1)


def erase_point():
    global erase_mode
    erase_mode = not erase_mode
    if erase_mode:
        print('Erase mode')


def create_polygon():
    global polygon_mode, polygon_points
    print('Create Polygon Mode')
    polygon_mode = not polygon_mode
    polygon_points = []


def clear_box():
    global point_list
    point_list.clear()


# 실행 루프
show_current_image()

while True:
    key = cv2.waitKey(1) & 0xFF

    if key == ord('a'):
        current_img_index = (current_img_index - 1) % len(image_files)
        clear_box()
        show_current_image()

    elif key == ord('d'):
        current_img_index = (current_img_index + 1) % len(image_files)
        clear_box()
        show_current_image()

    elif key == ord('p'):
        print(point_list)

    elif key == ord('s'):
        save_point()

    elif key == ord('e'):
        erase_point()

    elif key == ord('c'):
        show_current_image()
        clear_box()

    elif key == ord('o'):
        create_polygon()

    elif key == 27 or key == ord('q'):
        break

cv2.destroyAllWindows()
