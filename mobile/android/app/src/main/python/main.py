import argparse
import os
import numpy as np

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

def preprocess(img_path):
    from PIL import Image
    size = (1024, 1024)

    img = Image.open(img_path).convert("RGB")
    img = img.resize(size, Image.BILINEAR)
    x = np.asarray(img, dtype=np.float32)[None, ...]  # (1,1024,1024,3)
    
    # Normalize to [0, 1] range if needed
    x = x / 255.0
    
    # Return as a list that can be easily converted to ByteBuffer
    return x.tolist()

def main(opt):
    x = preprocess_image(opt.basepath + "/initial_img/IMG_0317.jpg")
    print(x.shape)
    print(x)
    #a1,a2,a3=pred(opt,x)
    #a1,a2,a3=pred(opt)
    #classify_three(a1, a2, a3, threshold=8)
