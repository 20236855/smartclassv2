# 智慧课程——个性化学习导航与自适应学习引擎 API接口文档

## 项目代号："学习向导"

## 核心产品价值
为学生提供千人千面的学习路径和精准的学习资源推荐，变"人找资源"为"资源找人"，提升学习效率。

---

## 一、学习数据驾驶舱 API

### 1.1 获取我的课程列表

**接口描述**：查询当前登录学生已选上的所有课程

**请求方式**：`GET`

**请求路径**：`/system/student/my-courses`

**请求参数**：无（自动获取当前登录用户）

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {
      "id": 33,
      "title": "高等数学",
      "description": "大学数学基础课程",
      "coverImage": "/profile/upload/course_cover.jpg",
      "status": "ongoing",
      "startDate": "2025-09-01",
      "endDate": "2026-01-15"
    }
  ]
}
```

**前端调用**：
```javascript
import { getMyCourses } from '@/api/system/student'
getMyCourses().then(response => {
  console.log(response.data)
})
```

---

### 1.2 获取能力雷达图数据

**接口描述**：展示学生在某课程中的能力掌握情况（多维度能力模型）

**请求方式**：`GET`

**请求路径**：`/learning/radar/getData`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| studentId | Long | 是 | 学生ID（user表id） |
| courseId | Long | 是 | 课程ID |

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": [
    {
      "competencyName": "计算能力",
      "score": 75.5
    },
    {
      "competencyName": "逻辑推理",
      "score": 82.3
    },
    {
      "competencyName": "空间想象",
      "score": 68.0
    }
  ]
}
```

**前端调用**：
```javascript
import { getRadarData } from '@/api/learning/radar'
getRadarData({ studentId: 1, courseId: 33 }).then(response => {
  console.log(response.data)
})
```

---

### 1.3 获取数字分身

**接口描述**：计算学生的学习画像，匹配4种学习类型（稳步积累型/逻辑攻坚型/高效突击型/查漏补缺型）

**请求方式**：`GET`

**请求路径**：`/system/digitalTwin/calculate`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| studentId | Long | 是 | 学生ID（user表id） |
| courseId | Long | 是 | 课程ID |

**响应示例**：
```json
{
  "code": 200,
  "msg": "计算成功",
  "data": {
    "twinType": "稳步积累型",
    "score": 15,
    "features": [
      "视频学习完成率70%",
      "练习正确率85%",
      "学习时间分布均匀"
    ],
    "scoreDetails": [
      {
        "twinType": "稳步积累型",
        "score": 15,
        "ruleMatches": [
          "视频学习完成率≥70%：符合 (当前75.05%, +5分)",
          "练习正确率≥80%：符合 (当前85%, +5分)"
        ]
      }
    ]
  }
}
```

**前端调用**：
```javascript
import { calculateDigitalTwin } from '@/api/learning/digitalTwin'
calculateDigitalTwin({ studentId: 1, courseId: 33 }).then(response => {
  console.log(response.data)
})
```

---

### 1.4 获取学生知识点掌握情况列表

**接口描述**：查询学生对课程中各知识点的掌握情况（支撑知识图谱状态标识）

**请求方式**：`GET`

**请求路径**：`/learning/mastery/list`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| studentUserId | Long | 否 | 学生ID（user表id） |
| courseId | Long | 否 | 课程ID |
| kpId | Long | 否 | 知识点ID |
| masteryStatus | String | 否 | 掌握状态：mastered/learning/weak/not_started |

**响应示例**：
```json
{
  "code": 200,
  "msg": "查询成功",
  "total": 10,
  "rows": [
    {
      "id": 1,
      "studentUserId": 1,
      "courseId": 33,
      "kpId": 123,
      "correctCount": 8,
      "totalCount": 10,
      "accuracy": "80.00",
      "lastTestScore": 85,
      "lastTestTime": "2025-11-27",
      "trend": "up",
      "masteryScore": 75,
      "masteryStatus": "learning"
    }
  ]
}
```

