import argparse
import os
import cv2

# construct the argument parser and parse the arguments
parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input', required=True, help='Input Image path.')
args = parser.parse_args()

pathInput = os.path.abspath(args.input)
pathOutput = pathInput[0 : pathInput.find('.')] + '.coe'

print("Input: {0}".format(pathInput))

# open the image and generate red, green and black array
imageInput = cv2.imread(pathInput, cv2.IMREAD_UNCHANGED)
(h, w, c) = imageInput.shape

data = []
for i in range(0, h) :
    for j in range(0, w) :
        value = []
        for k in range(0, c) :
            value.append(imageInput[i][j][k])
        data.append(value)

file = open(pathOutput, "w")
file.write("memory_initialization_radix={0};\n".format(16))
file.write("memory_initialization_vector=\n")
for i in data :
    value = hex(i[0])[2] + hex(i[1])[2] + hex(i[2])[2]
    if i[3] == 0 :
        value = value + '0'
    else:
        value = value + 'f'
    file.write(value + '\n')

print("Output: {0}".format(pathOutput))