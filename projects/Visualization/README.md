# Visualization

可视化了两种经典的监督学习与无监督学习算法。

## 功能

此项目可以生成两簇平面上的点，并展示逻辑回归以及 K-means 聚类的效果。

- 在第一个代码块中可以设置参数，调整数据分布情况以及逻辑回归和 K-means 聚类的超参数。
- 第二个代码块实现了逻辑回归，并将逻辑回归参数对应的直线显示在平面上。
- 第三个代码块实现了 K-means 聚类（k=2），并展示簇极其中心点。

## 安装

安装所需依赖：
```
pip install -r requirements.txt
```

## 运行

打开 `main.ipynb`，例如：
```
jupyter notebook main.ipynb
```

## FAQ

### 运行时卡死？

A：初次运行时，可能需要为 `matplotlib.pyplot` 设置渲染用后端：
```python
import matplotlib
matplotlib.use('TkAgg')
```

(StackOverflow)[https://stackoverflow.com/questions/44262242/pyplot-plot-freezes-not-responding]