**前端调用**：
```javascript
import { listMastery } from '@/api/learning/mastery'
listMastery({ studentUserId: 1, courseId: 33 }).then(response => {
  console.log(response.rows)
})
```

---

### 1.5 获取视频学习行为数据

**接口描述**：查询学生的视频学习行为记录（观看时长、完成率、快进次数等）

**请求方式**：`GET`

**请求路径**：`/system/behavior/list`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| studentId | Long | 否 | 学生ID（sys_user表user_id） |
| videoId | Long | 否 | 视频ID（section表id） |
| courseId | Long | 否 | 课程ID（通过关联查询） |

**响应示例**：
```json
{
  "code": 200,
  "msg": "查询成功",
  "total": 5,
  "rows": [
    {
      "id": 1,
      "studentId": 1,
      "videoId": 10,
      "watchDuration": 1200,
      "videoDuration": 1500,
      "completionRate": 80.0,
      "watchCount": 2,
      "isCompleted": 1,
      "fastForwardCount": 3,
      "pauseCount": 5,
      "playbackSpeed": 1.5,
      "firstWatchAt": "2025-11-20 10:00:00",
      "lastWatchAt": "2025-11-27 15:30:00",
      "sectionTitle": "第一章 函数与极限",
      "courseName": "高等数学",
      "chapterName": "第一章"
    }
  ]
}
```

**前端调用**：
```javascript
import { listBehavior } from '@/api/system/behavior'
listBehavior({ studentId: 1, courseId: 33 }).then(response => {
  console.log(response.rows)
})
```

---

### 1.6 获取作业/任务列表

**接口描述**：查询课程中的作业或考试列表

**请求方式**：`GET`

**请求路径**：`/system/assignment/list`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| courseId | Long | 否 | 课程ID |
| chapterId | Long | 否 | 章节ID |
| type | String | 否 | 类型：homework/exam |
| status | Integer | 否 | 状态：0=草稿,1=已发布,2=已结束 |

**响应示例**：
```json
{
  "code": 200,
  "msg": "查询成功",
  "total": 3,
  "rows": [
    {
      "id": 1,
      "title": "第一章作业",
      "courseId": 33,
      "chapterId": 1,
      "type": "homework",
      "status": 1,
      "startTime": "2025-11-20 00:00:00",
      "endTime": "2025-12-01 23:59:59",
      "duration": 60,
      "totalScore": 100,
      "passScore": 60
    }
  ]
}
```

**前端调用**：
```javascript
import { listAssignment } from '@/api/system/assignment'
listAssignment({ courseId: 33, chapterId: 1 }).then(response => {
  console.log(response.rows)
})
```

---

## 二、集成并利用知识图谱 API

### 2.1 生成课程知识图谱

**接口描述**：为指定课程生成知识图谱（触发AI抽取任务，异步执行）

**请求方式**：`POST`

**请求路径**：`/system/graph/extract/course/{courseId}`

**路径参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| courseId | Long | 是 | 课程ID |

**响应示例**：
```json
{
  "code": 200,
  "msg": "已提交知识图谱生成任务"
}
```

**前端调用**：
```javascript
import { extractCourseGraph } from '@/api/system/graph'
extractCourseGraph(33).then(response => {
  this.$message.success(response.msg)
})
```

---

### 2.2 生成章节知识图谱

**接口描述**：为指定章节生成知识图谱（从视频转录文本抽取知识点和关系，异步执行）

**请求方式**：`POST`

**请求路径**：`/system/graph/extract/chapter/{courseId}/{chapterId}`

**路径参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| courseId | Long | 是 | 课程ID |
| chapterId | Long | 是 | 章节ID |

**响应示例**：
```json
{
  "code": 200,
  "msg": "已提交章节知识图谱生成任务"
}
```

**前端调用**：
```javascript
import { extractChapterGraph } from '@/api/system/graph'
extractChapterGraph(33, 1).then(response => {
  this.$message.success(response.msg)
})
```

---

### 2.3 查询知识图谱列表

**接口描述**：查询已生成的知识图谱列表

