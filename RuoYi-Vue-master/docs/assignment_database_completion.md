# 作业考试数据库完善文档

## 📋 概述

本文档记录了对 smartclassv2 数据库中 assignment 相关表的完善工作。

## 🎯 目标

1. 为所有课程创建答题型作业/考试
2. 确保所有答题型作业都有题目数据（来自 assignment_question 表）
3. 确保每个作业的题目分数总和等于作业总分（100分）

## 📊 数据库表结构

### 1. assignment 表
存储作业/考试的基本信息：
- `id`: 作业编号
- `title`: 作业标题
- `course_id`: 所属课程
- `type`: 类型（homework/exam）
- `mode`: 模式（question-答题型 / file-上传型）
- `total_score`: 总分
- `duration`: 建议时长（分钟）
- 其他字段...

### 2. assignment_question 表
存储作业与题目的关联关系：
- `id`: 主键
- `assignment_id`: 作业编号
- `question_id`: 题目编号（来自 question 表）
- `score`: 该题在此作业中的分值
- `sequence`: 题目顺序
- `is_deleted`: 是否删除

### 3. question 表
存储题目数据：
- `id`: 题目编号
- `title`: 题干
- `question_type`: 题型（single/multiple/true_false等）
- `difficulty`: 难度（1-5）
- `correct_answer`: 正确答案
- `course_id`: 所属课程
- 其他字段...

### 4. question_option 表
存储题目选项：
- `id`: 主键
- `question_id`: 题目编号
- `option_label`: 选项标签（A/B/C/D）
- `option_text`: 选项内容

## ✅ 完成的工作

### 1. 创建新的答题型作业

为以下课程创建了答题型作业：

| 作业ID | 作业标题 | 课程 | 类型 | 题目数 | 总分 |
|--------|---------|------|------|--------|------|
| 2003 | JavaScript基础测试 | 前端开发基础 | exam | 10 | 100 |
| 3001 | 前端基础综合测试（简单） | 前端开发基础 | homework | 10 | 100 |
| 3002 | 前端进阶能力测试（中等） | 前端开发基础 | exam | 18 | 100 |
| 3003 | 前端高级综合考试（困难） | 前端开发基础 | exam | 25 | 100 |
| 3004 | Java基础知识测试 | JavaScript高级编程 | homework | 10 | 100 |
| 3005 | Java面向对象编程考试 | JavaScript高级编程 | exam | 15 | 100 |
| 3006 | SQL基础查询练习 | Vue.js框架开发 | homework | 8 | 100 |
| 3007 | 数据库设计与优化考试 | Vue.js框架开发 | exam | 12 | 100 |
| 3008 | 网络协议基础测试 | React框架实战 | homework | 10 | 100 |
| 3009 | 网络安全综合考试 | React框架实战 | exam | 14 | 100 |
| 3010 | 进程与线程基础练习 | 前端工程化实践 | homework | 8 | 100 |
| 3011 | 操作系统原理综合考试 | 前端工程化实践 | exam | 16 | 100 |
| 3012 | 线性表与链表练习 | Node.js后端开发 | homework | 10 | 100 |
| 3013 | 算法设计与分析考试 | Node.js后端开发 | exam | 20 | 100 |
| 3014 | 软件开发流程测试 | 移动端开发 | homework | 8 | 100 |
| 3015 | 软件设计模式考试 | 移动端开发 | exam | 13 | 100 |
| 3016 | 机器学习基础测试 | 前端性能优化 | homework | 10 | 100 |
| 3017 | 深度学习综合考试 | 前端性能优化 | exam | 17 | 100 |

### 2. 关联题目数据

- 为每个作业从 question 表中选择合适的题目
- 通过 assignment_question 表建立关联
- 设置每道题的分值和顺序

### 3. 调整分数

- 确保每个作业的题目分数总和 = 100分
- 根据题目数量和类型合理分配分值

## 📁 相关SQL文件

1. **complete_assignment_data.sql**
   - 创建新的答题型作业
   - 关联题目数据

2. **fix_assignment_scores.sql**
   - 修正作业分数
   - 确保总分为100分

## 🔍 验证查询

```sql
-- 查看所有答题型作业及其题目统计
SELECT
    a.id,
    a.title,
    c.title AS course,
    a.type,
    COUNT(aq.id) AS questions,
    a.total_score AS target,
    SUM(aq.score) AS actual
FROM assignment a
LEFT JOIN course c ON a.course_id = c.id
LEFT JOIN assignment_question aq ON a.id = aq.assignment_id AND aq.is_deleted = 0
WHERE a.mode = 'question' AND a.is_deleted = 0
GROUP BY a.id
ORDER BY a.id;
```

## 📝 注意事项

1. **题目复用**：目前多个作业使用了相同的题目（来自课程1的题目），这是临时方案。实际应该为每个课程创建专门的题目。

2. **题目来源**：所有题目都来自 `question` 表，通过 `assignment_question` 表关联到作业。

3. **分数设置**：每道题的分值在 `assignment_question.score` 字段中设置，可以根据题目难度和类型灵活调整。

4. **题目顺序**：通过 `assignment_question.sequence` 字段控制题目在作业中的显示顺序。

## 🚀 后续建议

1. **创建专门题目**：为每个课程创建专门的题目，避免题目复用
2. **丰富题型**：增加填空题、简答题、编程题等题型
3. **难度分级**：根据作业类型（homework/exam）和难度设置合适的题目
4. **题目标签**：为题目添加知识点标签，方便按知识点筛选
5. **题目解析**：完善题目的答案解析，帮助学生理解

## ✅ 完成状态

- [x] 创建答题型作业
- [x] 关联题目数据
- [x] 调整分数确保总分为100
- [x] 验证数据完整性
- [ ] 为每个课程创建专门题目（待完成）
- [ ] 丰富题型和难度（待完成）

