import numpy as np

import os
from PIL import Image
from tensorflow.keras.models import model_from_json

def pred(opt) -> tuple[float, float, float]:
    # os.path.join(opt.basepath, "initial_img")
    folder_path=os.path.join(opt.basepath, "output_frames_seg")
    images = []
    filenames = []
    size=(256,256)
    # 遍历所有图片文件
    for filename in os.listdir(folder_path):
        if filename.lower().endswith(('.jpg', '.jpeg', '.png')):
            img_path = os.path.join(folder_path, filename)
            img = Image.open(img_path).convert("RGB")
            img_resized = img.resize(size, Image.BILINEAR)
            img_array = np.array(img_resized) / 255.0  # 归一化
            images.append(img_array)
            filenames.append(filename)
    img_input=np.array(images).reshape(len(images),256,256,3)

    my_model = model_from_json(open('./AandW/esrgan_architecture.json').read()) 
    my_model.load_weights('./AandW/111case135.hdf5')
    
    pred=my_model.predict(img_input)
    
    pred.shape
     
    proximal_thoracic, main_thoracic, lumbar=np.mean(pred[:,0]*40),np.mean(pred[:,1]*65),np.mean(pred[:,2]*70)
    
    print("Angle 1:", proximal_thoracic)
    print("Angle 2:", main_thoracic)
    print("Angle 3:", lumbar)
    return proximal_thoracic.item(), main_thoracic.item(), lumbar.item()
        