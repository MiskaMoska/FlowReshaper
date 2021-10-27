import os
from PIL import Image
import numpy as np

img_h = 260
img_w = 260

os.chdir(".")
img_data_file = r"test_output.txt"

img_data = np.zeros([img_h,img_w,3], dtype = int)

print(img_data.shape)

with open(img_data_file) as file:
    for i,line in enumerate(file):
        img_data[int(int(i / 3) / img_w)][int(i / 3) % img_w][i % 3]= int(line,16)
        # print(int(line,16))

print(type(img_data))
Image.fromarray(np.uint8(img_data)).show() #data二维图片矩阵。