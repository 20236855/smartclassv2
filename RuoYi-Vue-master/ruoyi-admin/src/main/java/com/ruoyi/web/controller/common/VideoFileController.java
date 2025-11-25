package com.ruoyi.web.controller.common;

import com.ruoyi.common.annotation.Anonymous;
import com.ruoyi.common.config.RuoYiConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * 视频文件访问控制器
 * 用于提供视频文件的HTTP访问
 */
@Anonymous
@RestController
@RequestMapping("/videos")
public class VideoFileController {
    
    private static final Logger log = LoggerFactory.getLogger(VideoFileController.class);

    /**
     * 获取视频文件
     * @param filename 视频文件名
     * @return 视频文件
     */
    @GetMapping("/{filename:.+}")
    public ResponseEntity<Resource> getVideo(@PathVariable String filename) {
        try {
            // 构建文件路径
            String videosPath = RuoYiConfig.getProfile() + "/videos/";
            Path filePath = Paths.get(videosPath, filename);
            File file = filePath.toFile();
            
            log.info("========================================");
            log.info("请求视频文件: {}", filename);
            log.info("完整路径: {}", filePath.toAbsolutePath());
            log.info("文件是否存在: {}", file.exists());
            if (file.exists()) {
                log.info("文件大小: {} bytes", file.length());
            }
            log.info("========================================");
            
            // 检查文件是否存在
            if (!file.exists() || !file.isFile()) {
                log.error("视频文件不存在: {}", filePath.toAbsolutePath());
                return ResponseEntity.notFound().build();
            }
            
            // 创建资源
            Resource resource = new FileSystemResource(file);
            
            // 确定内容类型
            String contentType = Files.probeContentType(filePath);
            if (contentType == null) {
                contentType = "video/mp4"; // 默认为MP4
            }
            
            log.info("返回视频文件，Content-Type: {}", contentType);
            
            // 返回文件
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + filename + "\"")
                    .header(HttpHeaders.ACCEPT_RANGES, "bytes")
                    .header(HttpHeaders.CACHE_CONTROL, "public, max-age=3600")
                    .body(resource);
                    
        } catch (Exception e) {
            log.error("获取视频文件失败: {}", filename, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}

