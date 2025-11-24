# 知识图谱（KG）功能 - 本地测试与 Qianwen 集成说明

此文件说明如何配置和测试后端的知识图谱生成（`generateCourseGraph`）功能，及如何为 `AiExtractionService` 提供千问（Qianwen）API 配置。

## 环境变量（推荐）
- QIANWEN_API_URL：千问 HTTP 接口地址，例如 `https://api.qianwen.example/v1/extract`
- QIANWEN_API_KEY：API Key（如果需要 Bearer Token），在 Spring Boot 中会被映射到 `qianwen.api.key`。

示例（硅基流动 / SiliconFlow）：
- 地址: `https://api.siliconflow.cn/v1/chat/completions`
- 环境变量名保持为 `QIANWEN_API_URL` 和 `QIANWEN_API_KEY`。
- 可选模型变量：`QIANWEN_API_MODEL`，默认 `Qwen/QwQ-32B`。

在 Windows PowerShell 下示例：

```powershell
$env:QIANWEN_API_URL = "https://api.siliconflow.cn/v1/chat/completions"
$env:QIANWEN_API_KEY = "<your-token>"
# 可选：指定模型
$env:QIANWEN_API_MODEL = "Qwen/QwQ-32B"
```

或者在 `application.yml` 中加入（不推荐在源码中写明明文密钥）：

```yaml
qianwen:
  api:
    url: ${QIANWEN_API_URL:}
    key: ${QIANWEN_API_KEY:}
```

## 本地触发生成（注意权限）
后端接口（需要登录并有 `system:graph:generate` 权限）：

```
POST http://localhost:8080/system/graph/extract/course/{courseId}
```

使用 `curl` 示例（需要登录后获取 `Admin-Token` cookie）：

```bash
curl -v -X POST "http://localhost:8080/system/graph/extract/course/123" \
  -H "Cookie: Admin-Token=<your-token-here>"
```

如果你想在开发阶段临时跳过权限验证（仅限本地调试），可以在安全配置中临时放开该路径（谨慎）。

## 注意事项
- `AiExtractionService` 已实现一个模板：当 `qianwen.api.url` 被配置时会尝试调用该接口。由于不同厂商返回格式不同，模板会尝试从常见字段（`candidates`/`items`/`data`/`result`）解析候选项。请根据你从千问处得到的实际响应格式调整 `AiExtractionService.callQianwen` 的解析逻辑。
- 若调用失败或未配置 URL，服务将回退到本地的占位抽取（按句切分前三句）。

## 下一步建议
- 提供千问 API 文档或示例响应，我将把 `AiExtractionService` 的解析逻辑改为精确匹配其返回结构。
- 为视频/文档实现 ASR 与文件解析，将分段后的文本通过该服务抽取知识点。

---
