import argparse

def parse_opt():
    parser = argparse.ArgumentParser()

    parser.add_argument('--basepath', type=str, default='', help='task base path')
    return parser.parse_args()

def classify_three(a, b, c, threshold=5):
    """
    Classify three numeric inputs into Type0..Type5 based on Straight/Bent pattern.

    Rule:
      - value <= threshold  -> "Straight"
      - value  > threshold  -> "Bent"

    Mapping:
      Type0: Straight-Straight-Straight
      Type1: Straight-Bent-Straight
      Type2: Bent-Bent-Straight
      Type3: Straight-Bent-Bent
      Type4: Bent-Bent-Bent
      Type5: Straight-Straight-Bent

    Any other pattern (e.g., Bent-Straight-Straight, Bent-Straight-Bent) -> Undefined.
    Returns: (type_or_None, labels_list, pattern_string)
    """
    labels = ['Straight' if x <= threshold else 'Bent' for x in (a, b, c)]
    mapping = {
        ('Straight', 'Straight', 'Straight'): 'Normal',
        ('Straight', 'Bent',     'Straight'): 'Thoracic',
        ('Bent',     'Bent',     'Straight'): 'Dobule Thoracic',
        ('Straight', 'Bent',     'Bent')    : 'Double major',
        ('Bent',     'Bent',     'Bent')    : 'Triple curve',
        ('Straight', 'Straight', 'Bent')    : 'Lumbar',
    }
    t = mapping.get(tuple(labels))
    pattern='-'.join(labels)
    if t is None:
        print(f"Result: Undefined pattern ({pattern}). Please define a mapping if needed.")
    else:
        print(f"Result: {t} ({pattern})")

    return t, labels, 

import numpy as np

import os
from PIL import Image
from tensorflow.keras.models import model_from_json



import numpy as np
import os
from PIL import Image


import tensorflow as tf

from rembg import remove
from PIL import Image
import numpy as np
import os
import time
from tqdm import tqdm
import concurrent.futures
import shutil
def process_image(args):
    """处理单个图像并裁剪白边"""
    input_path, output_path = args
    try:
        # 打开图像
        img = Image.open(input_path).convert("RGBA")

        # 限制尺寸（可选）
        max_size = 2000
        if max(img.size) > max_size:
            ratio = max_size / max(img.size)
            new_size = tuple(int(dim * ratio) for dim in img.size)
            img = img.resize(new_size, Image.LANCZOS)

        # 去背景
        img_no_bg = remove(img)

        # 合成白背景
        white_bg = Image.new("RGB", img_no_bg.size, (255, 255, 255))
        white_bg.paste(img_no_bg, mask=img_no_bg.split()[3])

        # ---------- 裁剪非白边区域 ----------
        np_img = np.array(white_bg)
        mask = np.any(np_img != [255, 255, 255], axis=-1)
        coords = np.argwhere(mask)

        if coords.size > 0:
            y0, x0 = coords.min(axis=0)
            y1, x1 = coords.max(axis=0) + 1
            cropped = white_bg.crop((x0, y0, x1, y1))
        else:
            cropped = white_bg  # 若全白，返回原图

        # 保存图像
        cropped.save(output_path, format="JPEG", quality=95)
        return True

    except Exception as e:
        print(f"process img {os.path.basename(input_path)} error: {str(e)}")
        return False

def run_image_segmentation(opt):
    input_folder = os.path.join(opt.basepath, "initial_img")
    output_folder = os.path.join(opt.basepath, "output_frames_seg")
    if os.path.exists(output_folder):
        shutil.rmtree(output_folder)
    os.makedirs(output_folder, exist_ok=True)

    # 收集图像路径对
    image_pairs = []
    for filename in os.listdir(input_folder):
        if filename.lower().endswith(('.jpg', '.jpeg', '.png')):
            input_path = os.path.join(input_folder, filename)
            output_path = os.path.join(output_folder, filename)
            image_pairs.append((input_path, output_path))

    start_time = time.time()

    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        results = list(tqdm(executor.map(process_image, image_pairs),
                            total=len(image_pairs),
                            desc="processing"))

    total_time = time.time() - start_time
    successful = sum(results)
    failed = len(results) - successful

    print("\ndone!")
    print(f"img num: {len(image_pairs)}")
    print(f"success: {successful}")
    print(f"fail: {failed}")
    print(f"time: {total_time:.2f}s")
    print(f"ave time: {total_time / len(image_pairs):.2f}s")


Interpreter = tf.lite.Interpreter

def pred(opt, model_path="./tflite/model_fp32.tflite", normalize=False):
    folder_path = os.path.join(opt.basepath, "output_frames_seg")
    size = (1024, 1024)

    # 收集待预测图片（不一次性堆到内存，逐张跑）
    file_list = [f for f in os.listdir(folder_path)
                 if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
    file_list.sort()

    # 初始化 TFLite 解释器
    interpreter = Interpreter(model_path=model_path, num_threads=4)
    interpreter.allocate_tensors()
    inp = interpreter.get_input_details()[0]
    out = interpreter.get_output_details()[0]

    sum_pred = np.zeros(3, dtype=np.float64)
    count = 0

    for filename in file_list:
        img_path = os.path.join(folder_path, filename)
        img = Image.open(img_path).convert("RGB")
        img = img.resize(size, Image.BILINEAR)

        x = np.asarray(img, dtype=np.float32)[None, ...]  # (1,1024,1024,3)
        if normalize:            # 如果训练时是[0,1]输入，设 normalize=True
            x /= 255.0

        # 如果模型是 int8 输入（fp32 不是），这里会自动量化
        if inp["dtype"] == np.int8:
            scale, zero = inp["quantization"]
            x = np.round(x / scale + zero).astype(np.int8)

        # 如需（重）设 batch 维度
        if tuple(inp["shape"]) != x.shape:
            interpreter.resize_tensor_input(inp["index"], x.shape)
            interpreter.allocate_tensors()
            inp = interpreter.get_input_details()[0]
            out = interpreter.get_output_details()[0]

        interpreter.set_tensor(inp["index"], x)
        interpreter.invoke()
        y = interpreter.get_tensor(out["index"]).squeeze().astype(np.float32)  # (3,)

        # 如果输出是 int8，这里做反量化（fp32 模型不会走到）
        if out["dtype"] == np.int8:
            scale, zero = out["quantization"]
            y = (y - zero) * scale

        sum_pred += y
        count += 1

    mean_pred = (sum_pred / max(count, 1)).astype(np.float32)

    print("Angle 1:", float(mean_pred[0]))
    print("Angle 2:", float(mean_pred[1]))
    print("Angle 3:", float(mean_pred[2]))
    return float(mean_pred[0]), float(mean_pred[1]), float(mean_pred[2])


def main(opt):
    run_image_segmentation(opt)
    a1,a2,a3=pred(opt)
    classify_three(a1, a2, a3, threshold=8)


if __name__ == '__main__':
    opt = parse_opt()
    main(opt)
    # main
 