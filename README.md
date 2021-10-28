# FlowReshaper

This is an hardware image-reshaping unit designed by verilog and simulated based on Vivado.The design adopts dataflow calculation architecture and is implemented through a  7-stage pipeline structure.

Click [here](https://zhuanlan.zhihu.com/p/425191429) to view a more concrete introduction of the design. 

## src_base

Baseline design which performs reshaping a grayscale image.

## src_opt

Optimized design which realizes boosting of clock frequency by tuning the pipeline structure.

## src_rgb

Final design based on the former one,achieves reshaping RGB images through exploiting parallel calculation of 3 data channels.

### [NOTICE] Make sure to change the paths in "test_FlowReshaper.v" and "FlowReshaper.v" in each folder according to your own project environment.