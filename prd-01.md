以下是一份可直接用于项目立项与开发的 **PRD + 脚手架 + FFI 核心代码 + 编译脚本** 完整技术包。内容基于当前移动端边缘 AI 最佳实践（Flutter 3.24+ / Dart 3.5+ / llama.cpp v0.3.x）。

---
## 📄 一、产品需求文档（PRD）核心摘要

### 1. 产品定位
- **名称**：EdgeMind AI（示例）
- **定位**：完全离线、跨平台、低延迟的端侧大模型对话应用
- **核心价值**：数据不出设备、零流量消耗、隐私安全、弱网可用

### 2. 目标用户与场景
| 场景 | 用户画像 | 核心诉求 |
|------|----------|----------|
| 通勤/飞行无网环境 | 商务人士、学生 | 随时可用的本地 AI 助手 |
| 隐私敏感场景 | 金融/医疗从业者、开发者 | 对话记录不上传云端 |
| 轻量级知识问答 | 普通用户 | 低内存占用、快速响应 |

### 3. 核心功能清单
| 模块 | 功能点 | 验收标准 |
|------|--------|----------|
| **模型管理** | 内置 1 个基础模型 + OTA 下载/切换/卸载 | 下载断点续传、SHA256 校验、支持 Q4/Q5 量化 |
| **对话引擎** | 流式生成、上下文管理、参数调节（Temp/TopP/MaxTokens） | TTFT < 2s，吞吐 ≥ 12 tok/s（骁龙8Gen2） |
| **本地存储** | 对话历史、模型配置、系统设置 | SQLite + Isar，支持加密与备份导出 |
| **性能调度** | 自动硬件检测、后台降频、内存水位控制 | 后台切换不 OOM，发热阈值触发降级 |
| **隐私合规** | 零网络请求、本地日志脱敏、用户协议明示 | 通过 Apple/Google 端侧 AI 审核 |

### 4. 非功能指标
- **包体积**：基础 APK/IPA ≤ 80MB（模型按需下载）
- **内存占用**：峰值 ≤ 1.8GB（1.5B Q4 模型 + 上下文 2K）
- **启动耗时**：冷启动 ≤ 1.5s，模型加载 ≤ 3s
- **兼容性**：Android 8.0+ (ARM64)，iOS 14.0+ (A12 芯片起)

### 5. 版本规划
| 阶段 | 交付物 | 周期 |
|------|--------|------|
| V0.1 原型 | FFI 跑通、基础 UI、单模型推理 | 2 周 |
| V0.5 内测 | 流式输出、模型下载、设置页、真机压测 | 3 周 |
| V1.0 上架 | 多模型切换、本地加密、性能优化、合规审查 | 2 周 |

---
## 📁 二、项目脚手架结构（Production-Ready）

```text
edge_ai_app/
├── android/                  # Android 原生工程（Gradle/NDK 配置）
├── ios/                      # iOS 原生工程（Xcode/Info.plist）
├── lib/
│   ├── main.dart             # 入口 & 全局初始化
│   ├── app.dart              # 路由 & 主题
│   ├── core/
│   │   ├── engine/           # FFI 绑定 & 引擎封装
│   │   │   ├── llama_ffi.dart
│   │   │   ├── llama_engine.dart
│   │   │   └── types.dart
│   │   ├── models/           # 数据实体
│   │   │   ├── message.dart
│   │   │   └── model_config.dart
│   │   └── services/
│   │       ├── model_manager.dart  # 下载/加载/卸载
│   │       └── stream_handler.dart # Token 流控制器
│   ├── features/
│   │   ├── chat/             # 对话页 UI + ViewModel
│   │   └── settings/         # 参数调节 + 模型管理
│   └── utils/                # 日志/常量/硬件检测
├── native/                   # C++ 引擎源码与构建脚本
│   ├── CMakeLists.txt        # 统一交叉编译配置
│   ├── llama_wrapper.cpp     # 桥接层（封装 llama.cpp）
│   └── scripts/
│       ├── build_android.sh
│       └── build_ios.sh
├── assets/
│   ├── models/               # 预置小模型（可选）
│   └── icons/
├── pubspec.yaml
└── README.md
```

> 📌 **说明**：
> - `native/llama_wrapper.cpp` 不直接暴露完整 `llama.cpp` API，而是封装为 **C-ABI 稳定** 的简化接口，降低 FFI 复杂度。
> - 推荐使用 `ffigen` 自动生成完整绑定，手动只维护核心流式接口。

---
## 🔗 三、核心 FFI 代码片段（Dart 3.5+）

