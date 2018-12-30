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

#### Size
|Object|Size|
|---|---|
|mario|34x36|
|kong|112x72|
|queue|44x50|
|background|640x480|
|barrelfall|42x24|
|barrelroll|32x24|

#### 楼梯判断
人物中心像素线为基准，地图中梯子部分中心一定宽度进行标记，中心像素线与标记处重叠时判定可以上爬。

#### 倾斜地形判断
人物中心像素线为基准，如果基准线上下有很小的宽度标记为地面，则可以跨过同时人物上移/下移。

#### 地图标记
| 类型 | 标记 |
|---|---|
| 空气 | 0 |
| 障碍 | 1 |
| 梯子 | 2 |

#### 初始化时:
- 人物左下角坐标
- 猩猩左上角坐标
- 公主坐标
- 竖立桶坐标

#### Running:
- 多个木桶位置
- 木桶每帧动作
- 猩猩每帧动作
- Mario 每帧动作
- 公主每帧动作
- 火焰每帧动作

#### Over:
- Mario 死亡动画
- 木桶与火焰消失
- 猩猩动作不变
- 公主动作不变

#### 胜利:
- 显示胜利画面，只有背景
