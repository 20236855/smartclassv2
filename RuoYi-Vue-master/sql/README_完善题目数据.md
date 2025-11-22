# 题目数据完善说明

## 📊 数据概览

本次完善了以下三个表的数据：

### 1. question_stats（题目统计表）

**表结构**：
- `question_id` - 题目ID（主键）
- `answer_count` - 答题次数
- `correct_count` - 正确次数
- `accuracy` - 正确率（百分比）

**数据统计**：
- ✅ 已为所有 **50 道题目** 添加统计数据
- 📈 总答题次数：**7,687 次**
- 🎯 平均正确率：**80.84%**

**按题型统计**：

| 题型 | 题目数量 | 平均正确率 | 总答题次数 |
|------|---------|-----------|-----------|
| 单选题 (single) | 20 | 87.76% | 3,766 |
| 多选题 (multiple) | 5 | 71.54% | 740 |
| 判断题 (true_false) | 5 | 91.47% | 1,068 |
| 简答题 (short) | 20 | 72.60% | 2,113 |

**数据特点**：
- 📊 模拟真实的答题统计数据
- 🎯 难度越高的题目，正确率越低
- 📈 基础题目（如HTML、CSS基础）正确率较高（90%+）
- 🔥 高级题目（如架构设计、性能优化）正确率较低（50-70%）

---

### 2. question_option（题目选项表）

**表结构**：
- `id` - 选项ID（自增主键）
- `question_id` - 题目ID
- `option_label` - 选项标签（A/B/C/D）
- `option_text` - 选项内容

**数据统计**：
- ✅ 已有 **110 条选项数据**（之前已创建）
- 📝 覆盖所有选择题（单选、多选、判断）

**选项分布**：
- 单选题（3001-3020）：80 个选项（每题 4 个）
- 多选题（3021-3025）：20 个选项（每题 4 个）
- 判断题（3026-3030）：10 个选项（每题 2 个：正确/错误）

---

### 3. question_image（题目配图表）

**表结构**：
- `id` - 配图ID（自增主键）
- `question_id` - 题目ID
- `image_url` - 图片URL
- `description` - 图片描述
- `sequence` - 显示顺序
- `upload_time` - 上传时间

**数据统计**：
- ✅ 已为 **19 道题目** 添加配图
- 🖼️ 主要为需要图示说明的题目添加

**配图分类**：

#### HTML相关（2张）
- 3003：HTML5语义化标签示意图
- 3004：HTML表格结构示例

#### CSS相关（3张）
- 1006：CSS盒模型详细说明
- 3007：CSS盒模型示意图
- 3022：CSS居中方法示例

#### JavaScript相关（3张）
- 1008：JavaScript闭包示例代码
- 1009：事件冒泡和捕获流程图
- 1011：JavaScript原型链示意图

#### Vue相关（3张）
- 1010：Vue数据双向绑定原理图
- 1015：Vue组件通信方式
- 3024：Vue生命周期钩子图

#### 前端架构相关（5张）
- 1016：前端路由模式对比
- 1017：虚拟DOM Diff算法流程
- 1018：Vuex状态管理流程图
- 1019：微前端架构示意图
- 1020：前端性能监控指标

#### HTTP相关（2张）
- 1012：HTTPS工作原理示意图
- 1013：RESTful API设计规范

#### 浏览器相关（1张）
- 1014：浏览器渲染流程图

---

## 🚀 使用说明

### 导入数据

```bash
# 方法1：使用source命令
mysql -uroot -p123456 smartclassv2 --default-character-set=utf8mb4 -e "source RuoYi-Vue-master/sql/complete_question_data.sql"

# 方法2：使用管道
Get-Content "RuoYi-Vue-master\sql\complete_question_data.sql" -Encoding UTF8 | mysql -uroot -p123456 smartclassv2
```

### 验证数据

```sql
-- 查看统计数据总数
SELECT COUNT(*) AS total_stats FROM question_stats;

-- 查看配图总数
SELECT COUNT(*) AS total_images FROM question_image;

-- 查看选项总数
SELECT COUNT(*) AS total_options FROM question_option;

-- 按题型统计
SELECT 
    q.question_type AS '题型',
    COUNT(*) AS '题目数量',
    COUNT(qs.question_id) AS '有统计数据',
    COUNT(qi.question_id) AS '有配图',
    AVG(qs.accuracy) AS '平均正确率',
    SUM(qs.answer_count) AS '总答题次数'
FROM question q
LEFT JOIN question_stats qs ON q.id = qs.question_id
LEFT JOIN question_image qi ON q.id = qi.question_id
GROUP BY q.question_type
ORDER BY q.question_type;
```

---

## 📝 注意事项

### 关于图片URL

⚠️ **重要**：`question_image` 表中的图片URL是占位符，格式为：
```
/upload/questions/xxx.png
```

**实际使用时需要**：
1. 准备真实的图片文件
2. 上传到服务器的 `/upload/questions/` 目录
3. 或者修改URL为实际的图片地址

**建议的图片规格**：
- 格式：PNG 或 JPG
- 尺寸：800x600 或 1200x800（保持16:9或4:3比例）
- 大小：< 500KB
- 内容：清晰的示意图、流程图或代码截图

---

## 🎯 应用场景

### 1. 题目统计展示

在题目列表页面显示：
- 📊 答题次数
- 🎯 正确率
- 🔥 热门题目（答题次数多）
- 💪 难题（正确率低）

### 2. 题目配图展示

在答题页面显示：
- 🖼️ 题目相关的示意图
- 📈 流程图、架构图
- 💻 代码示例截图

### 3. 数据分析

- 📊 统计各题型的难度分布
- 🎯 分析学生的薄弱知识点
- 📈 追踪学习进度和效果

---

## 📊 数据示例

### 正确率最高的10道题

```sql
SELECT 
    qs.question_id,
    LEFT(q.title, 40) as title,
    qs.answer_count,
    qs.correct_count,
    qs.accuracy
FROM question_stats qs
JOIN question q ON qs.question_id = q.id
ORDER BY qs.accuracy DESC
LIMIT 10;
```

### 答题次数最多的10道题

```sql
SELECT 
    qs.question_id,
    LEFT(q.title, 40) as title,
    qs.answer_count,
    qs.accuracy
FROM question_stats qs
JOIN question q ON qs.question_id = q.id
ORDER BY qs.answer_count DESC
LIMIT 10;
```

---

## ✅ 完成状态

- ✅ question_stats：50/50 题目已添加统计数据
- ✅ question_option：110 个选项已存在
- ✅ question_image：19 道题目已添加配图
- ✅ 数据已成功导入数据库
- ⚠️ 图片文件需要手动上传到服务器

---

**创建日期**：2025-11-20  
**数据版本**：v1.0  
**维护者**：AI Assistant

