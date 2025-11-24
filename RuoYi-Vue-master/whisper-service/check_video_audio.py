#!/usr/bin/env python3
"""
检查视频文件的音频信息

用法：
python check_video_audio.py <视频文件路径>
"""

import sys
import subprocess
import json

def check_video_info(video_path):
    """检查视频文件的详细信息"""
    
    print(f"正在检查视频文件: {video_path}\n")
    print("=" * 60)
    
    # 1. 检查文件是否存在
    import os
    if not os.path.exists(video_path):
        print(f"❌ 错误：文件不存在")
        return False
    
    file_size = os.path.getsize(video_path)
    print(f"✅ 文件存在")
    print(f"   文件大小: {file_size:,} 字节 ({file_size / 1024 / 1024:.2f} MB)")
    print()
    
    # 2. 使用ffprobe获取详细信息
    try:
        cmd = [
            'ffprobe',
            '-v', 'quiet',
            '-print_format', 'json',
            '-show_format',
            '-show_streams',
            video_path
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        
        if result.returncode != 0:
            print(f"❌ 错误：无法读取视频信息")
            print(f"   错误信息: {result.stderr}")
            return False
        
        data = json.loads(result.stdout)
        
        # 3. 分析流信息
        streams = data.get('streams', [])
        format_info = data.get('format', {})
        
        print(f"📊 格式信息:")
        print(f"   格式: {format_info.get('format_name', 'unknown')}")
        print(f"   时长: {float(format_info.get('duration', 0)):.2f} 秒")
        print(f"   比特率: {int(format_info.get('bit_rate', 0)) / 1000:.0f} kbps")
        print()
        
        # 4. 检查视频流
        video_streams = [s for s in streams if s.get('codec_type') == 'video']
        print(f"🎬 视频流: {len(video_streams)} 个")
        for i, stream in enumerate(video_streams):
            print(f"   流 {i+1}:")
            print(f"      编码: {stream.get('codec_name', 'unknown')}")
            print(f"      分辨率: {stream.get('width', 0)}x{stream.get('height', 0)}")
            print(f"      帧率: {stream.get('r_frame_rate', 'unknown')}")
        print()
        
        # 5. 检查音频流（重点）
        audio_streams = [s for s in streams if s.get('codec_type') == 'audio']
        print(f"🔊 音频流: {len(audio_streams)} 个")
        
        if len(audio_streams) == 0:
            print(f"   ❌ 警告：视频文件不包含音频轨道！")
            print(f"   这就是Whisper转录失败的原因。")
            print()
            print(f"💡 解决方案:")
            print(f"   1. 重新上传包含音频的视频文件")
            print(f"   2. 或者使用视频编辑软件添加音频轨道")
            print(f"   3. 或者在系统中禁用视频转录功能")
            return False
        
        for i, stream in enumerate(audio_streams):
            print(f"   流 {i+1}:")
            print(f"      编码: {stream.get('codec_name', 'unknown')}")
            print(f"      采样率: {stream.get('sample_rate', 'unknown')} Hz")
            print(f"      声道: {stream.get('channels', 'unknown')}")
            print(f"      比特率: {int(stream.get('bit_rate', 0)) / 1000:.0f} kbps")
            
            # 检查时长
            duration = stream.get('duration')
            if duration:
                duration_float = float(duration)
                print(f"      时长: {duration_float:.2f} 秒")
                if duration_float == 0:
                    print(f"      ⚠️  警告：音频时长为0！")
        
        print()
        print("=" * 60)
        print("✅ 视频文件包含音频，应该可以正常转录")
        return True
        
    except subprocess.TimeoutExpired:
        print(f"❌ 错误：检查超时")
        return False
    except FileNotFoundError:
        print(f"❌ 错误：ffprobe未找到")
        print(f"   请确保已安装ffmpeg并添加到PATH环境变量")
        return False
    except json.JSONDecodeError as e:
        print(f"❌ 错误：解析ffprobe输出失败")
        print(f"   {str(e)}")
        return False
    except Exception as e:
        print(f"❌ 错误：{str(e)}")
        return False

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("用法: python check_video_audio.py <视频文件路径>")
        print()
        print("示例:")
        print("  python check_video_audio.py C:/ruoyi/uploadPath/upload/2025/11/20/1_20251120193138A003.mp4")
        sys.exit(1)
    
    video_path = sys.argv[1]
    success = check_video_info(video_path)
    
    sys.exit(0 if success else 1)

