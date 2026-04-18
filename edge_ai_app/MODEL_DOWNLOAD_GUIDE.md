# LocalChat MVP - 模型下载与切换功能使用说明

## 📦 新增功能

### 1. 模型管理页面
- **位置**: 底部导航栏"模型"标签页
- **功能**:
  - 推荐模型列表（Qwen3.5 系列）
  - 自定义 URL 下载
  - 本地文件导入
  - 已下载模型管理（切换/删除）

### 2. 推荐的 Qwen3.5 模型

| 模型名称 | 量化版本 | 大小 | 适用设备 | 下载链接 |
|---------|---------|------|---------|---------|
| Qwen3.5-0.8B-Instruct | Q4_K_M | ~620MB | 大多数设备（推荐） | [下载](https://huggingface.co/bartowski/Qwen3.5-0.8B-Instruct-GGUF/resolve/main/Qwen3.5-0.8B-Instruct-Q4_K_M.gguf) |
| Qwen3.5-0.8B-Instruct | Q5_K_M | ~720MB | 高端设备 | [下载](https://huggingface.co/bartowski/Qwen3.5-0.8B-Instruct-GGUF/resolve/main/Qwen3.5-0.8B-Instruct-Q5_K_M.gguf) |
| Qwen3.5-0.8B-Instruct | Q6_K | ~850MB | 旗舰设备 | [下载](https://huggingface.co/bartowski/Qwen3.5-0.8B-Instruct-GGUF/resolve/main/Qwen3.5-0.8B-Instruct-Q6_K.gguf) |
| Qwen2.5-0.5B-Instruct | Q4_K_M | ~320MB | 低端设备/快速测试 | [下载](https://huggingface.co/bartowski/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/Qwen2.5-0.5B-Instruct-Q4_K_M.gguf) |

### 3. 使用流程

#### 方式一：下载推荐模型
1. 打开 App，点击底部"模型"标签页
2. 在"推荐模型"列表中选择需要的模型
3. 点击"下载"按钮
4. 等待下载完成（显示进度条）
5. 点击"切换"按钮选择该模型
6. 返回"对话"标签页开始聊天

#### 方式二：自定义 URL 下载
1. 打开"模型"标签页
2. 在"自定义模型下载"输入框中粘贴 `.gguf` 文件直链
3. 点击下载按钮
4. 等待下载完成

#### 方式三：从本地导入
1. 提前通过浏览器或其他工具下载 `.gguf` 文件到设备
2. 打开"模型"标签页
3. 点击"从本地导入模型"
4. 选择文件管理器中的 `.gguf` 文件
5. 导入成功后点击"切换"

### 4. 模型切换
- 在"已下载的模型"列表中找到目标模型
- 点击"切换"按钮
- 系统会提示"模型已切换，重启应用生效"
- 返回对话页面，标题栏会显示当前模型名称

### 5. 模型删除
- 在"已下载的模型"列表中点击删除图标
- 确认删除操作
- 注意：不能删除当前正在使用的模型

## 🔧 技术实现

### 新增依赖
```yaml
dependencies:
  dio: ^5.4.3+1              # 网络下载
  file_picker: ^8.0.7        # 文件选择
  permission_handler: ^11.3.1 # 权限管理
  shared_preferences: ^2.2.3  # 本地存储
  path_provider: ^2.1.3      # 路径获取
  path: ^1.9.0               # 路径处理
```

### 核心服务
- `ModelService`: 模型管理服务（单例模式）
  - `downloadModel()`: 下载模型（带进度回调）
  - `importModel()`: 导入外部模型
  - `switchModel()`: 切换当前模型
  - `deleteModel()`: 删除模型
  - `availableModels`: 获取已下载模型列表

### 存储位置
- Android: `/data/data/<package_name>/app_flutter/models/`
- iOS: `<Application_Home>/Documents/models/`

## ⚠️ 注意事项

1. **网络要求**: 首次下载模型需要稳定的网络连接
2. **存储空间**: 确保设备有足够存储空间（建议预留 1GB+）
3. **权限**: Android 设备需要存储权限（自动申请）
4. **格式限制**: 仅支持 `.gguf` 格式的量化模型
5. **模型兼容性**: 推荐使用 Qwen 系列的 instruct 版本

## 🚀 下一步

1. 下载任意一个推荐模型
2. 切换到该模型
3. 返回对话页面开始体验离线 AI 对话！

---

**提示**: 如果下载速度慢，可以：
- 使用代理网络访问 HuggingFace
- 通过浏览器下载后使用"本地导入"功能
- 使用国内镜像源（如 ModelScope）