**请求方式**：`GET`

**请求路径**：`/system/graph/list`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| courseId | Long | 否 | 课程ID |
| graphType | String | 否 | 图谱类型：COURSE/CHAPTER |
| status | String | 否 | 状态：active/archived |

**响应示例**：
```json
{
  "code": 200,
  "msg": "查询成功",
  "total": 2,
  "rows": [
    {
      "id": 1,
      "title": "高等数学-课程总图谱",
      "courseId": 33,
      "graphType": "COURSE",
      "graphData": "{\"nodes\":[...],\"edges\":[...]}",
      "status": "active",
      "createTime": "2025-11-27 10:00:00"
    }
  ]
}
```

**前端调用**：
```javascript
import { listGraph } from '@/api/system/graph'
listGraph({ courseId: 33, graphType: 'COURSE' }).then(response => {
  console.log(response.rows)
})
```

---



### 2.4 查询知识图谱详情

**接口描述**：获取指定知识图谱的详细信息（包含完整的节点和边数据）

**请求方式**：`GET`

**请求路径**：`/system/graph/{id}`

**路径参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 知识图谱ID |

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "id": 1,
    "title": "高等数学-第一章知识图谱",
    "courseId": 33,
    "graphType": "CHAPTER",
    "graphData": {
      "chapterId": 1,
      "chapterSortOrder": 1,
      "chapterTitle": "函数与极限",
      "nodes": [
        {
          "kpId": 123,
          "label": "函数的定义",
          "definition": "函数是两个非空数集之间的一种对应关系",
          "confidence": 0.95,
          "level": 1
        }
      ],
      "edges": [
        {
          "fromKpId": 123,
          "toKpId": 124,
          "relationType": "PREREQUISITE",
          "confidence": 0.9
        }
      ]
    },
    "status": "active",
    "createTime": "2025-11-27 10:00:00"
  }
}
```

**前端调用**：
```javascript
import { getGraph } from '@/api/system/graph'
getGraph(1).then(response => {
  console.log(response.data)
})
```

---

## 三、AI驱动的个性化推荐 API

### 3.1 获取AI个性化推荐结果

**接口描述**：综合分析学生的成绩数据、任务完成数据、视频/资源行为数据，通过LLM生成个性化学习建议

**请求方式**：`GET`

**请求路径**：`/system/ai/recommend/getResult`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| studentUserId | Long | 是 | 学生ID（user表id） |
| courseId | Long | 是 | 课程ID |

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "recommendContent": "根据您的学习情况，建议您：\n1. 重点复习函数的定义和性质\n2. 完成第一章的练习题\n3. 观看极限的概念视频",
    "avatarStatus": "completed",
    "recommendItemList": [
      {
        "id": 1,
        "recommendType": "video",
        "targetId": 10,
        "targetTitle": "极限的概念",
        "relatedKpIds": "123,124",
        "relatedKpNames": "函数的定义,函数的性质",
        "recommendReason": "您在函数定义知识点上的正确率为60%，建议观看此视频巩固基础",
        "status": "pending",
        "wrongQuestionNos": null
      },
      {
        "id": 2,
        "recommendType": "exercise",
        "targetId": 1,
        "targetTitle": "第一章作业",
        "relatedKpIds": "123",
        "relatedKpNames": "函数的定义",
        "recommendReason": "您在第1题答错，建议重做",
        "status": "pending",
        "wrongQuestionNos": "1,3,5"
      }
    ]
  }
}
```

**前端调用**：
```javascript
import { getPersonalizedRecommend } from '@/api/learning/recommend'
getPersonalizedRecommend({ studentUserId: 1, courseId: 33 }).then(response => {
  console.log(response.data)
})
```

---

### 3.2 获取大模型输入数据（调试用）

**接口描述**：获取传递给大模型的完整Prompt（用于调试和优化）

**请求方式**：`GET`

**请求路径**：`/system/ai/recommend/getModelInput`

**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| studentUserId | Long | 是 | 学生ID（user表id） |
| courseId | Long | 是 | 课程ID |

