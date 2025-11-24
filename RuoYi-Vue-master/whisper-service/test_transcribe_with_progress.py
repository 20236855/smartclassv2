#!/usr/bin/env python3
"""
测试Whisper转录功能（带进度显示）

用法：
python test_transcribe_with_progress.py <视频文件路径>
"""

import sys
import requests
import os
import time
import threading

def show_progress(stop_event, video_duration):
    """显示转录进度"""
    start_time = time.time()
    
    # 估算转录时间（tiny模型：约6秒/分钟视频）
    estimated_seconds = (video_duration / 60) * 6
    
    while not stop_event.is_set():
        elapsed = time.time() - start_time
        
        if estimated_seconds > 0:
            progress = min(95, (elapsed / estimated_seconds) * 100)
            bar_length = 40
            filled = int(bar_length * progress / 100)
            bar = '█' * filled + '░' * (bar_length - filled)
            
            print(f'\r⏳ 转录中... [{bar}] {progress:.1f}% ({int(elapsed)}秒/{int(estimated_seconds)}秒)', end='', flush=True)
        else:
            print(f'\r⏳ 转录中... {int(elapsed)}秒', end='', flush=True)
        
        time.sleep(0.5)
    
    print()  # 换行

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
    
    # 获取视频时长
    try:
        import subprocess
        import json
        cmd = ['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_format', video_path]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        data = json.loads(result.stdout)
        video_duration = float(data.get('format', {}).get('duration', 0))
        print(f"   视频时长: {video_duration:.1f} 秒 ({video_duration / 60:.1f} 分钟)")
    except:
        video_duration = 0
    
    print()
    
    # 2. 检查Whisper服务
    print("检查Whisper服务...")
    try:
        response = requests.get('http://localhost:5000/health', timeout=5)
        if response.status_code == 200:
            print(f"✅ Whisper服务运行正常")
            data = response.json()
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
    
    # 3. 发送转录请求（带进度显示）
    print("发送转录请求...")
    
    # 启动进度显示线程
    stop_event = threading.Event()
    progress_thread = threading.Thread(target=show_progress, args=(stop_event, video_duration))
    progress_thread.start()
    
    try:
        with open(video_path, 'rb') as f:
            files = {'file': (os.path.basename(video_path), f, 'video/mp4')}
            data = {
                'language': 'zh',
                'model': 'tiny'
            }
            
            response = requests.post(
                'http://localhost:5000/transcribe',
                files=files,
                data=data,
                timeout=1800  # 30分钟超时
            )
        
        # 停止进度显示
        stop_event.set()
        progress_thread.join()
        
        if response.status_code == 200:
            result = response.json()
            
            if result.get('success'):
                print("✅ 转录成功！")
                print()
                print("=" * 60)
                print("转录结果:")
                print("=" * 60)
                text = result.get('text', '')
                # 只显示前500字符
                if len(text) > 500:
                    print(text[:500] + "...")
                    print(f"\n... (共 {len(text)} 字符，仅显示前500字符)")
                else:
                    print(text)
                print("=" * 60)
                print()
                print(f"📊 统计信息:")
                print(f"   文本长度: {len(text)} 字符")
                print(f"   语言: {result.get('language', 'unknown')}")
                print(f"   片段数: {result.get('segments', 0)}")
                print(f"   时长: {result.get('duration', 0):.2f} 秒")
                return True
            else:
                print(f"❌ 转录失败: {result.get('error')}")
                return False
        else:
            print(f"❌ 请求失败: HTTP {response.status_code}")
            return False
            
    except requests.exceptions.Timeout:
        stop_event.set()
        progress_thread.join()
        print(f"❌ 转录超时（超过30分钟）")
        return False
    except Exception as e:
        stop_event.set()
        progress_thread.join()
        print(f"❌ 转录失败: {str(e)}")
        return False

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("用法: python test_transcribe_with_progress.py <视频文件路径>")
        sys.exit(1)
    
    video_path = sys.argv[1]
    success = test_transcribe(video_path)
    
    sys.exit(0 if success else 1)

