# 知识图谱关系抽取功能说明

## 功能概述

本系统实现了基于 AI（千问大模型）的知识点和知识点关系自动抽取功能，支持从题库中提取知识点并建立它们之间的关系，构建完整的知识图谱。

## 核心功能

### 1. 知识点抽取
- 从题目的题干、选项、解析中自动提取知识点
- 每个知识点包含：名称、定义、置信度
- 自动去重并保存到 `knowledge_point` 表

### 2. 知识点关系抽取
- 自动识别知识点之间的关系
- 支持的关系类型：
  - `prerequisite`: 前置关系（A 是 B 的前置知识）
  - `uses`: 使用关系（A 使用了 B）
  - `related_method`: 相关方法
  - `similar`: 相似关系
- 关系保存到 `kp_relation` 表

### 3. 两级知识图谱
- **课程级知识图谱**：整合课程所有资源和题目的知识点
- **章节级知识图谱**：针对特定章节的细化知识点

## 数据库表结构

### knowledge_point（知识点表）
```sql
- id: 主键
- course_id: 所属课程
- title: 知识点名称
- description: 详细解释
- level: 难度等级（BASIC/INTERMEDIATE/ADVANCED）
- creator_user_id: 创建者（user 表的 id）
- create_time: 创建时间
```

**注意**：
1. **level 字段**根据 AI 置信度自动设置：
   - 置信度 ≥ 0.7 → level = BASIC（基础）
   - 置信度 0.4-0.7 → level = INTERMEDIATE（中级）
   - 置信度 < 0.4 → level = ADVANCED（高级）

2. **creator_user_id 字段**：
   - 在异步任务中无法获取当前用户 ID
   - 系统会自动使用默认值 1（admin 用户）
   - 确保数据库中存在 id=1 的用户记录

### kp_relation（知识点关系表）
```sql
- id: 主键
- from_kp_id: 源知识点 ID
- to_kp_id: 目标知识点 ID
- relation_type: 关系类型
- ai_generated: 是否 AI 生成（1=是，0=否）
- create_time: 创建时间
```

### knowledge_graph（知识图谱表）
```sql
- id: 主键
- course_id: 关联课程
- graph_type: 图谱类型（COURSE/CHAPTER）
- graph_data: 图谱数据（JSON 格式，用于前端可视化）
- status: 状态（active/archived）
```

## API 接口

### 1. 生成课程知识图谱
```
POST /system/graph/extract/course/{courseId}
```
- 功能：为指定课程生成知识图谱（异步）
- 参数：courseId - 课程 ID
- 返回：任务提交成功消息

### 2. 生成章节知识图谱
```
POST /system/graph/extract/chapter/{courseId}/{chapterId}
```
- 功能：为指定章节生成知识图谱（异步）
- 参数：
  - courseId - 课程 ID
  - chapterId - 章节 ID
- 返回：任务提交成功消息

### 3. 查询知识图谱列表
```
GET /system/graph/list
```
- 功能：查询知识图谱列表
- 参数：可选的筛选条件（courseId, graphType 等）

## 使用流程

### 1. 配置千问 API
在 `application.yml` 中配置：
```yaml
qianwen:
  api:
    url: https://api.siliconflow.cn/v1/chat/completions
    key: your-api-key-here
    model: Qwen/QwQ-32B
```

### 2. 准备题库数据
确保题目表中有数据，包含：
- title（题干）
- explanation（解析）
- options（选项，可选）
- course_id 和 chapter_id

### 3. 触发知识点抽取

#### 方式一：通过 API 调用
```bash
# 生成课程知识图谱
curl -X POST http://localhost:8080/system/graph/extract/course/33

# 生成章节知识图谱
curl -X POST http://localhost:8080/system/graph/extract/chapter/33/1
```

#### 方式二：通过前端界面
在知识图谱管理页面点击"生成知识图谱"按钮

### 4. 查看结果

#### 查看知识点
```sql
SELECT * FROM knowledge_point WHERE course_id = 33;
```