**响应示例**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": "你是一位资深的教育专家...\n\n学生学习数据：\n- 薄弱知识点：函数的定义(正确率60%)\n- 视频学习完成率：75%\n..."
}
```

**前端调用**：
```javascript
import { getModelInput } from '@/api/learning/recommend'
getModelInput({ studentUserId: 1, courseId: 33 }).then(response => {
  console.log(response.data)
})
```

---

## 四、关键数据结构说明

### 4.1 能力雷达图数据结构（CompetencyRadarVo）

```java
{
  "competencyName": "计算能力",  // 能力点名称
  "score": 75.5                 // 加权分数（0-100）
}
```

**计算逻辑**：
1. 从`course_competency`表获取课程的能力点定义
2. 从`competency_kp_relation`表获取能力点与知识点的映射关系
3. 从`student_kp_mastery`表获取学生对各知识点的掌握分数
4. 按权重计算每个能力点的综合得分

---

### 4.2 数字分身数据结构（DigitalTwinResultVO）

```java
{
  "twinType": "稳步积累型",      // 分身类型
  "score": 15,                   // 匹配分数（0-25）
  "features": [                  // 特征说明
    "视频学习完成率70%",
    "练习正确率85%"
  ],
  "scoreDetails": [              // 各分身得分明细
    {
      "twinType": "稳步积累型",
      "score": 15,
      "ruleMatches": [
        "视频学习完成率≥70%：符合 (当前75.05%, +5分)"
      ]
    }
  ]
}
```

**4种分身类型**：
1. **稳步积累型**：视频学习完成率高、练习正确率高、学习时间分布均匀
2. **逻辑攻坚型**：难题正确率高、逻辑推理能力强、深度学习时间长
3. **高效突击型**：短时间内学习效率高、快速完成任务、播放速度快
4. **查漏补缺型**：薄弱知识点多、推荐完成率高、错题重做率高

---

### 4.3 知识点掌握情况数据结构（StudentKpMastery）

```java
{
  "id": 1,
  "studentUserId": 1,           // 学生ID
  "courseId": 33,               // 课程ID
  "kpId": 123,                  // 知识点ID
  "correctCount": 8,            // 答对次数
  "totalCount": 10,             // 总答题次数
  "accuracy": "80.00",          // 正确率（百分比）
  "lastTestScore": 85,          // 最近一次测试得分
  "lastTestTime": "2025-11-27", // 最近测试时间
  "trend": "up",                // 趋势：up/stable/down
  "masteryScore": 75,           // 掌握指标（0-100）
  "masteryStatus": "learning"   // 掌握状态：mastered/learning/weak/not_started
}
```

**掌握状态说明**：
- `mastered`（已掌握）：masteryScore ≥ 80
- `learning`（学习中）：60 ≤ masteryScore < 80
- `weak`（薄弱点）：masteryScore < 60
- `not_started`（未学习）：totalCount = 0

---

### 4.4 AI推荐项数据结构（PersonalizedRecommendItemVo）

```java
{
  "id": 1,
  "recommendType": "video",     // 推荐类型：video/exercise/resource/kp_review
  "targetId": 10,               // 目标资源ID
  "targetTitle": "极限的概念",  // 目标资源标题
  "relatedKpIds": "123,124",    // 关联知识点ID（逗号分隔）
  "relatedKpNames": "函数的定义,函数的性质", // 关联知识点名称
  "recommendReason": "您在函数定义知识点上的正确率为60%，建议观看此视频巩固基础",
  "status": "pending",          // 状态：pending/in_progress/completed/skipped
  "wrongQuestionNos": "1,3,5"   // 错题序号（仅exercise类型）
}
```

**推荐类型说明**：
- `video`：推荐观看视频
- `exercise`：推荐做练习题/作业
- `resource`：推荐学习资源（PDF、文档等）
- `kp_review`：推荐复习知识点

---

## 五、数据流程图

### 5.1 学习数据驾驶舱数据流

```
用户登录
  ↓
