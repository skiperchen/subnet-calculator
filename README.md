# 子网掩码计算器 (Subnet Mask Calculator)

一个 macOS 原生桌面应用，集成 **10 种网络计算工具**。

## 功能模块

| # | 计算器 | 快捷键 | 说明 |
|---|--------|--------|------|
| 1 | **子网掩码计算** | ⌘1 | IP 地址 + 掩码 → 网络地址、广播地址、可用 IP 范围、主机数 |
| 2 | **网络地址计算** | ⌘2 | CIDR 前缀 → 子网详情 |
| 3 | **IP 地址转换** | ⌘3 | 十进制 ↔ 二进制 ↔ 十六进制互转 |
| 4 | **子网划分** | ⌘4 | 按子网数/主机数划分子网 |
| 5 | **超网计算** | ⌘5 | CIDR 聚合 / 路由汇总 |
| 6 | **IPv6 计算器** | ⌘6 | IPv6 地址展开、压缩、前缀计算 |
| 7 | **通配符掩码** | ⌘7 | 子网掩码 ↔ 通配符掩码互转（Cisco ACL 用） |
| 8 | **IP 范围计算** | ⌘8 | 起止 IP → CIDR 表示 |
| 9 | **带宽计算** | ⌘9 | 带宽单位换算（bps/Kbps/Mbps/Gbps） |
| 10 | **十六进制转换** | ⌘0 | 十六进制 ↔ 十进制 ↔ 二进制 |

## 特性

- 🖥️ **原生 macOS 窗口** — 基于 Electron，独立窗口体验
- ⌨️ **键盘快捷键** — ⌘1~⌘0 快速切换计算器
- 📋 **一键复制** — 所有结果支持点击复制
- 📜 **历史记录** — 本地存储最近 50 条计算历史
- 🌙 **暗色模式** — 支持系统暗色模式
- 🇨🇳 **中文界面** — 完整中文菜单和提示
- ✅ **135 个边缘测试全部通过**

## 下载

前往 [Releases](https://github.com/skiperchen/subnet-calculator/releases) 下载最新版本：

- **Apple Silicon (M1/M2/M3)**: `子网掩码计算器-macOS-arm64.zip`
- **Intel Mac**: `子网掩码计算器-macOS-x64.zip`

> ⚠️ 首次打开提示「无法验证开发者」→ 系统设置 → 隐私与安全性 → 仍要打开
> <img width="1164" height="846" alt="image" src="https://github.com/user-attachments/assets/b3a7cc55-81f7-4006-bf83-2181a001cc1d" />


## 开发

### 直接运行（浏览器）

```bash
# 直接用浏览器打开
open index.html
```

### 构建 Electron 桌面应用

```bash
cd electron
npm install
npm run build:mac       # 双架构 (arm64 + x64)
npm run build:mac-arm   # 仅 Apple Silicon
npm run build:mac-x64   # 仅 Intel Mac
```

构建产物在 `output/` 目录。

## 技术栈

- **前端**: 纯 HTML5 + CSS3 + Vanilla JavaScript（零依赖）
- **桌面框架**: Electron + electron-builder
- **测试**: 135 个边缘测试覆盖所有计算器

## 许可证

MIT License © 2026 skiperchen 
