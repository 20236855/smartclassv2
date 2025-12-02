#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Whisper服务测试脚本

用法：
python test_whisper.py <视频文件路径>

示例：
python test_whisper.py test.mp4
"""

import sys
import requests
import os

def test_whisper_service(video_path, service_url="http://localhost:8002"):
    """
    测试Whisper服务
    """
    print("=" * 60)
    print("Whisper 服务测试")
    print("=" * 60)
    
    # 1. 检查文件是否存在
    if not os.path.exists(video_path):
        print(f"❌ 错误：文件不存在 - {video_path}")
        return False
    
    file_size = os.path.getsize(video_path) / (1024 * 1024)  # MB
    print(f"📁 文件：{video_path}")
    print(f"📊 大小：{file_size:.2f} MB")
    print()
    
    # 2. 检查服务是否运行
    print("🔍 检查Whisper服务...")
    try:
        response = requests.get(f"{service_url}/health", timeout=5)
        if response.status_code == 200:
            print(f"✅ 服务正常运行：{service_url}")
            health_data = response.json()
            print(f"   已加载模型：{health_data.get('loaded_models', [])}")
        else:
            print(f"❌ 服务异常：HTTP {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 无法连接到服务：{e}")
        print(f"   请确保Whisper服务已启动：python whisper_server.py")
        return False
    
    print()
    
    # 3. 发送转录请求
    print("🎤 开始语音识别...")
    print("   （这可能需要几秒到几分钟，取决于视频长度）")
    
    try:
        with open(video_path, 'rb') as f:
            files = {'file': f}
            data = {
                'language': 'zh',  # 中文
                'model': 'base'    # 使用base模型
            }
            
            response = requests.post(
                f"{service_url}/transcribe",
                files=files,
                data=data,
                timeout=600  # 10分钟超时
            )
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                print()
                print("✅ 识别成功！")
                print("=" * 60)
                print("识别结果：")
                print("-" * 60)
                print(result.get('text', ''))
                print("-" * 60)
                print(f"语言：{result.get('language', 'unknown')}")
                print(f"片段数：{result.get('segments', 0)}")
                print(f"时长：{result.get('duration', 0):.2f} 秒")
                print("=" * 60)
                return True
            else:
                print(f"❌ 识别失败：{result.get('error', '未知错误')}")
                return False
        else:
            print(f"❌ 请求失败：HTTP {response.status_code}")
            print(f"   响应：{response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 发生错误：{e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("用法：python test_whisper.py <视频文件路径>")
        print()
        print("示例：")
        print("  python test_whisper.py test.mp4")
        print("  python test_whisper.py C:\\videos\\lecture.mp4")
        sys.exit(1)
    
    video_path = sys.argv[1]
    service_url = sys.argv[2] if len(sys.argv) > 2 else "http://localhost:8002"
    
    success = test_whisper_service(video_path, service_url)
    
    if success:
        print()
        print("🎉 测试通过！Whisper服务工作正常。")
        sys.exit(0)
    else:
        print()
        print("❌ 测试失败，请检查上述错误信息。")
        sys.exit(1)

if __name__ == '__main__':
    main()

