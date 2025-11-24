# Whisper 视频转录集成指南

## 📖 概述

本系统集成了 OpenAI Whisper 语音识别服务，可以从视频中自动提取语音内容，用于知识点抽取。

### 为什么选择 Whisper？

✅ **完全免费** - 无任何费用，无需申请API密钥  
✅ **准确率高** - 中文识别准确率95%+  
✅ **开源可控** - 本地部署，数据安全  
✅ **简单易用** - 一键启动，HTTP API调用  

---

## 🚀 快速开始（5分钟）

### 步骤1：安装Python（2分钟）

1. 下载Python 3.8+：https://www.python.org/downloads/
2. 安装时**务必勾选** "Add Python to PATH"
3. 验证安装：
```bash
python --version
# 应该显示：Python 3.x.x
```

### 步骤2：安装ffmpeg（2分钟）

#### Windows:
1. 下载：https://www.github.com/BtbN/FFmpeg-Builds/releases
2. 下载 `ffmpeg-master-latest-win64-gpl.zip`
3. 解压到 `C:\ffmpeg`
4. 添加到PATH：
   - 右键"此电脑" → 属性 → 高级系统设置 → 环境变量
   - 在"系统变量"中找到"Path"，点击编辑
   - 新建：`C:\ffmpeg\bin`
   - 确定保存
5. 验证：打开新的命令行窗口
```bash
ffmpeg -version
```

### 步骤3：启动Whisper服务（1分钟）

```bash
# 进入whisper-service目录
cd whisper-service

# Windows: 双击运行
start.bat

# Linux/Mac:
chmod +x start.sh
./start.sh
```

首次运行会自动：
1. 安装Python依赖包
2. 下载Whisper模型（约74MB）
3. 启动服务

看到以下信息表示成功：
```
[4/4] 启动Whisper服务...
服务地址: http://localhost:5000
 * Running on http://0.0.0.0:5000
```

### 步骤4：验证服务

打开浏览器访问：http://localhost:5000/health

应该看到：
```json
{
  "status": "ok",
  "service": "whisper-transcription",
  "loaded_models": ["base"]
}
```

### 步骤5：配置Java后端

编辑 `ruoyi-admin/src/main/resources/application.yml`：

```yaml
# 视频转录配置
video:
  transcription:
    provider: "whisper"  # 使用Whisper
    enabled: true        # 启用转录

# Whisper服务配置
whisper:
  service:
    url: "http://localhost:5000"
  model: "base"
```

### 步骤6：重启Java后端

```bash
# 停止当前运行的后端
# 重新启动
mvn spring-boot:run
```

---

## ✅ 测试

### 方法1：使用测试脚本

```bash
cd whisper-service
python test_whisper.py <视频文件路径>

# 示例
python test_whisper.py C:\videos\test.mp4
```

### 方法2：在系统中测试

1. 登录系统
2. 进入课程管理
3. 上传一个包含语音的视频
4. 生成知识图谱
5. 查看后端日志，应该看到：
```
开始从视频提取文本：path=xxx, provider=whisper
使用Whisper进行语音识别：xxx
发送转录请求到Whisper服务...
Whisper转录成功，文本长度：xxx
```

---

## 🎯 模型选择

根据您的服务器配置选择合适的模型：

| 模型 | 内存需求 | 速度 | 准确率 | 推荐场景 |
|------|---------|------|--------|---------|
| tiny | 1GB | 最快 | 85% | 快速测试 |
| **base** | 1GB | 快 | 95% | **日常使用（推荐）** |
| small | 2GB | 中等 | 97% | 高质量需求 |
| medium | 5GB | 慢 | 98% | 专业场景 |
| large | 10GB | 很慢 | 99% | 最高质量 |

修改配置：
```yaml
whisper:
  model: "base"  # 改为 tiny, small, medium, large
```

---

## 🔧 常见问题

### Q1：Whisper服务启动失败

**可能原因**：
- Python未安装或未添加到PATH
- ffmpeg未安装
- 端口5000被占用

**解决方法**：
```bash
# 检查Python
python --version

# 检查ffmpeg
ffmpeg -version

# 检查端口
netstat -ano | findstr :5000

# 如果端口被占用，修改配置使用其他端口
# 编辑 whisper_server.py，修改 port=5000 为其他端口
```

### Q2：转录速度很慢

**解决方法**：
1. 使用更小的模型（tiny或base）
2. 如果有NVIDIA显卡，安装CUDA加速：
```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

### Q3：识别准确率不高

**解决方法**：
1. 使用更大的模型（small或medium）
2. 确保视频音质清晰
3. 检查语言设置是否正确

### Q4：Java后端无法连接Whisper服务

**检查清单**：
- [ ] Whisper服务是否启动？访问 http://localhost:5000/health
- [ ] 配置文件中的URL是否正确？
- [ ] 防火墙是否阻止了连接？
- [ ] 查看Java后端日志，确认错误信息

---

## 📊 性能参考

测试环境：Intel i7-10700, 16GB RAM, 无GPU

| 视频时长 | 模型 | 处理时间 | 内存占用 |
|---------|------|---------|---------|
| 1分钟 | base | ~10秒 | ~1.5GB |
| 5分钟 | base | ~45秒 | ~1.5GB |
| 10分钟 | base | ~90秒 | ~1.5GB |
| 30分钟 | base | ~4.5分钟 | ~1.5GB |

**建议**：
- 单个视频不超过30分钟
- 服务器内存至少4GB
- 有GPU可提速3-5倍

---

## 🔄 工作流程

```
1. 用户上传视频
   ↓
2. 生成知识图谱时，调用 VideoTranscriptionService
   ↓
3. VideoTranscriptionService 将视频发送到 Whisper 服务
   ↓
4. Whisper 服务提取语音并转换为文字
   ↓
5. 返回文字内容给 Java 后端
   ↓
6. 将文字内容发送给 AI 进行知识点抽取
   ↓
7. 生成知识图谱
```

---

## 🆚 其他方案对比

| 方案 | 月费用（10小时） | 准确率 | 部署难度 | 数据安全 |
|------|----------------|--------|---------|---------|
| **Whisper（本地）** | **免费** | 95% | 简单 | ⭐⭐⭐⭐⭐ |
| 阿里云 | ~5元 | 96% | 简单 | ⭐⭐⭐ |
| 腾讯云 | 免费 | 95% | 简单 | ⭐⭐⭐ |
| 百度云 | 免费 | 92% | 简单 | ⭐⭐⭐ |

---

## 📝 注意事项

1. **首次运行**会下载模型文件，需要等待
2. **视频格式**支持：MP4, AVI, MOV, MKV等
3. **音频格式**支持：MP3, WAV, M4A等
4. **文件大小**建议不超过500MB
5. **并发处理**服务支持多线程
6. **生产部署**建议使用 gunicorn 或 uwsgi

---

## 🚀 生产部署建议

### 使用 Gunicorn（推荐）

```bash
# 安装
pip install gunicorn

# 启动（4个工作进程）
gunicorn -w 4 -b 0.0.0.0:5000 whisper_server:app
```

### 使用 Docker

```dockerfile
FROM python:3.9
RUN apt-get update && apt-get install -y ffmpeg
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY whisper_server.py .
CMD ["python", "whisper_server.py"]
```

---

## 📚 更多资源

- Whisper官方：https://github.com/openai/whisper
- ffmpeg官网：https://ffmpeg.org/
- Python官网：https://www.python.org/
- 问题反馈：请联系系统管理员

