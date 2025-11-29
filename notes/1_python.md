# Python

编程语言到底是什么？或者说，了解一门编程语言时应该注意什么？绝大多数人都会抖出一大堆语言的各种特性和设计哲学啥的。不过就实际应用中，最蛋疼的问题——也是最先接触到的问题可能是各种环境配置、包管理、环境管理之类的，所以这里先记录这些内容。Python 的特性在靠后些的地方。

## 环境配置

用于机器学习的 Python 环境配置不同于平常，这体现在：

- 为了保证效率，很多机器学习需要的包本身就不是 Python 写的。它们一般由其他语言编写，Python 只是拿编译好的东西来用。
- 机器学习的包容易依赖比较特定的版本，甚至依赖 Python 版本。

**Conda** 作为包管理工具可以安装其他语言编译的二进制包（甚至有可能有优化），作为环境管理工具可以隔离环境。Conda 在事实上很适合机器学习。

下文是在 Windows 10 系统，NVIDIA GeForce RTX 3060 Laptop GPU 下的配置流程。

### Conda

进入 [Anaconda 官网](https://www.anaconda.com/download)就可以免费下载 Conda。官网提供了一般的 Anaconda 和所谓的 Miniconda。它们有一些区别，但是操作流程大同小异。

安装时，你会注意到官方不推荐将 `condabin` 加到 `PATH` 里面，所以装好了也没法直接用。需要以下的操作流程：

#### 初始化

##### Anaconda

Anaconda 提供了一个图形化界面，可能是我电脑太垃圾了，卡得要命。所以使用 Anaconda PowerShell Prompt 会比较好。Anaconda PowerShell Prompt 是 Anaconda 提供的 Shell[^python_declare_0]，我们稍后会知道它其实就是 PowerShell 执行了一些 Conda 需要的东西。

[^python_declare_0]: 这个称呼不准确，不过你懂就好。

你可以在开始菜单中搜索“Anaconda PowerShell Prompt”来运行它。

##### Miniconda

**太长不看**：

将路径 `/path/to/your/miniconda/condabin` 换为 Miniconda 的安装路径（一般是 `~/miniconda3/condabin`）
```powershell
cd /path/to/your/miniconda/condabin
./conda init
```
运行后重启 PowerShell。

----

Miniconda 并没有提供 Anaconda PowerShell Prompt，所以需要一些额外操作来初始化。

在 `/path/to/your/miniconda/condabin`（默认是 `~/miniconda3/condabin`）中，可以找到 `conda.bat`，运行：

```powershell
cd /path/to/your/miniconda/condabin
./conda init
```

就可以为 PowerShell 完成初始化。（或者，也可以 `./conda init <shell_name>` 来配置你喜欢的 Shell。[官方文档](https://docs.conda.io/projects/conda/en/stable/commands/init.html)中列出了支持的 Shell。）

重启 PowerShell 后，就进入了 Anaconda PowerShell Prompt 一样的环境。

这么做当然是可以的，但是从此之后你每次打开 PowerShell 都得卡两秒多了！这谁受得了？幸好我们可以先撤销这个初始化操作：

```powershell
cd /path/to/your/miniconda/condabin
./conda init --reverse
```

如果你留心观察（或者，运行一遍 `./conda init --dry`），你就会看到这些信息：

```
no change     C:\Users\yn\miniconda3\Scripts\conda.exe
（略过）
modified      C:\Users\yn\Documents\WindowsPowerShell\profile.ps1
modified      C:\Users\yn\Documents\PowerShell\profile.ps1
modified      HKEY_CURRENT_USER\Software\Microsoft\Command Processor\AutoRun
```

最后一项是一个注册表里面的值，不太需要管[^python_register]。前面两项引人注意，看看：

[^python_register]: 事实上，我的机器上测试时，这个值压根就没修改，从头到尾都是空的……

```powershell
cat C:\Users\yn\Documents\WindowsPowerShell\profile.ps1
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Users\yn\miniconda3\Scripts\conda.exe") {
    (& "C:\Users\yn\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion
cat C:\Users\yn\Documents\PowerShell\profile.ps1
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Users\yn\miniconda3\Scripts\conda.exe") {
    (& "C:\Users\yn\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion
```

噢，看来这个所谓的初始化就是自动执行了一段脚本。

我所做的事是，在 `~/scripts` 下弄了一个 `condainit.ps1`，把这些内容复制了进去，又把 `%USERPROFILE%/scripts` 加到 `PATH` 里了。我可以运行 `condainit` 来随时按需进入这个环境，不需要的时候就不用卡两秒了。

#### 创建环境

调整好 PowerShell 后，就可以开始创建虚拟环境了。Conda 提供了一个 `base` 环境，但是大家都不太喜欢用这个，而是自己创建一个新的：

```powershell
(base) PS C:\Users\yn> conda create -n ml
```

其中 `-n` 参数表示环境名。

然后就可以进入这个环境了：

```powershell
(base) PS C:\Users\yn> conda activate ml
```

#### 包

创建好环境后，就可以安装所需的包了。需要注意的是，Conda 和 pip 都可以安装包，它们在 Conda 环境中是可以一起使用的，但是有些注意事项[^python_conda_with_pip]：

[^python_conda_with_pip]: https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#using-pip-in-an-environment

- 应该先用 Conda 安装尽可能多的包，然后再用 pip 安装剩下的包。
- 如果要安装新的 Conda 包，应该创建新的环境。

旧版本的 Conda 需要手动安装 pip 本身，pip 也需要用 Conda 在最后安装。因为 Conda 无法感知到 pip 作出的修改。

由此可见，要安装包，最好只用 Conda，所以为什么这里会写这些呢？因为非常悲催的是，[PyTorch 官方在早些时候宣布不再在 Anaconda 发布包了](https://github.com/pytorch/pytorch/issues/138506)，原因是“投资回报率不足”（not justifiable with the ROI）。

好吧，所以下面开始安装包：

```powershell
conda install jupyter
conda install numpy 
conda install pandas 
conda install matplotlib
```

PyTorch 包需要根据电脑显卡对 CUDA 的支持情况来安装，使用 `nvidia-smi` 获取显卡信息：

```powershell
PS C:\Users\yn> nvidia-smi
Fri Oct 17 20:48:18 2025
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 576.52                 Driver Version: 576.52         CUDA Version: 12.9     |
|-----------------------------------------+------------------------+----------------------+
（下略）
```

这说明支持 CUDA 最新版本为 12.9，在[官网](https://pytorch.org/get-started/locally/)找到对应版本的安装命令：

```powershell
pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu128
```

或者，如果担心 conda 和 pip 之间的兼容性问题，可以安装 conda 自己的包。从官网找到 `pytorch-gpu`（<https://anaconda.org/channels/conda-forge/packages/pytorch-gpu/overview>）

```powershell
conda install conda-forge::pytorch-gpu
```

#### 完毕

完成！PyCharm 之类的 IDE 可以使用这个环境，或者，也可以随时激活这个环境来运行程序。

#### 后记：requirements.txt？

众所周知，python 可以用 `pip freeze > requirements.txt` 来导出项目用到的包及其版本。之后再用 `pip install -r requirements.txt` 来安装环境。

conda 不太一样，它可以用 `conda env export > environment.yml` 导出，用 `conda env create -f environment.yml` 安装环境。

## 特色

接下来记录一些 Python 值得注意的特性。这里略去了绝大多数语言里共通的部分。

### 万物皆对象

> Everything in Python is an object.

一讲到 Python，很多人立刻说“Python 是弱类型语言，变量声明无需以类型名开头。”看看各种语言，Python 的类型系统在其中确实也算是特别的。

不同于老牌编程语言 Java、C++ 等，Python 没有所谓的“基础数据类型”。也就是说别的语言里，写一个 `int a = 1;` 那是真的实打实在内存里分配了一块空间来存这个值的。但是 Python 的一句 `a = 1` 就只是让 `a` 这个变量名引用 `1` 对应的对象罢了。

#### 传递

自然而然地引出这个问题：引用传递还是值传递？`b = a` 到底做了啥？答案是“对象引用传递”，这个说法听着怪怪的，但是可以把 Python 的变量理解成一个会自动解引用的**指针**，这绝对不准确但是可以解释什么是“对象引用传递”。

比如，Python 对象可以表现得像引用传递：

```python
>>> def f(lst):
...     lst[0] = 4
...
>>> a = [1, 2, 3]
>>> f(a)
>>> print(a)
[4, 2, 3]
```

也可以像是值传递：

```python
>>> def f(x):
...     x += 1
...
>>> a = 1
>>> f(a)
>>> print(a)
1
```

但是不可以“重新绑定引用”：

```python
>>> def f(lst):
...     lst = [4, 5, 6]
...
>>> a = [1, 2, 3]
>>> f(a)
>>> print(a)
[1, 2, 3]
```

第一例告诉我们，传递变量不是值传递，列表不会被复制一份传入函数。

第二例告诉我们，传递变量不是引用传递，在函数内改变[^python_declare_1]传入的变量不一定会导致外部的变量被修改。

[^python_declare_1]: 当然了，我们很快会知道这里其实没有“改变”这个变量的值。

最后这个例子中，函数尝试让变量引用另一个对象，这对外部来讲不起作用。

这些例子看起来有可能令人费解，实在没招了可以把它们都当成 `void *a` 这种东西，传递的时候就是在传递指针值，反正我是一下就清楚了。

#### 可变

幸好 Python 的变量并不是纯粹的“引用传递”，不然这样的代码绝对能把程序员愁死：

```python
>>> a = 1
>>> b = a
>>> b += 1
>>> print(a)
```

要是这里是引用传递的，那就得输出 `2` 了。操作了一处值，却改了两个变量……

为此，Python 有所谓的**可变类型**与**不可变类型**[^python_mutable]，不可变类型保证任何操作都创建并返回新的对象，而不是修改对象属性。例如，`list` 就可以修改内部的值，是可变的。而 `str` 无论如何都改不了值，`upper()` 这种方法会返回新的 `str`。

[^python_mutable]: 可变与否其实不是语法层面的特性，而是对一种类型具体实现方式的概况。如果类不提供修改值的方法，那么就称它是不可变的，反之亦然。

#### 连带特性

“万物皆对象”使得有些特性顺理成章了：

- 无需显式声明变量类型；
- 函数是一等公民；
- 类型是一等公民；
- 模块是一等公民；
- 切片总是浅拷贝，而不是“同一内存区域的引用”：
    - **不适用于许多 NumPy 和 Pytorch 对象，因为它们的底层实现不一般。**
- 没有“强制类型转换”，形如 `int(x)` 的写法不过是构造函数。

当然了，都面向对象了肯定得有 `is` 运算符。同一个对象之间作 `is` 才会得到 `True`，而 Python 的一个好玩的性质是，它会缓存较小的量，小量一般是同一个对象，大了就未必了，于是有了以下的奇观：

```python
>>> a = 1
>>> b = 1
>>> a is b
True
>>> a = 123123123
>>> b = 123123123
>>> a is b
False
```

### 重载运算符

面向对象语言老喜欢重载运算符，Python 也可以，而且除了赋值基本上都可以重载。有些时候对象的行为令人惊讶，要适应，毕竟运算符重载了之后内部逻辑想怎么写就怎么写。

这里列出了一些 Python 的特色运算：

- 整数除整数可以得到小数：`3 / 2 == 1.5`；
- 整除操作符 `//`：`3 // 2 == 1`；
- 可以索引负值：`"Hello"[-1] == 'o'`；
- 可以对字符串判等：`"aa" + "bb" == "aabb"`；
- 花式索引。

#### 花式索引

花式索引在 NumPy、Pandas 之类的包里面被实现了，这里记一下细节：

可以想象索引对象时，是在对一个高维数据结构操作。此时可以索引普通的值，也可以索引：

- `list`：
    - 如果内容是布尔值，则解释为掩码，即索引 `True` 对应的下标；
    - 否则，解释为索引内容的每一值，并聚合为一个**新的对象**（不是视图）。
- `tuple`：
    - 递归解释为依次索引值。（广播）
- `slice`：
    - 切片，结果是一个**视图**。

这有时候很有用，还可以省去 `for`。

### lambda

Python 可以使用匿名函数，和具名的函数相比似乎没有性质上的差别。

匿名函数的语法是 `lambda x: <表达式>`。相较于 C++ 的匿名函数，Python 的匿名函数不需要捕获外部变量，更确切地说，所有的外部作用域变量都是默认捕获的。这种特性使得其可以用于函数式编程中的闭包。

### 迭代器

“可以挨个数过去”的数据结构很常见，为了方便遍历它们，Python 使用了迭代器（iterator）。可迭代对象实现了 `__iter__()` 来产生迭代器对象，迭代器实现了 `__next__()` 来获取下一个值。

迭代器也实现 `__iter()__`，这使得迭代器自己也是可迭代的。

在形如 `for x in a` 的语句中，总是会先调用 `iter(a)` 来获取 `a` 的迭代器 `it`，然后反复调用 `next(it)` 来获取新的值，直到 `__next__()` 抛出 `StopIteration` 异常。

不仅仅是在循环中，其他地方的 `for x in a` 也总是如此使用迭代器以遍历所有值。

#### 生成器

生成器（generator）是一种迭代器，不过创建它的方法不太一样。

使用 `yield` 关键字[^python_yield]的函数被称为**生成器函数**。这样的函数不使用 `return` 来返回值[^python_declare_2]，而是使用 `yield`。

生成器函数的返回值是一个生成器 `gt`。每当调用 `next(gt)`，函数将会开始运行，直到遇到一个 `yield`，此时函数会**停在这个位置**，这个 `yield` 的值就是 `next(gt)` 的返回值。

[^python_yield]: 意思是“产出”。
[^python_declare_2]: 但是可以用 `return` 来抛出 `StopIteration`。如果带值，那么这个值可以在 `StopIteration.value` 找到。

*生成器是一种迭代器。*

### 推导式

`list` `dict` `tuple` `set` 都可以使用推导式（comprehension）来创建，这是一种语法糖。

推导式的基本写法是 `[fn for x in l if <表达式>]`，其中 `l` 是一个可迭代对象，`if` 不必要。语义上来看，这个式子的意思就是“对于 `l` 中的所有 `x`，作用一个表达式后组成一个列表”。

把外层的符号替换掉就可以得到不同类对象的推导式，即：

- `list`：`[fn for x in l if <表达式>]`
- `tuple`：`(fn for x in l if <表达式>)`
- `set`：`{fn for x in l if <表达式>}`
- `dict`：`{fn_key : fn_value for x in l if <表达式>}`

注意迭代器的 `for ... in ...` 语法在此是统一的。

### with

资源管理绝对是经久不衰的话题，所有人肯定都曾 `malloc()` 完了不 `free()`，或者 `fopen()` 了不 `fclose()`。Python 虽然不用管内存了，文件、连接的开关还是个问题。`with` 语句可以自动管理这个过程，例如：

```python
with open('python.md', 'r') as file:
    print(file.read())
```

离开 `with` 时，`file` 被自动关闭了，真好。

`with` 之所以能实现，是因为对象实现了方法 `__enter__()` 和 `__exit__()`，它们定义了进入和离开 `with` 时的行为。

缩进自然是又多一层，但是为了不把各种资源漏得到处都是，管他洪水滔天呢。

### 字符串与字符

Python 的字符串没什么很特别的，但是非常有趣的是，Python 没有字符类型，只有长度为 1 的字符串而已。倒反天罡。