#### 查看知识点关系
```sql
SELECT 
    r.id,
    kp1.title AS source_kp,
    kp2.title AS target_kp,
    r.relation_type,
    r.ai_generated
FROM kp_relation r
JOIN knowledge_point kp1 ON r.from_kp_id = kp1.id
JOIN knowledge_point kp2 ON r.to_kp_id = kp2.id
WHERE kp1.course_id = 33;
```

#### 查看知识图谱
```sql
SELECT * FROM knowledge_graph WHERE course_id = 33;
```

## 核心代码文件

1. **AiExtractionService.java**
   - 路径：`ruoyi-system/src/main/java/com/ruoyi/system/service/impl/AiExtractionService.java`
   - 功能：调用千问 API 抽取知识点和关系

2. **KnowledgeGraphServiceImpl.java**
   - 路径：`ruoyi-system/src/main/java/com/ruoyi/system/service/impl/KnowledgeGraphServiceImpl.java`
   - 功能：处理知识点和关系的保存逻辑

3. **KnowledgeGraphController.java**
   - 路径：`ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/KnowledgeGraphController.java`
   - 功能：提供 REST API 接口

## 注意事项

1. **异步处理**：知识图谱生成是异步任务，不会阻塞请求
2. **去重机制**：相同名称的知识点会自动去重
3. **关系验证**：只有当源和目标知识点都存在时才会保存关系
4. **AI 回退**：如果千问 API 不可用，会使用本地正则表达式回退方案
5. **日志记录**：所有操作都有详细的日志记录，便于调试

## 知识图谱可视化

### 访问可视化页面
1. 登录系统后，进入"知识图谱管理"页面
2. 点击"知识图谱可视化"按钮
3. 或直接访问：`http://localhost/system/graph/visualize`

### 可视化功能特性

#### 1. 交互式图谱展示
- **基于 ECharts 的力导向图**：节点自动布局，支持拖拽
- **节点大小**：根据置信度动态调整（置信度越高，节点越大）
- **节点颜色**：
  - 绿色：高置信度（≥0.7）
  - 橙色：中置信度（0.4-0.7）
  - 红色：低置信度（<0.4）
- **边的颜色**：根据关系类型区分
  - 蓝色：prerequisite（前置关系）
  - 绿色：uses（使用关系）
  - 橙色：related_method（相关方法）
  - 灰色：similar（相似关系）

#### 2. 操作功能
- **缩放和平移**：鼠标滚轮缩放，拖拽平移
- **节点点击**：点击节点查看详细信息（名称、定义、置信度、ID）
- **关系高亮**：鼠标悬停在节点上，高亮显示相邻节点和边
- **导出图片**：一键导出为 PNG 图片

#### 3. 筛选功能
- **按课程筛选**：选择特定课程查看其知识图谱
- **按章节筛选**：选择特定章节查看细化的知识图谱
- **一键生成**：直接在可视化页面触发知识图谱生成

### 使用示例

```javascript
// 1. 选择课程
选择课程：高等数学

// 2. 选择章节（可选）
选择章节：第1章 极限

// 3. 加载知识图谱
点击"加载知识图谱"按钮

// 4. 查看可视化结果
- 节点：极限、洛必塔法则、等价无穷小、小角度近似等
- 边：极限 -> 洛必塔法则（prerequisite）
      极限 -> 等价无穷小（uses）
```

### 前端文件结构

```
ruoyi-ui/src/
├── api/system/
│   └── graph.js                    # API 接口定义
├── views/system/graph/
│   ├── index.vue                   # 知识图谱管理页面
│   └── visualize.vue               # 知识图谱可视化页面（新增）
└── router/index.js                 # 路由配置
```

### 技术栈
- **ECharts 5.x**：图表可视化库
- **Vue 2.x**：前端框架
- **Element UI**：UI 组件库

## 扩展建议

1. ✅ 添加知识图谱可视化前端组件（已完成）
2. 添加知识点合并功能（处理同义词）
3. 实现知识点推荐算法
4. 支持手动编辑知识点关系
5. 实现基于知识图谱的个性化学习路径推荐
6. 添加知识图谱对比功能（比较不同章节的知识点）
7. 支持知识图谱的版本管理和历史回溯

