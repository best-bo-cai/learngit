# LocalChat MVP - 端侧大模型对话应用

## 📱 项目简介

LocalChat MVP 是一款完全离线、跨平台、低延迟的端侧大模型对话应用。基于 Flutter 和 llama.cpp 构建，实现数据不出设备、零流量消耗、隐私安全的 AI 对话体验。

### 核心特性

- **完全离线**：所有推理在设备本地完成，无需网络连接
- **隐私安全**：对话记录不上传云端，数据完全可控
- **跨平台**：支持 Android 8.0+ 和 iOS 14.0+
- **流式输出**：实时显示生成结果，降低等待焦虑
- **模型管理**：支持下载、导入、切换多个 GGUF 模型
- **轻量级**：优化的内存占用和性能表现

---

## 🏗️ 项目结构

```
edge_ai_app/
├── lib/
│   ├── main.dart                     # 应用入口
│   ├── core/
│   │   ├── engine/
│   │   │   └── llama_engine.dart     # FFI 引擎封装
│   │   ├── models/
│   │   │   └── message.dart          # 数据模型
│   │   └── services/
│   │       ├── chat_service.dart     # 聊天服务
│   │       └── model_service.dart    # 模型管理服务
│   └── features/
│       ├── chat/
│       │   └── chat_screen.dart      # 聊天界面
│       └── settings/
│           └── model_management_screen.dart  # 模型管理界面
├── native/
│   ├── llama_wrapper.cpp             # C++ 桥接层
│   ├── llama_wrapper.h               # C 头文件
│   └── scripts/
│       ├── build_android.sh          # Android 编译脚本
│       └── build_ios.sh              # iOS 编译脚本
├── assets/
│   └── models/                       # 模型文件目录
├── android/                          # Android 工程
├── ios/                              # iOS 工程
├── pubspec.yaml                      # 依赖配置
├── README.md                         # 本文件
└── MODEL_DOWNLOAD_GUIDE.md           # 模型下载指南
```

---

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.24
- Dart SDK >= 3.5
- Android NDK >= 26 (Android 构建)
- Xcode >= 15 (iOS 构建)

### 安装依赖

```bash
cd edge_ai_app
flutter pub get
```

### 运行应用

```bash
# Android
flutter run

# iOS
flutter run -d iphone

# 发布版本
flutter build apk --release
flutter build ios --release
```

---

## 📦 模型管理（新增功能）

### 三种获取模型方式

#### 1. 推荐模型一键下载
App 内置了 Qwen3.5 系列推荐模型列表，点击即可下载：
- Qwen3.5-0.8B-Instruct (Q4_K_M) - ~620MB ⭐ 推荐
- Qwen3.5-0.8B-Instruct (Q5_K_M) - ~720MB
- Qwen3.5-0.8B-Instruct (Q6_K) - ~850MB
- Qwen2.5-0.5B-Instruct (Q4_K_M) - ~320MB

#### 2. 自定义 URL 下载
在"模型管理"页面输入任意 `.gguf` 文件直链进行下载

#### 3. 本地文件导入
从其他渠道下载的 `.gguf` 文件可通过文件选择器导入

### 使用步骤

1. 打开 App，点击底部导航栏的 **"模型"** 标签页
2. 选择以下方式之一获取模型：
   - 点击推荐模型的"下载"按钮
   - 在输入框粘贴自定义 URL 并下载
   - 点击"从本地导入模型"选择文件
3. 下载完成后，点击模型右侧的 **"切换"** 按钮
4. 返回 **"对话"** 标签页，标题栏会显示当前模型名称
5. 开始离线对话！

详细说明请查看 [模型下载指南](MODEL_DOWNLOAD_GUIDE.md)

---

## 🔧 开发说明

### MVP 版本功能

当前版本为 MVP（最小可行产品），包含以下核心功能：

1. ✅ 基础聊天界面
2. ✅ 流式消息输出（模拟）
3. ✅ 对话历史管理
4. ✅ 清除对话功能
5. ✅ **模型下载与管理**（新增）
6. ✅ **多模型切换**（新增）
7. ✅ **本地文件导入**（新增）

### 待实现功能

以下功能已在 PRD 中定义，将在后续版本实现：

- [ ] llama.cpp FFI 真实集成
- [ ] Isolate 推理线程
- [ ] 上下文管理
- [ ] 参数调节（温度、TopP 等）
- [ ] 本地存储加密
- [ ] GPU 加速推理

### 集成真实 llama.cpp

1. 克隆 llama.cpp 作为子模块：
```bash
cd native/third_party
git clone https://github.com/ggerganov/llama.cpp.git
```

2. 编译原生库：
```bash
# Android
./native/scripts/build_android.sh

# iOS
./native/scripts/build_ios.sh
```

3. 启用 FFI 调用：
修改 `lib/core/engine/llama_engine.dart`，取消 FFI 调用注释

---

## 📄 相关文档

- [PRD-01](../prd-01.md) - 原始产品需求文档
- [PRD-03](../prd-03.md) - 缺陷修复与增强版 PRD
- [模型下载指南](MODEL_DOWNLOAD_GUIDE.md) - 详细的模型下载和使用说明

---

## ⚠️ 注意事项

1. **MVP 版本使用模拟响应**：当前版本未集成真实的 llama.cpp，AI 回复为模拟数据
2. **模型文件需自行下载或导入**：首次使用需在"模型"标签页下载或导入 GGUF 格式模型
3. **内存优化**：建议使用 1B 以下量化模型（Q4_K_M 或 Q5_K_M）
4. **设备兼容性**：推荐骁龙 7+ Gen1 或 A14 芯片及以上设备
5. **存储空间**：确保设备有足够存储空间（建议预留 1GB+）
6. **网络要求**：下载模型需要稳定的网络连接

---

## 📝 许可证

MIT License

---

## 👥 贡献指南

欢迎提交 Issue 和 Pull Request！

---

## 🌟 推荐模型来源

本项目推荐的 Qwen3.5 模型来自 HuggingFace：
- [Qwen/Qwen3.5-0.8B](https://huggingface.co/Qwen/Qwen3.5-0.8B)
- [bartowski/Qwen3.5-0.8B-Instruct-GGUF](https://huggingface.co/bartowski/Qwen3.5-0.8B-Instruct-GGUF)

感谢 Qwen 团队和开源社区的贡献！
