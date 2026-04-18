# EdgeMind AI - 端侧大模型对话应用

## 📱 项目简介

EdgeMind AI 是一款完全离线、跨平台、低延迟的端侧大模型对话应用。基于 Flutter 和 llama.cpp 构建，实现数据不出设备、零流量消耗、隐私安全的 AI 对话体验。

### 核心特性

- **完全离线**：所有推理在设备本地完成，无需网络连接
- **隐私安全**：对话记录不上传云端，数据完全可控
- **跨平台**：支持 Android 和 iOS
- **流式输出**：实时显示生成结果，降低等待焦虑
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
│   │       └── chat_service.dart     # 聊天服务
│   └── features/
│       └── chat/
│           └── chat_screen.dart      # 聊天界面
├── native/
│   ├── llama_wrapper.cpp             # C++ 桥接层（待实现）
│   ├── llama_wrapper.h               # C 头文件（待实现）
│   └── scripts/
│       ├── build_android.sh          # Android 编译脚本
│       └── build_ios.sh              # iOS 编译脚本
├── assets/
│   └── models/                       # 模型文件目录
├── android/                          # Android 工程（待创建）
├── ios/                              # iOS 工程（待创建）
├── pubspec.yaml                      # 依赖配置
└── README.md                         # 本文件
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

## 🔧 开发说明

### MVP 版本功能

当前版本为 MVP（最小可行产品），包含以下核心功能：

1. ✅ 基础聊天界面
2. ✅ 流式消息输出（模拟）
3. ✅ 对话历史管理
4. ✅ 清除对话功能

### 待实现功能

以下功能已在 PRD 中定义，将在后续版本实现：

- [ ] llama.cpp FFI 真实集成
- [ ] 模型下载与管理
- [ ] Isolate 推理线程
- [ ] 上下文管理
- [ ] 参数调节（温度、TopP 等）
- [ ] 本地存储加密
- [ ] 多模型切换

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

---

## ⚠️ 注意事项

1. **MVP 版本使用模拟响应**：当前版本未集成真实的 llama.cpp，AI 回复为模拟数据
2. **模型文件需自行准备**：将 GGUF 格式模型放入 `assets/models/` 目录
3. **内存优化**：建议使用 7B 以下量化模型（Q4_K_M 或 Q5_K_M）
4. **设备兼容性**：推荐骁龙 8 Gen 2 或 A15 芯片及以上设备

---

## 📝 许可证

MIT License

---

## 👥 贡献指南

欢迎提交 Issue 和 Pull Request！
