#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Whisper 语音识别服务
提供HTTP API接口，供Java后端调用

安装依赖：
pip install openai-whisper flask flask-cors

运行：
python whisper_server.py

API接口：
POST /transcribe
参数：
  - file: 视频/音频文件
  - language: 语言代码（可选，如 zh, en）
  - model: 模型大小（可选，默认 base）

返回：
{
  "success": true,
  "text": "识别的文本内容",
  "language": "zh",
  "duration": 123.45
}
"""

import os
import whisper
import tempfile
import subprocess
from flask import Flask, request, jsonify
from flask_cors import CORS
import logging

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # 允许跨域

# 全局变量：缓存已加载的模型
loaded_models = {}

def check_audio_stream(video_path):
    """
    检查视频文件是否包含音频流

    返回：(has_audio, duration, error_message)
    """
    try:
        # 使用ffprobe检查音频流
        cmd = [
            'ffprobe',
            '-v', 'error',
            '-select_streams', 'a:0',
            '-show_entries', 'stream=codec_type,duration',
            '-of', 'default=noprint_wrappers=1:nokey=1',
            video_path
        ]

        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)

        if result.returncode != 0:
            return False, 0, "无法读取视频文件信息"

        output = result.stdout.strip()

        if not output or 'audio' not in output:
            return False, 0, "视频文件不包含音频轨道"

        # 尝试获取时长
        lines = output.split('\n')
        duration = 0
        for line in lines:
            try:
                duration = float(line)
                break
            except ValueError:
                continue

        if duration == 0:
            return False, 0, "音频轨道时长为0"

        return True, duration, None

    except subprocess.TimeoutExpired:
        return False, 0, "检查音频流超时"
    except FileNotFoundError:
        return False, 0, "ffprobe未找到，请确保ffmpeg已安装"
    except Exception as e:
        return False, 0, f"检查音频流失败: {str(e)}"

def preprocess_audio(video_path):
    """
    预处理音频：提取并转换为Whisper友好的格式

    返回：(success, processed_path, error_message)
    """
    try:
        # 创建临时WAV文件
        output_path = tempfile.NamedTemporaryFile(delete=False, suffix='.wav').name

        # 使用ffmpeg提取音频并转换为16kHz单声道WAV
        cmd = [
            'ffmpeg',
            '-i', video_path,
            '-vn',  # 不处理视频
            '-acodec', 'pcm_s16le',  # PCM 16位
            '-ar', '16000',  # 16kHz采样率
            '-ac', '1',  # 单声道
            '-y',  # 覆盖输出文件
            output_path
        ]

        logger.info(f"预处理音频: {video_path} -> {output_path}")

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=600,  # 10分钟超时（处理长视频）
            creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
        )

        if result.returncode != 0:
            logger.warning(f"音频预处理失败: {result.stderr}")
            return False, None, f"音频预处理失败: {result.stderr}"

        # 检查输出文件
        if not os.path.exists(output_path) or os.path.getsize(output_path) == 0:
            return False, None, "预处理后的音频文件为空"

        logger.info(f"音频预处理成功: {os.path.getsize(output_path)} 字节")
        return True, output_path, None

    except subprocess.TimeoutExpired:
        return False, None, "音频预处理超时"
    except Exception as e:
        return False, None, f"音频预处理异常: {str(e)}"

def get_model(model_name="tiny"):
    """
    获取Whisper模型（带缓存）

    模型大小：
    - tiny: 最快，准确率85%（~1GB内存）← 当前默认
    - base: 平衡，准确率95%（~1GB内存）
    - small: 较好，准确率97%（~2GB内存）
    - medium: 很好，准确率98%（~5GB内存）
    - large: 最好，最慢，准确率99%（~10GB内存）
    """
    if model_name not in loaded_models:
        logger.info(f"正在加载Whisper模型: {model_name}")
        loaded_models[model_name] = whisper.load_model(model_name)
        logger.info(f"模型加载完成: {model_name}")
    return loaded_models[model_name]

@app.route('/health', methods=['GET'])
def health():
    """健康检查接口"""
    return jsonify({
        "status": "ok",
        "service": "whisper-transcription",
        "loaded_models": list(loaded_models.keys())
    })

@app.route('/transcribe', methods=['POST'])
def transcribe():
    """
    语音识别接口
    """
    try:
        # 检查是否有文件
        if 'file' not in request.files:
            return jsonify({
                "success": False,
                "error": "没有上传文件"
            }), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({
                "success": False,
                "error": "文件名为空"
            }), 400
        
        # 获取参数
        language = request.form.get('language', None)  # 如 'zh', 'en'
        model_name = request.form.get('model', 'tiny')  # 模型大小，默认tiny（最快）
        
        logger.info(f"收到转录请求: file={file.filename}, language={language}, model={model_name}")
        
        # 保存临时文件
        with tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(file.filename)[1]) as tmp_file:
            file.save(tmp_file.name)
            tmp_path = tmp_file.name

        try:
            # 检查音频流
            logger.info(f"检查音频流: {tmp_path}")
            has_audio, duration, error_msg = check_audio_stream(tmp_path)

            if not has_audio:
                logger.warning(f"音频检查失败: {error_msg}")
                return jsonify({
                    "success": False,
                    "error": error_msg,
                    "suggestion": "请确保视频文件包含音频轨道"
                }), 400

            logger.info(f"音频检查通过，时长: {duration:.2f}秒")

            # 预处理音频（提取并转换为标准格式）
            logger.info(f"预处理音频...")
            success, processed_path, error_msg = preprocess_audio(tmp_path)

            if not success:
                logger.warning(f"音频预处理失败，尝试直接转录: {error_msg}")
                # 预处理失败，尝试直接使用原文件
                audio_path = tmp_path
                processed_path = None
            else:
                logger.info(f"音频预处理成功")
                audio_path = processed_path

            # 加载模型
            model = get_model(model_name)

            # 执行转录
            logger.info(f"开始转录: {audio_path}")

            # 使用更宽松的参数来提高兼容性
            result = model.transcribe(
                audio_path,
                language=language,
                verbose=False,
                fp16=False,  # 在CPU上禁用FP16
                condition_on_previous_text=False,  # 减少依赖
                initial_prompt=None,  # 不使用初始提示
                temperature=0.0,  # 使用贪婪解码
                compression_ratio_threshold=2.4,  # 默认值
                logprob_threshold=-1.0,  # 默认值
                no_speech_threshold=0.6  # 默认值
            )
            
            logger.info(f"转录完成，文本长度: {len(result['text'])}")
            
            # 返回结果
            return jsonify({
                "success": True,
                "text": result['text'],
                "language": result.get('language', language),
                "segments": len(result.get('segments', [])),
                "duration": sum(seg['end'] - seg['start'] for seg in result.get('segments', []))
            })
            
        except RuntimeError as e:
            # 捕获Whisper的reshape错误（通常是音频为空）
            error_msg = str(e)
            if "reshape tensor of 0 elements" in error_msg or "cannot reshape" in error_msg:
                logger.error(f"音频数据为空或无效: {error_msg}")
                return jsonify({
                    "success": False,
                    "error": "视频文件音频数据为空或无效",
                    "suggestion": "请检查视频是否包含有效的音频内容",
                    "technical_details": error_msg
                }), 400
            else:
                raise  # 重新抛出其他RuntimeError

        finally:
            # 删除临时文件
            if os.path.exists(tmp_path):
                os.remove(tmp_path)
            # 删除预处理的音频文件
            if 'processed_path' in locals() and processed_path and os.path.exists(processed_path):
                os.remove(processed_path)

    except Exception as e:
        logger.error(f"转录失败: {str(e)}", exc_info=True)
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@app.route('/models', methods=['GET'])
def list_models():
    """列出可用的模型"""
    return jsonify({
        "available_models": ["tiny", "base", "small", "medium", "large"],
        "loaded_models": list(loaded_models.keys()),
        "recommended": "base"
    })

if __name__ == '__main__':
    # 预加载默认模型（可选）
    logger.info("预加载tiny模型（最快速度）...")
    get_model("tiny")

    # 启动服务
    logger.info("启动Whisper服务...")
    app.run(
        host='0.0.0.0',  # 允许外部访问
        port=5000,       # 端口
        debug=False,     # 生产环境设为False
        threaded=True    # 支持多线程
    )

