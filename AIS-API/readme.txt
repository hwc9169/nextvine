# Scoliosis Angle Estimation from Back View Images

This project estimates three key scoliosis angles from one or more **back-view images** of a person using a deep learning model. The output includes:

- **CA (Proximal Thoracic)**
- **CA (Main Thoracic)**
- **CA (Thoracolumbar or Lumbar)**

> 📌 The current model has an average **absolute error of ~9°**, and it is under continuous development for better accuracy.

---

📦 Installation
Create a virtual environment (optional but recommended):

conda create -n scoliosis python=3.10
conda activate scoliosis

Install dependencies:

pip install -r requirements.txt

### requirements.txt ###
pillow==11.2.1
tensorflow==2.10.0
rembg==2.0.61
tqdm
###




---

## ▶️ How to Run

```bash

python main.py --basepath C:/xxx/xxx/test1

The --basepath must point to a folder that includes a subfolder 'initial_img' containing back-view image(s) of a person, the type is JPG.



📈 Current Performance
Metric	                Value
Avg. Absolute Error	~9.0°