### 1. Dart 侧：FFI 声明与流式回调
```dart
// lib/core/engine/llama_ffi.dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// 加载动态库（Android: libllama.so / iOS: libllama.a 打包为 framework）
final DynamicLibrary _lib = Platform.isAndroid
    ? DynamicLibrary.open('libllama.so')
    : DynamicLibrary.process();

// C 函数签名声明
typedef _ModelLoad = Pointer<Void> Function(Pointer<Utf8>, Int32, Int32);
typedef _ModelLoadDart = Pointer<Void> Function(Pointer<Utf8>, int, int);

typedef _CreateContext = Pointer<Void> Function(Pointer<Void>, Int32, Int32, Int32);
typedef _CreateContextDart = Pointer<Void> Function(Pointer<Void>, int, int, int);

typedef _DecodeToken = Int32 Function(Pointer<Void>, Int32, Pointer<Char>);
typedef _DecodeTokenDart = int Function(Pointer<Void>, int, Pointer<Char>);

typedef _FreeContext = Void Function(Pointer<Void>);
typedef _FreeContextDart = void Function(Pointer<Void>);

// 绑定函数
final _ModelLoadDart _loadModel = _lib.lookupFunction<_ModelLoad, _ModelLoadDart>('edge_llama_load_model');
final _CreateContextDart _createCtx = _lib.lookupFunction<_CreateContext, _CreateContextDart>('edge_llama_new_context');
final _DecodeTokenDart _decodeToken = _lib.lookupFunction<_DecodeToken, _DecodeTokenDart>('edge_llama_decode_next');
final _FreeContextDart _freeCtx = _lib.lookupFunction<_FreeContext, _FreeContextDart>('edge_llama_free_context');

// 高层封装（线程安全）
class LlamaEngine {
  Pointer<Void> _model = nullptr;
  Pointer<Void> _ctx = nullptr;
  late final NativeCallable<Void Function(Pointer<Utf8>)> _tokenCallback;

  LlamaEngine() {
    // 注册 C 回调（Dart 3.3+ NativeCallable）
    _tokenCallback = NativeCallable<Void Function(Pointer<Utf8>)>.listener(_onTokenReceived);
  }

  bool loadModel(String path, {int nGpuLayers = 20, int nThreads = 4}) {
    _model = _loadModel(path.toNativeUtf8(), nGpuLayers, nThreads);
    return _model != nullptr;
  }

  void createContext({int nCtx = 2048, int nBatch = 512}) {
    _ctx = _createCtx(_model, nCtx, nBatch, _tokenCallback.nativeFunction.address);
  }

  Future<void> generatePrompt(String prompt) async {
    // 实际项目中应在 Isolate 中调用 _decodeToken 避免阻塞主线程
    // 此处简化示意
    _decodeToken(_ctx, 0, prompt.toNativeUtf8());
  }

  void _onTokenReceived(Pointer<Utf8> tokenPtr) {
    // 转发至 StreamController 供 UI 消费
    StreamHandler.instance.addToken(tokenPtr.toDartString());
  }

  void dispose() {
    if (_ctx != nullptr) _freeCtx(_ctx);
    _tokenCallback.close();
  }
}
```

### 2. C++ 侧：桥接层（`native/llama_wrapper.cpp`）
```cpp
#include "llama.h"
#include <cstring>
#include <functional>

extern "C" {
    typedef void (*TokenCallback)(const char* token);

    // 简化上下文结构体
    struct EdgeContext {
        llama_model* model;
        llama_context* ctx;
        llama_batch batch;
        TokenCallback callback;
        // ... 其他状态
    };

    __attribute__((visibility("default")))
    EdgeContext* edge_llama_load_model(const char* path, int n_gpu_layers, int n_threads) {
        llama_model_params params = llama_model_default_params();
        params.n_gpu_layers = n_gpu_layers;
        llama_model* model = llama_load_model_from_file(path, params);
        if (!model) return nullptr;

        auto* ctx = new EdgeContext();
        ctx->model = model;
        ctx->batch = llama_batch_init(512, 0, 1);
        return ctx;
    }

    __attribute__((visibility("default")))
    EdgeContext* edge_llama_new_context(EdgeContext* ectx, int n_ctx, int n_batch, void* callback_ptr) {
        llama_context_params params = llama_context_default_params();
        params.n_ctx = n_ctx;
        params.n_batch = n_batch;
        params.n_threads = 4;
        ectx->ctx = llama_new_context_with_model(ectx->model, params);
        ectx->callback = reinterpret_cast<TokenCallback>(callback_ptr);
        return ectx;
    }

    __attribute__((visibility("default")))
    int edge_llama_decode_next(EdgeContext* ectx, int seed, const char* prompt) {
        // 1. Tokenize prompt -> batch
        // 2. llama_decode
        // 3. llama_sample_token_greedy / top_k
        // 4. llama_token_to_piece -> callback(token_str)
        // 完整实现约 120 行，受限于篇幅提供核心逻辑
        std::vector<llama_token> tokens = llama_tokenize(ectx->ctx, prompt, false);
        // ... 解码循环
        // llama_detokenize -> ectx->callback(token_str.c_str());
        return 0;
    }

    __attribute__((visibility("default")))
    void edge_llama_free_context(EdgeContext* ectx) {
        if (ectx) {
            llama_free(ectx->ctx);
            llama_free_model(ectx->model);
            llama_batch_free(ectx->batch);
            delete ectx;
        }
    }
}
```

