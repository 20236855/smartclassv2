#!/bin/bash

echo "========================================"
echo "  测试数据导入工具"
echo "========================================"
echo ""

# 设置MySQL连接信息
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_USER="root"
MYSQL_DB="ry-vue"

# 读取密码
echo -n "请输入MySQL密码: "
read -s MYSQL_PASSWORD
echo ""

echo ""
echo "正在导入测试数据..."
echo ""

# 执行SQL脚本
mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DB} < test_data.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "  ✓ 测试数据导入成功！"
    echo "========================================"
    echo ""
    echo "已导入："
    echo "  - 20道题目 (ID: 1001-1020)"
    echo "  - 10个作业 (ID: 2001-2010)"
    echo ""
    echo "现在可以启动系统进行测试了！"
    echo ""
else
    echo ""
    echo "========================================"
    echo "  ✗ 导入失败，请检查："
    echo "========================================"
    echo "  1. MySQL服务是否启动"
    echo "  2. 数据库名称是否正确"
    echo "  3. 用户名和密码是否正确"
    echo "  4. 表结构是否已创建"
    echo ""
fi

