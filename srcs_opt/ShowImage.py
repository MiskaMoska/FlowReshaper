import os
from PIL import Image
import numpy as np

img_h = 260
img_w = 260

os.chdir(".")
img_data_file = r"test_output.txt"

img_data = np.empty([img_h,img_w], dtype = int, order = 'C')

with open(img_data_file) as file:
    for i,line in enumerate(file):
        img_data[int(i / img_w)][i % img_w] = int(line,16)
        # print(int(line,16))


new_im = Image.fromarray(img_data) #data二维图片矩阵。

new_im.show()