获取我的课程列表 (/system/student/my-courses)
  ↓
选择课程
  ↓
并行请求：
  ├─ 能力雷达图 (/learning/radar/getData)
  ├─ 数字分身 (/system/digitalTwin/calculate)
  ├─ 知识点掌握情况 (/learning/mastery/list)
  ├─ 视频学习行为 (/system/behavior/list)
  └─ 作业任务列表 (/system/assignment/list)
  ↓
Dashboard展示
```

---

### 5.2 知识图谱生成与展示流程

```
教师/管理员触发生成
  ↓
POST /system/graph/extract/course/{courseId}
或
POST /system/graph/extract/chapter/{courseId}/{chapterId}
  ↓
后端异步任务：
  ├─ 调用Whisper API转录视频
  ├─ 调用通义千问API抽取知识点
  ├─ 去重并保存到knowledge_point表
  ├─ 保存关系到kp_relation表
  └─ 生成graph_data JSON并保存到knowledge_graph表
  ↓
学生查询图谱列表 (GET /system/graph/list)
  ↓
获取图谱详情 (GET /system/graph/{id})
  ↓
前端ECharts渲染力导向图
  ↓
点击节点查看掌握情况 (GET /learning/mastery/list?kpId=xxx)
```

---

### 5.3 AI个性化推荐流程

```
学生进入课程详情页
  ↓
点击"学习分析"Tab
  ↓
GET /system/ai/recommend/getResult?studentUserId=1&courseId=33
  ↓
后端逻辑：
  ├─ 查询student_kp_mastery（薄弱知识点）
  ├─ 查询video_learning_behavior（视频学习行为）
  ├─ 查询student_answer（错题记录）
  ├─ 查询assignment（作业完成情况）
  ├─ 拼接Prompt
  ├─ 调用通义千问API生成推荐
  ├─ 解析推荐结果
  ├─ 保存到personalized_recommendation表
  └─ 返回推荐内容和推荐项列表
  ↓
前端展示：
  ├─ 推荐内容文本
  ├─ 推荐项卡片（视频/练习/资源）
  └─ 点击"开始学习"跳转到对应页面
```

---

## 六、权限说明

### 6.1 权限标识

| 权限标识 | 说明 |
|---------|------|
| `system:student:list` | 查询学生选课列表 |
| `learning:radar:query` | 查询能力雷达图 |
| `system:ai:recommend` | 获取AI推荐 |
| `system:graph:generate` | 生成知识图谱 |
| `system:graph:list` | 查询知识图谱列表 |
| `learning:mastery:list` | 查询知识点掌握情况 |
| `system:behavior:list` | 查询视频学习行为 |
| `system:assignment:list` | 查询作业列表 |

### 6.2 角色权限分配

**学生角色**：
- ✅ 查询自己的课程列表
- ✅ 查询自己的能力雷达图
- ✅ 查询自己的数字分身
- ✅ 查询自己的知识点掌握情况
- ✅ 查询自己的视频学习行为
- ✅ 查询自己的AI推荐
- ✅ 查看知识图谱
- ❌ 生成知识图谱

**教师/管理员角色**：
- ✅ 所有学生权限
- ✅ 生成知识图谱
- ✅ 查询所有学生的数据

---

## 七、错误码说明

| 错误码 | 说明 | 解决方案 |
|-------|------|---------|
| 200 | 操作成功 | - |
| 500 | 系统异常 | 查看后端日志 |
| 401 | 未登录或登录过期 | 重新登录 |
| 403 | 无权限访问 | 联系管理员分配权限 |
| 404 | 资源不存在 | 检查请求参数 |
| 400 | 参数错误 | 检查请求参数格式 |

**常见错误示例**：

```json
{
  "code": 500,
  "msg": "获取推荐结果失败：大模型无有效推荐结果"
}
```

```json
{
  "code": 403,
  "msg": "无权限访问"
}
```

---

## 八、调试建议

### 8.1 使用浏览器开发者工具

1. 打开浏览器开发者工具（F12）
2. 切换到"Network"标签
3. 筛选XHR请求
4. 查看请求URL、参数、响应数据

### 8.2 查看后端日志

```bash
# 查看实时日志
tail -f ruoyi-admin/logs/sys-info.log

