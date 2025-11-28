# YOLO_HeartOfSteel

检测金属表面的缺陷。

## 功能

检测六种金属表面缺陷：

- 龟裂（crazing）
- 夹杂物（inclusion）
- 斑痕（patches）
- 点蚀（pitted surface）
- 轧入氧化皮（rolled-in scale）
- 划痕（scratches）

## 安装

安装所需依赖：
```
pip install -r requirements.txt
```

训练需要[东北大学钢材检测数据集NEU-DET](https://aistudio.baidu.com/datasetdetail/195425)，需要下载并解压在项目根目录。

## 运行

运行 `main.py`，例如：

```powershell
python main.py
```

## FAQ

### CUDA Out of Memory

显存不足，可以尝试重启。可能硬件性能不足。

### MemoryError、OSError: [WinError 1455]、[WinError 1114]

可能是虚拟内存不足，尝试分配更多虚拟内存：

- `Win`+`R` 输入 `sysdm.cpl`
- 高级→性能→设置→高级→虚拟内存→更改

修改后需要重启。

