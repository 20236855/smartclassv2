package com.ruoyi.system.service.impl;

import com.ruoyi.common.config.RuoYiConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.*;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.io.File;
import java.util.*;

/**
 * 视频转录服务 - 将视频转换为文字
 *
 * 支持多种方式：
 * 1. Whisper（OpenAI开源，完全免费）- 推荐
 * 2. 阿里云语音识别（每月3小时免费）
 * 3. 腾讯云语音识别（每月10小时免费）
 * 4. 百度智能云（每月50小时免费）
 *
 * @author ruoyi
 */
@Service
public class VideoTranscriptionService {

    private static final Logger logger = LoggerFactory.getLogger(VideoTranscriptionService.class);

    @Autowired
    private RuoYiConfig ruoYiConfig;

    @Value("${video.transcription.provider:whisper}")
    private String provider; // whisper, aliyun, tencent, baidu, none

    @Value("${video.transcription.enabled:true}")
    private boolean enabled;

    // Whisper服务配置
    @Value("${whisper.service.url:http://localhost:5000}")
    private String whisperServiceUrl;

    @Value("${whisper.model:tiny}")
    private String whisperModel; // tiny, base, small, medium, large

    @Value("${whisper.timeout:1800000}")
    private int whisperTimeout; // 超时时间（毫秒），默认30分钟

    private final RestTemplate restTemplate;

    public VideoTranscriptionService() {
        // 创建自定义的RestTemplate，设置超时时间
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(10000); // 连接超时：10秒
        factory.setReadTimeout(1800000);  // 读取超时：30分钟（处理长视频）
        this.restTemplate = new RestTemplate(factory);
    }
    
    /**
     * 从视频中提取文本内容
     *
     * @param videoPath 视频文件路径（可以是相对路径或绝对路径）
     * @param videoTitle 视频标题
     * @param videoDescription 视频描述
     * @return 提取的文本内容
     */
    public String extractTextFromVideo(String videoPath, String videoTitle, String videoDescription) {
        logger.info("开始从视频提取文本：path={}, provider={}, enabled={}", videoPath, provider, enabled);

        // 如果未启用转录或未配置服务，使用标题和描述
        if (!enabled || "none".equals(provider) || provider == null || provider.isEmpty()) {
            logger.warn("视频转录未启用，仅使用标题和描述");
            return buildTextFromMetadata(videoTitle, videoDescription);
        }

        // 转换为绝对路径
        String absolutePath = getAbsolutePath(videoPath);
        logger.info("转换后的绝对路径：{}", absolutePath);

        // 检查文件是否存在
        File videoFile = new File(absolutePath);
        if (!videoFile.exists() || !videoFile.isFile()) {
            logger.warn("视频文件不存在：{}，降级使用标题和描述", absolutePath);
            return buildTextFromMetadata(videoTitle, videoDescription);
        }

        try {
            String transcribedText = null;

            switch (provider.toLowerCase()) {
                case "whisper":
                    transcribedText = extractUsingWhisper(absolutePath);
                    break;
                case "aliyun":
                    transcribedText = extractUsingAliyun(absolutePath, videoTitle, videoDescription);
                    break;
                case "tencent":
                    transcribedText = extractUsingTencent(absolutePath, videoTitle, videoDescription);
                    break;
                case "baidu":
                    transcribedText = extractUsingBaidu(absolutePath, videoTitle, videoDescription);
                    break;
                default:
                    logger.warn("未知的转录服务提供商：{}，使用标题和描述", provider);
                    return buildTextFromMetadata(videoTitle, videoDescription);
            }

            // 如果转录成功，合并转录文本和元数据
            if (transcribedText != null && !transcribedText.trim().isEmpty()) {
                return buildTextFromTranscription(videoTitle, videoDescription, transcribedText);
            } else {
                logger.warn("转录结果为空，降级使用标题和描述");
                return buildTextFromMetadata(videoTitle, videoDescription);
            }

        } catch (Exception e) {
            logger.error("视频转录失败，降级使用标题和描述：{}", e.getMessage(), e);
            return buildTextFromMetadata(videoTitle, videoDescription);
        }
    }