# 搜索特定接口日志
grep "AI个性化推荐" ruoyi-admin/logs/sys-info.log
```

### 8.3 使用Postman测试

1. 导入接口集合
2. 设置环境变量：`baseUrl`, `token`
3. 发送请求并查看响应

---

## 九、性能优化建议

### 9.1 前端优化

1. **懒加载**：切换到Tab时才加载数据
2. **缓存**：将课程列表缓存到Vuex
3. **防抖**：搜索框输入时使用防抖
4. **分页**：大数据量时使用分页加载

### 9.2 后端优化

1. **数据库索引**：为常用查询字段添加索引
2. **缓存**：使用Redis缓存热点数据
3. **异步任务**：知识图谱生成使用异步任务
4. **批量查询**：减少数据库查询次数

---

## 十、附录

### 10.1 数据库表关系

```
user (学生表)
  ├─ course_student (选课关系)
  │    └─ course (课程表)
  │         ├─ chapter (章节表)
  │         ├─ assignment (作业表)
  │         ├─ course_competency (能力点表)
  │         └─ knowledge_point (知识点表)
  ├─ student_kp_mastery (知识点掌握情况)
  ├─ video_learning_behavior (视频学习行为)
  ├─ student_answer (学生答题记录)
  └─ personalized_recommendation (个性化推荐)
```

### 10.2 前端API文件位置

```
ruoyi-ui/src/api/
  ├─ system/
  │   ├─ student.js          # 学生选课API
  │   ├─ behavior.js         # 视频学习行为API
  │   ├─ assignment.js       # 作业API
  │   └─ graph.js            # 知识图谱API
  └─ learning/
      ├─ radar.js            # 能力雷达图API
      ├─ digitalTwin.js      # 数字分身API
      ├─ mastery.js          # 知识点掌握情况API
      └─ recommend.js        # AI推荐API
```

### 10.3 后端Controller文件位置

```
ruoyi-admin/src/main/java/com/ruoyi/web/controller/system/
  ├─ CourseStudentController.java          # 学生选课
  ├─ VideoLearningBehaviorController.java  # 视频学习行为
  ├─ AssignmentController.java             # 作业
  ├─ KnowledgeGraphController.java         # 知识图谱
  ├─ CompetencyRadarController.java        # 能力雷达图
  ├─ DigitalTwinController.java            # 数字分身
  ├─ StudentKpMasteryController.java       # 知识点掌握情况
  └─ AiRecommendController.java            # AI推荐
```

---

## 十一、集成示例

### 11.1 其他项目组如何调用这些API

**场景1：获取学生的学习数据用于分析**

```javascript
// 1. 获取学生的课程列表
const courses = await fetch('/system/student/my-courses', {
  headers: { 'Authorization': 'Bearer ' + token }
}).then(res => res.json())

// 2. 获取第一门课程的能力雷达图
const radarData = await fetch(`/learning/radar/getData?studentId=${studentId}&courseId=${courses.data[0].id}`, {
  headers: { 'Authorization': 'Bearer ' + token }
}).then(res => res.json())

// 3. 获取知识点掌握情况
const masteryData = await fetch(`/learning/mastery/list?studentUserId=${studentId}&courseId=${courses.data[0].id}`, {
  headers: { 'Authorization': 'Bearer ' + token }
}).then(res => res.json())
```

**场景2：生成知识图谱并获取数据**

```javascript
// 1. 触发生成章节知识图谱
await fetch(`/system/graph/extract/chapter/${courseId}/${chapterId}`, {
  method: 'POST',
  headers: { 'Authorization': 'Bearer ' + token }
})

// 2. 等待生成完成（轮询或WebSocket）
await sleep(30000) // 等待30秒

