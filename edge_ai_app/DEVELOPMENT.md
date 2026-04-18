# EdgeMind AI MVP 开发日志

## 版本信息
- **版本号**: v0.1.0 (MVP)
- **创建日期**: 2024
- **状态**: 基础框架完成，等待 llama.cpp 集成

---

## 已完成功能

### 1. 项目结构搭建 ✅
```
edge_ai_app/
├── lib/
│   ├── main.dart                     # Flutter 应用入口
│   ├── core/
│   │   ├── engine/
│   │   │   └── llama_engine.dart     # FFI 引擎封装（含 Mock）
│   │   ├── models/
│   │   │   └── message.dart          # 消息和配置模型
│   │   └── services/
│   │       └── chat_service.dart     # 聊天业务逻辑
│   └── features/
│       └── chat/
│           └── chat_screen.dart      # 聊天 UI 界面
├── native/
│   ├── llama_wrapper.h               # C API 头文件
│   ├── llama_wrapper.cpp             # C++ 桥接实现
│   ├── CMakeLists.txt                # CMake 构建配置
│   ├── dummy_llama.cpp               # Mock 实现（开发用）
│   └── scripts/
│       ├── build_android.sh          # Android 编译脚本
│       └── build_ios.sh              # iOS 编译脚本
├── assets/
│   └── models/                       # 模型文件目录
├── pubspec.yaml                      # Dart 依赖配置
└── README.md                         # 项目文档
```

### 2. 核心模块实现 ✅

#### 2.1 LlamaEngine (llama_engine.dart)
- [x] 单例模式实现
- [x] 动态库加载（Android/iOS 自适应）
- [x] 模型加载接口（Mock 版本）
- [x] 上下文创建接口（Mock 版本）
- [x] 流式生成接口（模拟输出）
- [x] 资源释放方法

#### 2.2 数据模型 (message.dart)
- [x] ChatMessage 消息类
  - 支持 user/assistant/system 角色
  - 流式状态标记
  - JSON 序列化/反序列化
- [x] ModelConfig 配置类
  - nCtx, nGpuLayers, nThreads 参数
  - temperature, topP, maxTokens 推理参数
  - 默认配置常量

#### 2.3 聊天服务 (chat_service.dart)
- [x] 单例服务模式
- [x] 消息历史管理
- [x] 流式消息发送
- [x] 上下文提示词构建
- [x] 对话清除功能

#### 2.4 聊天界面 (chat_screen.dart)
- [x] Material Design 3 风格 UI
- [x] 消息气泡展示
- [x] 流式输出动画
- [x] 输入框与发送按钮
- [x] 自动滚动到底部
- [x] 清除对话功能
- [x] 空状态引导页

### 3. 原生桥接层 ✅

#### 3.1 C API 定义 (llama_wrapper.h)
- [x] edge_llama_load_model
- [x] edge_llama_new_context
- [x] edge_llama_decode
- [x] edge_llama_free_context
- [x] edge_llama_get_last_error

#### 3.2 C++ 实现 (llama_wrapper.cpp)
- [x] 完整的模型加载逻辑
- [x] 上下文创建与管理
- [x] 自回归生成循环
- [x] Token 回调机制
- [x] 错误处理

#### 3.3 构建系统
- [x] CMakeLists.txt 配置
- [x] Android NDK 编译脚本
- [x] iOS Xcode 编译脚本
- [x] Mock 占位实现（开发友好）

---

## 待实现功能（按优先级）

### P0 - 核心功能
- [ ] 集成真实 llama.cpp 库
  ```bash
  cd native/third_party
  git clone https://github.com/ggerganov/llama.cpp.git
  ```
- [ ] 启用 FFI 真实调用（取消 Mock）
- [ ] Isolate 推理线程（避免 UI 阻塞）
- [ ] Token 回调与 StreamController 对接

### P1 - 增强功能
- [ ] 模型下载管理器
  - HTTP 断点续传
  - SHA256 校验
  - 进度显示
- [ ] 多模型切换
- [ ] 推理参数调节 UI
- [ ] 上下文长度管理

### P2 - 优化功能
- [ ] 本地存储（SQLite/Isar）
- [ ] 对话历史持久化
- [ ] 导出/导入对话
- [ ] 性能监控

---

## 已知问题

### 1. Mock 模式限制
- 当前使用模拟响应，非真实 AI 生成
- 解决方案：集成 llama.cpp 后取消 Mock

### 2. 主线程阻塞风险
- `generateStream` 目前在主线程运行
- 解决方案：使用 `compute()` 或 `Isolate.spawn`

### 3. 内存管理
- 未实现 OOM 防护
- 解决方案：添加内存水位监控

---

## 下一步行动

### 立即可执行
1. **测试 UI 流程**
   ```bash
   cd edge_ai_app
   flutter pub get
   flutter run
   ```

2. **克隆 llama.cpp**
   ```bash
   cd edge_ai_app/native/third_party
   git clone https://github.com/ggerganov/llama.cpp.git
   cd ..
   ./scripts/build_android.sh  # 或 build_ios.sh
   ```

3. **启用真实 FFI**
   - 修改 `lib/core/engine/llama_engine.dart`
   - 取消 FFI 调用注释
   - 移除 Mock 延迟

### 本周计划
- [ ] 完成 llama.cpp 集成
- [ ] 真机测试推理性能
- [ ] 优化首字延迟（TTFT）

---

## 技术栈

| 组件 | 技术选型 | 版本 |
|------|----------|------|
| UI 框架 | Flutter | 3.24+ |
| 语言 | Dart | 3.5+ |
| 推理引擎 | llama.cpp | v0.3.x |
| 状态管理 | Provider | 6.1+ |
| 本地存储 | SQLite | 2.3+ |
| FFI 绑定 | ffigen | 9.0+ |

---

## 性能目标

| 指标 | 目标值 | 当前状态 |
|------|--------|----------|
| TTFT (首字延迟) | < 2s | N/A (Mock) |
| 生成速度 | ≥ 12 tok/s | N/A (Mock) |
| 内存占用 | ≤ 1.8GB | N/A |
| 包体积 | ≤ 80MB | ~5MB (无模型) |

---

## 参考文档

- [PRD-01](../prd-01.md) - 原始需求文档
- [PRD-03](../prd-03.md) - 修复增强版 PRD
- [llama.cpp 官方文档](https://github.com/ggerganov/llama.cpp)
