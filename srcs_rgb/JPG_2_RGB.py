import os
import glob
import cv2
import time
import argparse
import numpy as np
from PIL import Image

os.chdir(".")

#choose a transfer mode for the picture
#alternatives: "RGB565","R8","G8","B8"
MODE = "RGB565"

#choose the source and destination path of the picture
input_path = r"test.jpg" #输入jpg文件夹
output_path = r"test.txt" #输出txt根目录

#set the target size of the transfer
target_width = 320
target_length = 240


target_shape = (target_width, target_length) #图片分辨率
img = cv2.imread(input_path)
img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

final_img = np.random.random((target_length,target_width))
image = cv2.resize(img, target_shape)
Image.fromarray(image).show() 

img_target = image / 256
for i in range(0,target_length):
    for j in range(0,target_width):
        for k in range(0,3):
            if k == 0: #Red
                r = int(img_target[i,j,k] * 32)
            if k == 1: #Green
                g = int(img_target[i,j,k] * 64)
            if k == 2: #Blue
                b = int(img_target[i,j,k] * 32)

        if MODE == "RGB565":
            final_img[i,j] = b + g * 32 + r * 2048
        elif MODE == "R8":
            final_img[i,j] = r+100 # make the color lighter 
        elif MODE == "G8":
            final_img[i,j] = g+100 # make the color lighter 
        elif MODE == "B8": 
            final_img[i,j] = b+100 # make the color lighter 

final_img = final_img.flatten()

h_file = open(output_path,"w")
for i in range(0,target_width*target_length):
    temp_data = hex(int(final_img[i]))
    temp_data = temp_data[2:]
    h_file.write("{0}\n".format(temp_data))
    h_file.flush()
print("transferred completed")
