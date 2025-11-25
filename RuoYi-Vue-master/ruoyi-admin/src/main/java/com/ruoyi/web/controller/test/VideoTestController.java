package com.ruoyi.web.controller.test;

import com.ruoyi.common.annotation.Anonymous;
import com.ruoyi.common.config.RuoYiConfig;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * 视频路径测试控制器
 */
@Anonymous
@RestController
@RequestMapping("/test/video")
public class VideoTestController {

    @GetMapping("/config")
    public Map<String, Object> testConfig() {
        Map<String, Object> result = new HashMap<>();
        
        String profilePath = RuoYiConfig.getProfile();
        String videosPath = profilePath + "/videos/";
        
        result.put("profilePath", profilePath);
        result.put("videosPath", videosPath);
        result.put("videosPathExists", new File(videosPath).exists());
        
        // 检查测试视频文件
        String testVideoPath = videosPath + "1_20251120193138A003.mp4";
        File testVideoFile = new File(testVideoPath);
        result.put("testVideoPath", testVideoPath);
        result.put("testVideoExists", testVideoFile.exists());
        result.put("testVideoSize", testVideoFile.exists() ? testVideoFile.length() : 0);
        
        // 列出videos目录下的所有文件
        File videosDir = new File(videosPath);
        if (videosDir.exists() && videosDir.isDirectory()) {
            String[] files = videosDir.list();
            result.put("filesInVideosDir", files);
        }
        
        return result;
    }
}

