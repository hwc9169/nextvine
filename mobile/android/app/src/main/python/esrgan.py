import numpy as np

import os
from PIL import Image
from tensorflow.keras.models import model_from_json



import numpy as np
import os
from PIL import Image


import tensorflow as tf
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































































