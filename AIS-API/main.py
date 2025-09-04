from fastapi import FastAPI


from image_segmentation import run_image_segmentation
from esrgan import pred
from utils import download_image


app = FastAPI()


@app.get("/angle/")
async def pred_angle(image_path: str):
    """
    image_path: the URL of the image 
    """

    # Download the image to tmp
    download_image(image_path)

    opt = type('Opt', (object,), {'basepath': "tmp"})
    run_image_segmentation(opt)
    proximal_thracic, main_thoracic, lumbar = pred(opt)

    return {
        "proximal_thoracic": proximal_thracic,
        "main_thoracic": main_thoracic,
        "lumbar": lumbar
    }
