
---

```markdown
# FPGA_prj 💡 - 从零开始的FPGA实战项目

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Quartus](https://img.shields.io/badge/Quartus-22.01-blue)](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/download.html)
[![ModelSim](https://img.shields.io/badge/ModelSim-20.1-green)](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-sim.html)
[![Stars](https://img.shields.io/github/stars/yourusername/FPGA_prj?style=social)](https://github.com/yourusername/FPGA_prj)

**基于EP4CE6E22C8N的FPGA入门到进阶实战项目**  
包含完整代码 + 仿真 + 详细笔记，适合初学者和进阶开发者

</div>

---

## 📋 项目简介

本项目基于 **Altera Cyclone IV EP4CE6E22C8N** FPGA开发板，从零开始实现了一系列基础到中等难度的外设驱动和功能模块。每个模块都包含完整的Verilog代码、仿真文件和学习笔记，记录了从原理理解到代码实现的全过程。

> 🎯 **适用人群**：FPGA初学者、电子类学生、嵌入式开发者、硬件爱好者  
> ✨ **项目特点**：边学边做、文档齐全、持续更新、真实的学习笔记

---

## ✨ 功能模块进度

### 一表看懂当前进展

| 类别 | 已完成 ✅ | 进行中 🚧 | 规划中 📅 |
|------|----------|----------|----------|
| **基础外设** | LED流水灯、LED阵列、蜂鸣器 | 数码管、拨码开关 | - |
| **通信接口** | 红外接收、超声波测距 | UART串口 | **SPI、I²C** |
| **综合项目** | 简易音乐播放器 | - | 红外应用、SPI设备驱动 |

### 📦 模块详细列表

#### ✅ 已完成模块
| 模块 | 说明 | 文档/路径 |
|------|------|----------|
| LED流水灯 | 基础IO控制，了解FPGA时序 | [LED阵列.md](LED阵列.md) |
| LED阵列控制 | 多位LED的不同显示模式 | [LED阵列.md](LED阵列.md) |
| 蜂鸣器控制 | PWM输出，播放简单音调 | [蜂鸣器.md](蜂鸣器.md) |
| 红外接收 | 基于红外遥控的解码实现 | 代码见 `infrared/` |
| 超声波测距 | HC-SR04驱动，精确测距 | [ultrasonic](ultrasonic/) |
| 简易音乐播放器 | 利用PWM播放简单旋律 | [music_player](music_player/) |

#### 🚧 进行中模块
| 模块 | 说明 | 预计完成 |
|------|------|---------|
| 数码管驱动 | 动态扫描显示数字 | 近期 |
| 拨码开关 | 输入检测与消抖 | 近期 |
| UART串口 | 串口收发与PC通信 | 本月内 |

#### 📅 规划中模块
| 模块 | 说明 | 计划 |
|------|------|------|
| **SPI接口** | 驱动Flash/ADC等SPI设备 | 下个月开始 |
| **I²C接口** | 驱动OLED/温度传感器等 | 后续 |
| 红外遥控应用 | 结合音乐播放器做综合项目 | 长期计划 |

> 💡 **项目持续更新中**：红外模块已完成，SPI/I²C正在规划，欢迎Watch关注更新！

---

## 🛠️ 开发环境

- **FPGA芯片**：EP4CE6E22C8N (Cyclone IV E)
- **开发工具**：Quartus Prime Lite Edition 22.01
- **仿真工具**：ModelSim (与Quartus联合仿真)
- **波形查看**：VScope
- **硬件平台**：自制/某宝基础开发板

---

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone https://github.com/yourusername/FPGA_prj.git
cd FPGA_prj
```

### 2. 打开项目
- 启动Quartus Prime
- 打开对应模块的 `.qpf` 工程文件
- 或直接新建工程，添加需要的 `.v` 文件

### 3. 编译与烧录
- 点击 **Start Compilation** 编译工程
- 连接开发板，点击 **Programmer** 烧录 `.sof` 文件

### 4. 仿真测试
- 使用提供的 `tb_*.v` 测试文件
- 在ModelSim中运行仿真，查看波形

---

## 📂 项目结构

```
FPGA_prj/
├── led_ctrl/              # LED控制模块
│   ├── led_ctrl.v         # 主代码
│   └── tb_led.v           # 测试文件
├── ultrasonic/            # 超声波测距
│   ├── ultrasonic.v
│   └── README.md          # 模块说明
├── music_player/          # 音乐播放器
│   └── ...
├── infrared/              # 红外接收模块
│   └── ... (即将上传)
├── docs/                  # 学习笔记
│   ├── day1.md            # 学习日记
│   ├── verilog语法易错点.md  # ⭐ 初学者必看
│   ├── LED阵列.md
│   └── 蜂鸣器.md
├── LICENSE
└── README.md
```

---

## 📚 学习资料精选

| 文档 | 说明 |
|------|------|
| [Verilog语法易错点.md](verilog语法易错点.md) | **新手必看**！总结了最常见的学习误区 |
| [day1.md](day1.md) | 学习笔记，记录真实的学习过程 |
| [LED阵列.md](LED阵列.md) | LED模块的详细实现说明 |
| [蜂鸣器.md](蜂鸣器.md) | PWM原理与实现笔记 |

每个模块的代码中都包含了详细的注释，帮助理解设计思路。

---

## 📌 为什么要关注这个项目？

✅ **真实的学习过程**  
不是一次性写完的"完美代码"，而是边学边做、边踩坑边总结的真实记录

✅ **完整的配套文档**  
每个模块都有实现笔记、易错点总结，不仅是代码，更是学习资料

✅ **持续迭代更新**  
从基础外设到通信协议，从简单到复杂，一步步深入FPGA开发

✅ **开源共享**  
所有代码和文档免费使用，欢迎一起学习、一起进步

---

## 🗓️ 后续更新计划

### 近期（本月内）
- [ ] 完成数码管动态扫描模块
- [ ] 完成UART串口收发模块
- [ ] 上传红外接收模块代码

### 中期（下个月起）
- [ ] SPI接口实现（计划驱动Flash芯片）
- [ ] I²C接口实现（计划驱动OLED显示屏）
- [ ] 完善各模块的仿真测试文件

### 长期
- [ ] 基于红外+音乐播放器做综合项目
- [ ] 迁移到ZYNQ系列，学习PS+PL协同设计
- [ ] 编写更详细的新手教程系列

---

## 🤝 如何参与

欢迎任何形式的贡献！
- ⭐ **点个Star** - 支持项目持续更新
- 👀 **Watch关注** - 第一时间收到更新通知
- 📝 **提交Issue** - 报告bug或提出建议
- 🔧 **Pull Request** - 一起完善代码和文档

---

## ⭐ 支持项目

如果这个项目对你有帮助，欢迎给个Star ⭐  
你的支持是我持续更新的最大动力！

**项目会长期更新，欢迎Watch关注，一起学习FPGA！**

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

<div align="center">
  <sub>Built with ❤️ by 一个正在学习FPGA的开发者</sub><br>
  <sub>如果觉得有用，请给个⭐ 让更多人看到</sub>
</div>
```

---