// 3. 查询知识图谱列表
const graphs = await fetch(`/system/graph/list?courseId=${courseId}&graphType=CHAPTER`, {
  headers: { 'Authorization': 'Bearer ' + token }
}).then(res => res.json())

// 4. 获取图谱详情
const graphDetail = await fetch(`/system/graph/${graphs.rows[0].id}`, {
  headers: { 'Authorization': 'Bearer ' + token }
}).then(res => res.json())

// 5. 解析graph_data并渲染
const graphData = JSON.parse(graphDetail.data.graphData)
console.log('节点数量:', graphData.nodes.length)
console.log('边数量:', graphData.edges.length)
```

**场景3：获取AI推荐并展示**

```javascript
// 1. 获取AI推荐结果
const recommend = await fetch(`/system/ai/recommend/getResult?studentUserId=${studentId}&courseId=${courseId}`, {
  headers: { 'Authorization': 'Bearer ' + token }
}).then(res => res.json())

// 2. 展示推荐内容
console.log('推荐内容:', recommend.data.recommendContent)

// 3. 遍历推荐项
recommend.data.recommendItemList.forEach(item => {
  console.log(`推荐类型: ${item.recommendType}`)
  console.log(`目标资源: ${item.targetTitle}`)
  console.log(`推荐理由: ${item.recommendReason}`)
})
```

---

### 11.2 数据同步建议

**如果其他项目组需要定期同步数据**：

1. **方式1：定时任务**
   - 每天凌晨调用API获取最新数据
   - 存储到本地数据库

2. **方式2：WebHook**
   - 在本系统中添加WebHook功能
   - 数据更新时主动推送到其他系统

3. **方式3：消息队列**
   - 使用RabbitMQ或Kafka
   - 数据变更时发送消息

---

## 十二、联系方式

**技术支持**：开发团队
**文档版本**：v1.0
**最后更新**：2025-11-27

---

## 十三、快速开始

### 13.1 获取Token

```bash
# 登录获取token
curl -X POST http://localhost:8080/login \
  -H "Content-Type: application/json" \
  -d '{"username":"student","password":"123456"}'

# 响应示例
{
  "code": 200,
  "msg": "操作成功",
  "token": "eyJhbGciOiJIUzUxMiJ9..."
}
```

### 13.2 调用API示例

```bash
# 获取我的课程列表
curl -X GET http://localhost:8080/system/student/my-courses \
  -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9..."

# 获取能力雷达图
curl -X GET "http://localhost:8080/learning/radar/getData?studentId=1&courseId=33" \
  -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9..."

# 获取AI推荐
curl -X GET "http://localhost:8080/system/ai/recommend/getResult?studentUserId=1&courseId=33" \
  -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9..."
```

---

## 十四、常见问题FAQ

### Q1: 如何判断知识图谱是否生成完成？

**A**: 调用 `/system/graph/list` 接口，查看返回的图谱列表中是否有对应的记录。如果有，说明生成完成。

### Q2: AI推荐接口超时怎么办？

**A**: AI推荐接口调用大模型，可能需要10-30秒。前端已设置timeout为30秒。如果仍然超时，可以：
1. 增加前端timeout时间
2. 后端改为异步任务，前端轮询结果

### Q3: 能力雷达图数据为空怎么办？

**A**: 检查以下几点：
1. `course_competency`表中是否有该课程的能力点定义
2. `competency_kp_relation`表中是否有能力点与知识点的映射
3. `student_kp_mastery`表中是否有学生的掌握数据

### Q4: 知识点掌握状态如何更新？

**A**: 学生每次答题后，系统会自动更新 `student_kp_mastery` 表中的数据，包括：
- `correctCount`（答对次数）
- `totalCount`（总答题次数）
- `accuracy`（正确率）
- `masteryScore`（掌握指标）
- `masteryStatus`（掌握状态）

### Q5: 如何自定义数字分身的规则？

**A**: 修改 `DigitalTwinServiceImpl.java` 中的规则定义，调整各分身类型的匹配条件和分数计算逻辑。

---

**文档结束**

