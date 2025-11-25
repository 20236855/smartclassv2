#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
置信度分级测试脚本

测试不同质量的视频转录结果，验证AI的置信度评估是否合理
"""

import requests
import json

def test_confidence_levels():
    """
    测试三种不同质量的输入，验证置信度分级
    """
    print("=" * 80)
    print("置信度分级测试")
    print("=" * 80)
    print()
    
    # 测试用例1：高质量内容（应该得到高置信度）
    test_case_1 = """
=== 题目 1 ===
【类型】视频内容
【视频标题】Java面向对象编程详解
【视频描述】详细讲解Java的面向对象编程概念
【视频内容】
大家好，今天我们来详细学习Java的面向对象编程。
首先，什么是类？类（Class）是对象的模板，它定义了对象的属性和方法。
比如，我们可以定义一个Student类，包含姓名、年龄等属性，以及学习、考试等方法。
那么什么是对象呢？对象（Object）是类的实例，是具体的实体。
比如，张三就是Student类的一个对象，他有具体的姓名"张三"，年龄18岁。
面向对象编程有三大特性：封装、继承、多态。
封装（Encapsulation）是指将数据和操作数据的方法封装在一起，隐藏内部实现细节。
继承（Inheritance）是指子类可以继承父类的属性和方法，实现代码复用。
多态（Polymorphism）是指同一个方法在不同对象中有不同的实现。
"""
    
    # 测试用例2：中等质量内容（应该得到中置信度）
    test_case_2 = """
=== 题目 1 ===
【类型】视频内容
【视频标题】牛顿运动定律
【视频描述】讲解牛顿三大运动定律
【视频内容】
今天讲牛顿运动定律...第一定律说的是...物体保持静止或匀速直线运动...
除非有外力作用...第二定律是...力等于质量乘以加速度...
第三定律...作用力和反作用力...大小相等方向相反...
"""
    
    # 测试用例3：低质量内容（应该得到低置信度）
    test_case_3 = """
=== 题目 1 ===
【类型】视频内容
【视频标题】Python编程入门
【视频描述】介绍Python基础知识
"""
    
    test_cases = [
        ("高质量内容（详细讲解）", test_case_1, "应该得到高置信度 (≥0.7)"),
        ("中等质量内容（简要说明）", test_case_2, "应该得到中置信度 (0.4-0.7)"),
        ("低质量内容（仅标题）", test_case_3, "应该得到低置信度 (<0.4)")
    ]
    
    for i, (name, content, expected) in enumerate(test_cases, 1):
        print(f"\n{'='*80}")
        print(f"测试用例 {i}：{name}")
        print(f"预期结果：{expected}")
        print(f"{'='*80}")
        print()
        
        # 这里仅展示测试内容，实际需要调用AI API
        print("输入内容：")
        print(content[:200] + "..." if len(content) > 200 else content)
        print()
        print("⚠️  注意：此脚本仅用于展示测试用例")
        print("   实际测试需要：")
        print("   1. 启动Java后端")
        print("   2. 上传视频并生成知识图谱")
        print("   3. 查看返回的知识点置信度")
        print()

def show_confidence_guide():
    """
    显示置信度评估指南
    """
    print("\n" + "=" * 80)
    print("置信度评估指南")
    print("=" * 80)
    print()
    
    print("★ 高置信度 (0.7-1.0)：")
    print("  ✅ 原文明确提到该知识点的定义、概念或详细解释")
    print("  ✅ 有充分的证据支持（如题目解析、视频详细讲解）")
    print("  ✅ 知识点表述清晰、准确、完整")
    print("  示例：\"类（Class）是对象的模板，它定义了对象的属性和方法\"")
    print()
    
    print("★ 中置信度 (0.4-0.7)：")
    print("  ⚠️  原文提到该知识点，但解释不够详细")
    print("  ⚠️  可以从上下文推断出该知识点，但不是直接表述")
    print("  ⚠️  视频语音识别可能有误，但大致意思清楚")
    print("  示例：\"第一定律说的是...物体保持静止或匀速直线运动\"")
    print()
    
    print("★ 低置信度 (0.0-0.4)：")
    print("  ❓ 仅从标题或简短描述推测的知识点")
    print("  ❓ 证据不足，主要靠推断")
    print("  ❓ 视频语音识别质量差，内容不确定")
    print("  示例：仅有\"Python编程入门\"标题")
    print()

def show_usage_guide():
    """
    显示使用指南
    """
    print("\n" + "=" * 80)
    print("如何验证置信度分级")
    print("=" * 80)
    print()
    
    print("方法1：通过系统测试")
    print("  1. 准备三个不同质量的视频：")
    print("     - 高质量：有详细讲解的教学视频")
    print("     - 中质量：简要说明的视频")
    print("     - 低质量：仅有标题的视频")
    print("  2. 上传到系统并生成知识图谱")
    print("  3. 查看返回的知识点，检查置信度是否合理")
    print()
    
    print("方法2：查看日志")
    print("  1. 启动Java后端，设置日志级别为DEBUG")
    print("  2. 生成知识图谱")
    print("  3. 查看日志中的AI返回结果")
    print("  4. 检查每个知识点的confidence字段")
    print()
    
    print("方法3：数据库查询")
    print("  1. 生成知识图谱后")
    print("  2. 查询knowledge_graph表")
    print("  3. 查看graph_data字段中的JSON数据")
    print("  4. 统计不同置信度区间的知识点数量")
    print()
    
    print("SQL示例：")
    print("  SELECT ")
    print("    id, title,")
    print("    JSON_EXTRACT(graph_data, '$.nodes') as nodes")
    print("  FROM knowledge_graph")
    print("  WHERE course_id = 33")
    print("  ORDER BY create_time DESC")
    print("  LIMIT 1;")
    print()

def main():
    print("\n")
    print("╔" + "=" * 78 + "╗")
    print("║" + " " * 20 + "置信度分级测试工具" + " " * 38 + "║")
    print("╚" + "=" * 78 + "╝")
    
    # 显示置信度评估指南
    show_confidence_guide()
    
    # 显示测试用例
    test_confidence_levels()
    
    # 显示使用指南
    show_usage_guide()
    
    print("\n" + "=" * 80)
    print("总结")
    print("=" * 80)
    print()
    print("✅ 已在AI提示词中加入置信度分级约束")
    print("✅ 高置信度 (≥0.7)：明确定义的知识点")
    print("✅ 中置信度 (0.4-0.7)：可推断的知识点")
    print("✅ 低置信度 (<0.4)：推测的知识点")
    print()
    print("📝 建议：")
    print("  1. 使用tiny模型快速处理视频（速度快，准确率85%）")
    print("  2. AI会根据证据充分程度自动评估置信度")
    print("  3. 前端可根据置信度用不同颜色展示知识点")
    print("  4. 生成知识图谱时可选择只使用高置信度知识点")
    print()
    print("🚀 现在可以开始测试了！")
    print()

if __name__ == '__main__':
    main()

