import os

for root, dirs, files in os.walk('.') :
    for file in files :
        if os.path.splitext(file)[-1] == '.png' :
            os.system("python converter.py -i " + file)

print("Finish.")