import argparse
from image_segmentation import run_image_segmentation
from esrgan import pred

def parse_opt():
    parser = argparse.ArgumentParser()

    parser.add_argument('--basepath', type=str, default='', help='task base path')
    return parser.parse_args()

def main(opt):
    run_image_segmentation(opt)
    pred(opt)


if __name__ == '__main__':
    opt = parse_opt()
    main(opt)
    # main