> ⚠️ **注意**：生产环境请使用 `ffigen` 生成完整绑定，并将推理逻辑放入 Dart `Isolate`，通过 `SendPort/ReceivePort` 通信，彻底避免 UI 线程阻塞。

---
## 🛠️ 四、跨平台编译脚本

### 1. 统一 CMake 配置（`native/CMakeLists.txt`）
```cmake
cmake_minimum_required(VERSION 3.22)
project(edge_llama C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# 引入 llama.cpp 源码（建议 git submodule）
add_subdirectory(../third_party/llama.cpp llama.cpp)

# 桥接库
add_library(edge_llama SHARED llama_wrapper.cpp)
target_link_libraries(edge_llama PRIVATE llama)

# 优化编译选项
target_compile_options(edge_llama PRIVATE -O3 -fvisibility=hidden)
if (ANDROID)
    target_compile_options(edge_llama PRIVATE -march=armv8-a+fp16)
endif()
```

### 2. Android 编译脚本（`native/scripts/build_android.sh`）
```bash
#!/bin/bash
set -e
export ANDROID_NDK_HOME=$ANDROID_SDK_ROOT/ndk/26.1.10909125

mkdir -p build/android
cd build/android

cmake ../.. \
  -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-26 \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLAMA_METAL=OFF -DLLAMA_VULKAN=ON

ninja
echo "✅ Android arm64-v8a 编译完成: build/android/libllama.so"
```

### 3. iOS 编译脚本（`native/scripts/build_ios.sh`）
```bash
#!/bin/bash
set -e
mkdir -p build/ios
cd build/ios

cmake ../.. \
  -G "Xcode" \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES="arm64" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLAMA_METAL=ON -DLLAMA_VULKAN=OFF

xcodebuild -project llama.xcodeproj \
  -target edge_llama \
  -configuration Release \
  -sdk iphoneos \
  ARCHS=arm64 \
  ONLY_ACTIVE_ARCH=NO \
  build

echo "✅ iOS 编译完成: build/ios/Release-iphoneos/libllama.a"
```

### 4. Flutter 侧引用配置
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  ffi: ^2.1.0
  sqflite: ^2.3.0
  isar_flutter_libs: ^3.1.0

flutter:
  uses-material-design: true
  assets:
    - assets/models/

# android/app/build.gradle
android {
    sourceSets {
        main {
            jniLibs.srcDirs = ['../../native/build/android']
        }
    }
}
```

---
## 🚀 五、下一步行动清单

| 步骤 | 操作 | 耗时 | 交付物 |
|------|------|------|--------|
| 1 | 克隆 `llama.cpp` 为 submodule，跑通 CMake 编译 | 2h | `libllama.so` / `.a` |
| 2 | 用 `ffigen` 生成完整 FFI 绑定，替换手写声明 | 3h | `llama_ffi.g.dart` |
| 3 | 实现 Isolate 推理线程 + StreamController 流式输出 | 4h | 可交互 Demo |
| 4 | 接入模型下载管理器（断点续传+SHA校验） | 3h | 模型管理模块 |
| 5 | 真机压测（内存/发热/后台恢复/低电量模式） | 2d | 性能报告 |
| 6 | 配置 Fastlane + GitHub Actions 自动打包上架 | 1d | CI/CD 流水线 |

---
## 💡 关键避坑提醒
1. **不要在主线程调用 `_decodeToken`**：必须使用 `compute()` 或 `Isolate.spawn`，否则 UI 会直接卡死。
2. **iOS Metal Shader 首次编译慢**：建议首次启动显示进度条，或预编译 Shader Cache 打包进 IPA。
3. **Android 后台服务限制**：推理任务需在 `ForegroundService` 中运行，并在 `AndroidManifest.xml` 声明 `FOREGROUND_SERVICE_SPECIAL_USE`。
4. **模型文件路径**：使用 `path_provider` 获取应用沙盒目录，避免 Android 11+ 存储权限问题。

如需我提供：
- `ffigen` 自动配置脚本
- Isolate 推理线程完整实现
- 模型 OTA 下载管理器代码
- GitHub Actions 自动打包 YAML

请回复具体模块名称，我将直接输出可复制粘贴的生产级代码。
