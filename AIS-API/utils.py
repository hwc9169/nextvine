
import requests
import os


def download_image(url, folder="tmp/initial_img"):
    if not os.path.exists(folder):
        os.makedirs(folder)

    response = requests.get(url)
    if response.status_code == 200:
        file_path = os.path.join(folder, "downloaded_image.jpg")
        with open(file_path, 'wb') as f:
            f.write(response.content)


if __name__ == "__main__":
    image_url = "https://firebasestorage.googleapis.com/v0/b/nextvine-b2705.firebasestorage.app/o/scoliosis%2Fvideos%2F1752822570565-CAP1226559537924977283.jpg?alt=media&token=300bc027-024c-46a7-a281-5abee71b6f35"
    download_image(image_url)
