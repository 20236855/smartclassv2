#!/usr/bin/env python3
"""
测试Whisper转录功能

用法：
python test_transcribe.py <视频文件路径>
"""

import sys
import requests
import os

def test_transcribe(video_path):
    """测试转录功能"""
    
    print(f"测试转录: {video_path}\n")
    print("=" * 60)
    
    # 1. 检查文件
    if not os.path.exists(video_path):
        print(f"❌ 错误：文件不存在")
        return False
    
    file_size = os.path.getsize(video_path)
    print(f"✅ 文件存在")
    print(f"   文件大小: {file_size:,} 字节 ({file_size / 1024 / 1024:.2f} MB)")
    print()
    
    # 2. 检查Whisper服务
    print("检查Whisper服务...")
    try:
        response = requests.get('http://localhost:8002/health', timeout=5)
        if response.status_code == 200:
            print(f"✅ Whisper服务运行正常")
            data = response.json()
            print(f"   状态: {data.get('status')}")
            print(f"   已加载模型: {data.get('loaded_models', [])}")
        else:
            print(f"❌ Whisper服务异常: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print(f"❌ 无法连接到Whisper服务")
        print(f"   请确保Whisper服务正在运行: python whisper_server.py")
        return False
    except Exception as e:
        print(f"❌ 检查服务失败: {str(e)}")
        return False
    
    print()
    
    # 3. 发送转录请求
    print("发送转录请求...")
    print("⏳ 正在转录，请稍候...")
    
    try:
        with open(video_path, 'rb') as f:
            files = {'file': (os.path.basename(video_path), f, 'video/mp4')}
            data = {
                'language': 'zh',
                'model': 'tiny'
            }
            
            response = requests.post(
                'http://localhost:8002/transcribe',
                files=files,
                data=data,
                timeout=1800  # 30分钟超时（处理长视频）
            )
        
        print()
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                print("✅ 转录成功！")
                print()
                print("=" * 60)
                print("转录结果:")
                print("=" * 60)
                print(result.get('text', ''))
                print("=" * 60)
                print()
                print(f"📊 统计信息:")
                print(f"   文本长度: {len(result.get('text', ''))} 字符")
                print(f"   语言: {result.get('language', 'unknown')}")
                print(f"   片段数: {result.get('segments', 0)}")
                print(f"   时长: {result.get('duration', 0):.2f} 秒")
                return True
            else:
                print(f"❌ 转录失败: {result.get('error')}")
                if 'suggestion' in result:
                    print(f"   建议: {result.get('suggestion')}")
                if 'technical_details' in result:
                    print(f"   技术细节: {result.get('technical_details')}")
                return False
        else:
            print(f"❌ 请求失败: HTTP {response.status_code}")
            try:
                error_data = response.json()
                print(f"   错误: {error_data.get('error')}")
            except:
                print(f"   响应: {response.text[:200]}")
            return False
            
    except requests.exceptions.Timeout:
        print(f"❌ 转录超时（超过30分钟）")
        print(f"   视频可能太长，建议分段处理或使用更快的硬件")
        return False
    except Exception as e:
        print(f"❌ 转录失败: {str(e)}")
        return False

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("用法: python test_transcribe.py <视频文件路径>")
        print()
        print("示例:")
        print("  python test_transcribe.py C:/ruoyi/uploadPath/upload/2025/11/20/1_20251120193138A003.mp4")
        sys.exit(1)
    
    video_path = sys.argv[1]
    success = test_transcribe(video_path)
    
    sys.exit(0 if success else 1)

