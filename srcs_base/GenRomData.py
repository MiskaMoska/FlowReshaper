import sys
import os
import glob
import numpy as np 

os.chdir(".")
SrcI_filename = r"SrcI.txt" 
SrcJ_filename = r"SrcJ.txt" 
u_filename    = r"u.txt" 
v_filename    = r"v.txt" 

DstI = np.arange(260)  
SrcI = np.arange(260)
DstJ = np.arange(260)  
SrcJ = np.arange(260)
u    = np.arange(260)
v    = np.arange(260)

for i in range(260):
    SrcI[i] = int(DstI[i]*240/260)
    SrcJ[i] = int(DstJ[i]*320/260)
    u[i]    = 256*DstJ[i]*320/260 - 256*int(DstJ[i]*320/260) #256 times magnification
    v[i]    = 256*DstI[i]*240/260 - 256*int(DstI[i]*240/260) #256 times magnification


with open(SrcI_filename,"w") as SrcI_file: 
    for i in range(0,len(SrcI)):
        SrcI_file.write("{0}\n".format(hex(SrcI[i])[2:]))
        SrcI_file.flush()
print("file1 written completed")

with open(SrcJ_filename,"w") as SrcJ_file:
    for i in range(0,len(SrcJ)):
        SrcJ_file.write("{0}\n".format(hex(SrcJ[i])[2:]))
        SrcJ_file.flush()
print("file2 written completed")

with open(u_filename,"w") as u_file:
    for i in range(0,len(u)):
        u_file.write("{0}\n".format(hex(u[i])[2:]))
        u_file.flush()
print("file3 written completed")

with open(v_filename,"w") as v_file:
    for i in range(0,len(v)):
        v_file.write("{0}\n".format(hex(v[i])[2:]))
        v_file.flush()
print("file4 written completed")