#!/bin/bash

echo "========================================"
echo "Whisper 语音识别服务启动脚本"
echo "========================================"
echo ""

# 检查Python是否安装
if ! command -v python3 &> /dev/null; then
    echo "❌ [错误] 未检测到Python3，请先安装Python 3.8+"
    echo "   Ubuntu/Debian: sudo apt install python3 python3-pip"
    echo "   Mac: brew install python3"
    exit 1
fi

echo "[1/4] 检查Python环境..."
python3 --version

echo ""
echo "[2/4] 检查依赖包..."
if ! python3 -c "import whisper" &> /dev/null; then
    echo "[提示] 未安装openai-whisper，正在安装..."
    pip3 install openai-whisper flask flask-cors
else
    echo "[OK] 依赖包已安装"
fi

echo ""
echo "[3/4] 检查ffmpeg..."
if ! command -v ffmpeg &> /dev/null; then
    echo "⚠️  [警告] 未检测到ffmpeg，某些视频格式可能无法处理"
    echo "   Ubuntu/Debian: sudo apt install ffmpeg"
    echo "   Mac: brew install ffmpeg"
    echo ""
    read -p "是否继续启动服务？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "[OK] ffmpeg已安装"
fi

echo ""
echo "[4/4] 启动Whisper服务..."
echo "服务地址: http://localhost:5000"
echo "健康检查: http://localhost:5000/health"
echo ""
echo "按 Ctrl+C 停止服务"
echo "========================================"
echo ""

python3 whisper_server.py

