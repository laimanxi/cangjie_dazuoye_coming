# ImageForge - AI 图像编辑与生成

> 基于仓颉（Cangjie）语言开发的 HarmonyOS 鸿蒙原生应用

## 项目简介

ImageForge 是一款面向 HarmonyOS 设备的 AI 驱动图像处理应用，提供图像智能编辑与生成功能。用户可通过自然语言描述来编辑图片或生成全新图像。

## 核心功能

### 图像编辑
| 功能 | 说明 |
|------|------|
| 风格化修图 | 自然语言编辑 + Flux2 工作流，支持人像精修、复古胶片、证件照等风格 |
| 高清增强 | Lanczos 放大算法 + 更高像素与步数，提升图片清晰度 |
| 背景重绘 | 提高 CFG 配合背景提示词，智能替换或重绘背景 |

### 图像生成
- **文生图**：输入文字描述，AI 生成全新图像
- 支持自定义分辨率、步数、CFG 等参数
- 内置场景预设（自拍、办公桌、户外等）

### 其他功能
- **历史记录**：本地保存处理成功的任务，支持离线回看
- **服务设置**：健康检查与版本信息查看
- **积分系统**：基于积分的用量管理

## 技术栈

| 层级 | 技术 |
|------|------|
| 编程语言 | [仓颉（Cangjie）](https://cangjie-lang.cn/) |
| UI 框架 | ArkUI（声明式 UI） |
| 目标平台 | HarmonyOS（手机/平板） |
| 构建工具 | Hvigor + cjpm |

## 项目结构

```
cangjie_dazuoye_try/
├── entry/                          # 主模块（Entry 模块）
│   ├── src/main/cangjie/           # 仓颉源码目录
│   │   ├── index.cj                # 应用入口 + 登录页
│   │   ├── home_page.cj            # 首页功能导航
│   │   ├── editor_page.cj          # 编辑/生成页面
│   │   ├── history_page.cj         # 历史记录页面
│   │   ├── settings_page.cj        # 设置页面
│   │   ├── api_service.cj          # 数据模型与 API 定义
│   │   ├── main_ability.cj         # 主 Ability 生命周期
│   │   └── ability_stage.cj        # AbilityStage 初始化
│   ├── src/test/cangjie/           # 单元测试
│   ├── src/main/resources/         # 应用资源
│   │   ├── base/element/           # 颜色、字符串定义
│   │   └── base/media/             # 图片资源
│   ├── src/main/module.json5       # 模块配置
│   └── cjpm.toml                   # 仓颉包管理配置
├── AppScope/                       # 应用级资源
└── build-profile.json5             # 构建配置
```

## 快速开始

### 环境要求

- DevEco Studio（鸿蒙开发 IDE）
- 仓颉 SDK（版本 1.1.0+）
- HarmonyOS 模拟器或真机

### 构建运行

1. 使用 DevEco Studio 打开本项目
2. 等待 Gradle 和仓颉依赖同步完成
3. 点击运行按钮（或按 `Shift+F10`）
4. 选择目标设备（模拟器或真机）

### 构建命令（命令行）

```bash
# 进入项目目录
cd cangjie_dazuoye_try

# 使用 hvigor 构建
hvigorw assembleHap
```

## 使用说明

### 首次启动
1. 应用启动后进入登录页
2. 输入内测访问码（当前版本为模拟登录，任意非空访问码均可）
3. 进入主界面后可查看积分余额

### 编辑图片
1. 进入「创作」标签页
2. 选择「编辑图片」模式
3. 选择编辑类型（风格化/高清增强/背景重绘）
4. 上传图片（支持 JPG/PNG/WEBP，最大 20MB）
5. 输入编辑指令（可使用预设提示词快速填充）
6. 可选填写排除内容（负向提示词）
7. 点击「编辑图片」按钮开始处理

### 生成图片
1. 在「创作」页切换至「生成图片」模式
2. 输入图片描述
3. 可选选择场景预设
4. 调整参数（宽度/高度/步数/CFG）
5. 点击「生成图片」按钮

## 数据模型

### 用户信息（UserInfo）
```
- userId: 用户唯一标识
- username: 用户名
- plan: 套餐类型（free/basic/pro/enterprise）
- credits: 剩余积分
- editCreditCost: 编辑消耗积分（默认 2）
- generateCreditCost: 生成消耗积分（默认 1）
```

### 预设模板（EditPreset）
内置 5 种编辑预设：
- 人像精修（style_portrait）
- 复古胶片（style_vintage）
- 证件照清爽（style_id）
- 高清增强（upscale_main）
- 背景重绘（background_main）

### 订阅套餐
| 套餐 | 月积分 | 价格 | 特色功能 |
|------|--------|------|----------|
| 免费版 | 10 | 免费 | 基础画质 |
| 基础版 | 100 | $9.99 | 高清画质、无水印 |
| 专业版 | 500 | $29.99 | 超高清、API 访问 |
| 企业版 | 2000 | $99.99 | 最高画质、定制 API、SLA |

## API 说明

当前版本 API 基础地址：
```
https://ptp.matrixlabs.cn
```

> 注意：此为演示配置，生产环境请替换为实际服务地址。

## 开发说明

### 添加新页面
1. 在 `entry/src/main/cangjie/` 下创建 `.cj` 文件
2. 使用 `@Component` 装饰器定义组件
3. 在 `index.cj` 的 Tabs 中注册页面

### 添加新预设
在 `api_service.cj` 的 `getDefaultPresets()` 函数中添加新的 `EditPreset` 实例。

### 修改样式
应用采用 iOS 风格设计系统：
- 主色调：`#007AFF`（蓝色）
- 背景色：`#F2F2F7`（浅灰）
- 文字主色：`#1D1D1F`（深黑）
- 文字次色：`#86868B`（灰色）

## 许可证

本项目仅供学习和演示使用。

---

**开发语言**: 仓颉（Cangjie）  
**目标平台**: HarmonyOS  
**最后更新**: 2026-05
**我勒个老天奶**：咱就是说五一假期为什么要写作业我勒个马勒戈壁