    /**
     * 使用Whisper进行语音识别（推荐，完全免费）
     */
    private String extractUsingWhisper(String videoPath) {
        logger.info("使用Whisper进行语音识别：{}", videoPath);

        try {
            // 检查Whisper服务是否可用
            String healthUrl = whisperServiceUrl + "/health";
            try {
                ResponseEntity<Map> healthResponse = restTemplate.getForEntity(healthUrl, Map.class);
                if (healthResponse.getStatusCode() != HttpStatus.OK) {
                    logger.warn("Whisper服务不可用：{}", healthResponse.getStatusCode());
                    return null;
                }
            } catch (Exception e) {
                logger.warn("无法连接到Whisper服务：{}，请确保服务已启动", whisperServiceUrl);
                return null;
            }

            // 准备请求
            String transcribeUrl = whisperServiceUrl + "/transcribe";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("file", new FileSystemResource(videoPath));
            body.add("language", "zh");  // 中文
            body.add("model", whisperModel);

            HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

            // 发送请求
            logger.info("发送转录请求到Whisper服务...");
            ResponseEntity<Map> response = restTemplate.postForEntity(transcribeUrl, requestEntity, Map.class);

            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                Map<String, Object> result = response.getBody();
                Boolean success = (Boolean) result.get("success");

                if (Boolean.TRUE.equals(success)) {
                    String text = (String) result.get("text");
                    logger.info("Whisper转录成功，文本长度：{}", text != null ? text.length() : 0);
                    return text;
                } else {
                    String error = (String) result.get("error");
                    logger.error("Whisper转录失败：{}", error);
                    return null;
                }
            } else {
                logger.error("Whisper服务返回异常状态：{}", response.getStatusCode());
                return null;
            }

        } catch (Exception e) {
            logger.error("调用Whisper服务失败：{}", e.getMessage(), e);
            return null;
        }
    }
    
    /**
     * 使用阿里云语音识别
     */
    private String extractUsingAliyun(String videoPath, String videoTitle, String videoDescription) {
        logger.info("使用阿里云语音识别提取视频内容");

        // TODO: 集成阿里云录音文件识别
        // https://help.aliyun.com/document_detail/90727.html

        logger.warn("阿里云语音识别功能尚未实现");
        return null;
    }

    /**
     * 使用腾讯云语音识别
     */
    private String extractUsingTencent(String videoPath, String videoTitle, String videoDescription) {
        logger.info("使用腾讯云语音识别提取视频内容");

        // TODO: 集成腾讯云录音文件识别
        // https://cloud.tencent.com/document/product/1093/37823

        logger.warn("腾讯云语音识别功能尚未实现");
        return null;
    }

    /**
     * 使用百度智能云语音识别
     */
    private String extractUsingBaidu(String videoPath, String videoTitle, String videoDescription) {
        logger.info("使用百度智能云语音识别提取视频内容");

        // TODO: 集成百度语音识别
        // https://cloud.baidu.com/doc/SPEECH/s/Jkl8i2xqq

        logger.warn("百度语音识别功能尚未实现");
        return null;
    }

    /**
     * 从元数据构建文本（降级方案）
     */
    private String buildTextFromMetadata(String title, String description) {
        StringBuilder text = new StringBuilder();

        if (title != null && !title.trim().isEmpty()) {
            text.append("【视频标题】\n").append(title).append("\n\n");
        }

        if (description != null && !description.trim().isEmpty()) {
            text.append("【视频描述】\n").append(description).append("\n");
        }

        return text.toString();
    }

    /**
     * 从转录文本和元数据构建完整文本
     */
    private String buildTextFromTranscription(String title, String description, String transcribedText) {
        StringBuilder text = new StringBuilder();

        if (title != null && !title.trim().isEmpty()) {
            text.append("【视频标题】\n").append(title).append("\n\n");
        }

        if (description != null && !description.trim().isEmpty()) {
            text.append("【视频描述】\n").append(description).append("\n\n");
        }

        if (transcribedText != null && !transcribedText.trim().isEmpty()) {
            text.append("【视频内容】\n").append(transcribedText).append("\n");
        }

        return text.toString();
    }

    /**
     * 将相对路径转换为绝对路径
     *
     * @param path 可能是相对路径（如 /profile/upload/xxx.mp4）或绝对路径
     * @return 绝对路径
     */
    private String getAbsolutePath(String path) {
        if (path == null || path.isEmpty()) {
            return path;
        }

        // 如果已经是绝对路径（Windows: C:\ 或 D:\，Linux: /home 等），直接返回
        File file = new File(path);
        if (file.isAbsolute()) {
            return path;
        }

        // 如果是相对路径（如 /profile/upload/xxx.mp4），转换为绝对路径
        // RuoYi的上传路径配置：ruoyi.profile = C:/ruoyi/uploadPath
        // 数据库存储的路径：/profile/upload/xxx.mp4
        // 实际文件路径：C:/ruoyi/uploadPath/upload/xxx.mp4

        String profilePath = ruoYiConfig.getProfile();

        // 移除开头的 /profile
        if (path.startsWith("/profile/")) {
            path = path.substring("/profile/".length());
        } else if (path.startsWith("/profile")) {
            path = path.substring("/profile".length());
        }

        // 拼接绝对路径
        return profilePath + File.separator + path;
    }
}

