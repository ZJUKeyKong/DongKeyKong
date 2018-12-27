## DongKey-Kong

Image 里有需要用到的图片以及 png 转 coe 的 python 脚本，依赖 OpenCV。

安装 cv2：

```bash
pip install opencv-python
```

运行脚本转换单个文件，输出文件为输入文件名字将后缀改为 coe：

```bash
python converter.py -i filename
```

将文件夹内所有 png 文件全部转换为 coe 文件：

```bash
python alltrans.py
```

src 内为主要代码。
