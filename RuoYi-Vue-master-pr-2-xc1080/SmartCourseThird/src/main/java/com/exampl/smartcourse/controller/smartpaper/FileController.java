package com.exampl.smartcourse.controller.smartpaper;

import com.exampl.smartcourse.common.smartpaper.Result;
import com.exampl.smartcourse.dto.smartpaper.response.FileUploadResponse;
import com.exampl.smartcourse.service.smartpaper.IFileService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * 文件管理控制器
 */
@Tag(name = "文件管理", description = "文件上传、下载相关接口")
@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
@Slf4j
public class FileController {

    private final IFileService fileService;
    private final com.exampl.smartcourse.util.FilePathResolver filePathResolver;

    @Value("${file.upload.path}")
    private String uploadPath;

    @Operation(
        summary = "上传文件",
        description = "支持上传文档、图片等文件，可指定分类(answer/material/attachment)"
    )
    @PostMapping(
        value = "/upload",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public Result<FileUploadResponse> uploadFile(
            @Parameter(
                description = "上传的文件",
                required = true,
                content = @Content(mediaType = MediaType.APPLICATION_OCTET_STREAM_VALUE)
            )
            @RequestPart("file") MultipartFile file,
            
            @Parameter(
                description = "文件分类: answer(答案), material(资料), attachment(附件)",
                example = "answer",
                schema = @Schema(type = "string", allowableValues = {"answer", "material", "attachment"})
            )
            @RequestParam(value = "category", required = false, defaultValue = "answer") String category) {

        log.info("收到文件上传请求：文件名={}, 大小={}, 分类={}",
                file.getOriginalFilename(), file.getSize(), category);

        FileUploadResponse response = fileService.uploadFile(file, category);
        return Result.success("文件上传成功", response);
    }

    @Operation(
        summary = "上传课程资源文件",
        description = "将文件保存到 /courses/{courseId}/{uploaderUserId}/，返回可下载的相对URL"
    )
    @PostMapping(
        value = "/upload-to-courses",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public Result<FileUploadResponse> uploadToCourses(
            @Parameter(description = "上传的文件", required = true,
                    content = @Content(mediaType = MediaType.APPLICATION_OCTET_STREAM_VALUE))
            @RequestPart("file") MultipartFile file,

            @Parameter(description = "课程ID", required = true)
            @RequestParam("courseId") Long courseId,

            @Parameter(description = "上传者用户ID", required = true)
            @RequestParam("uploaderUserId") Long uploaderUserId
    ) {
        log.info("收到课程资源上传请求：file={}, courseId={}, uploaderUserId={}",
                file != null ? file.getOriginalFilename() : null, courseId, uploaderUserId);
        FileUploadResponse response = fileService.uploadToCourses(file, courseId, uploaderUserId);
        log.info("课程资源上传生成返回：fileName={}, fileUrl={}", response.getFileName(), response.getFileUrl());
        return Result.success("文件上传成功", response);
    }

    @Operation(summary = "下载文件")
    @GetMapping("/download/**")
    public ResponseEntity<Resource> downloadFile(
            @Parameter(description = "文件路径") @RequestParam("filePath") String filePath) {

        try {
            // 构造完整文件路径
            String fullPath = uploadPath + filePath.replace("/uploads", "");
            log.info("文件下载请求：filePath={}, uploadPath={}, fullPath={}", filePath, uploadPath, fullPath);
            File file = new File(fullPath);

            if (!file.exists() || !file.isFile()) {
                log.warn("文件未找到或不是文件：{}", fullPath);
                return ResponseEntity.notFound().build();
            }

            Resource resource = new FileSystemResource(file);
            String fileName = file.getName();
            String encodedFileName = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20");

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(MediaType.APPLICATION_OCTET_STREAM_VALUE))
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            "attachment; filename=\"" + encodedFileName + "\"; filename*=UTF-8''" + encodedFileName)
                    .body(resource);
        } catch (Exception e) {
            log.error("文件下载失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @Operation(summary = "从课程资源目录下载文件")
    @GetMapping("/download-from-courses")
    public ResponseEntity<Resource> downloadFromCourses(
            @Parameter(description = "相对文件URL，例如 /courses/{courseId}/{uploaderUserId}/{fileName}")
            @RequestParam("fileUrl") String fileUrl) {
        try {
            if (fileUrl == null || fileUrl.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }
            String normalized = fileUrl.replace('\\', '/');
            if (normalized.startsWith("http://") || normalized.startsWith("https://")) {
                try {
                    java.net.URI uri = new java.net.URI(normalized);
                    normalized = uri.getPath();
                } catch (Exception ignore) {}
            }
            if (normalized.startsWith("/")) {
                normalized = normalized.substring(1);
            }
            log.info("课程资源下载请求：fileUrl={}, normalized={}", fileUrl, normalized);
            // 通过统一解析器解析物理路径（支持 local-base 与 data 目录回退）
            String fullPath = filePathResolver.resolve(normalized);
            log.info("解析得到物理路径：{}", fullPath);
            File file = new File(fullPath);
            if (!file.exists() || !file.isFile()) {
                log.warn("课程资源未找到或不是文件：{}", fullPath);
                int idx = normalized.lastIndexOf('/');
                String dirRel = idx > 0 ? normalized.substring(0, idx) : normalized;
                String reqName = idx > 0 ? normalized.substring(idx + 1) : normalized;
                String reqExt = reqName.contains(".") ? reqName.substring(reqName.lastIndexOf('.') + 1) : "";
                File primaryDir = new File(new File(fullPath).getParent());
                File dataDir = new File("d:/githubRepository/smartclassv2/RuoYi-Vue-master-pr-2-xc1080/SmartCourseThird/data/" + dirRel);
                File chosen = chooseSimilar(primaryDir, dataDir, reqName, reqExt);
                if (chosen != null && chosen.exists() && chosen.isFile()) {
                    log.info("采用相似文件回退：{}", chosen.getAbsolutePath());
                    file = chosen;
                } else {
                    return ResponseEntity.notFound().build();
                }
            }

            Resource resource = new FileSystemResource(file);
            String fileName = file.getName();
            String encodedFileName = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20");

            return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            "attachment; filename=\"" + encodedFileName + "\"; filename*=UTF-8''" + encodedFileName)
                    .body(resource);
        } catch (Exception e) {
            log.error("课程资源文件下载失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    private File chooseSimilar(File primaryDir, File dataDir, String requestedName, String requestedExt) {
        File[] arr1 = (primaryDir != null && primaryDir.exists() && primaryDir.isDirectory()) ? primaryDir.listFiles() : null;
        File[] arr2 = (dataDir != null && dataDir.exists() && dataDir.isDirectory()) ? dataDir.listFiles() : null;
        File best = null;
        int bestScore = -1;
        if (arr1 != null) {
            for (File f : arr1) {
                if (!f.isFile()) continue;
                String name = f.getName();
                String ext = name.contains(".") ? name.substring(name.lastIndexOf('.') + 1) : "";
                if (!requestedExt.isEmpty() && !requestedExt.equalsIgnoreCase(ext)) continue;
                int score = commonPrefixLen(name.toLowerCase(), requestedName.toLowerCase());
                if (score > bestScore) { bestScore = score; best = f; }
                if (name.equalsIgnoreCase(requestedName)) return f;
            }
        }
        if (arr2 != null) {
            for (File f : arr2) {
                if (!f.isFile()) continue;
                String name = f.getName();
                String ext = name.contains(".") ? name.substring(name.lastIndexOf('.') + 1) : "";
                if (!requestedExt.isEmpty() && !requestedExt.equalsIgnoreCase(ext)) continue;
                int score = commonPrefixLen(name.toLowerCase(), requestedName.toLowerCase());
                if (score > bestScore) { bestScore = score; best = f; }
                if (name.equalsIgnoreCase(requestedName)) return f;
            }
        }
        return best;
    }

    private int commonPrefixLen(String a, String b) {
        int n = Math.min(a.length(), b.length());
        int i = 0;
        while (i < n && a.charAt(i) == b.charAt(i)) i++;
        return i;
    }
    @Operation(summary = "删除文件")
    @DeleteMapping
    public Result<Void> deleteFile(
            @Parameter(description = "文件URL") @RequestParam("fileUrl") String fileUrl) {

        log.info("收到文件删除请求：fileUrl={}", fileUrl);
        fileService.deleteFile(fileUrl);
        return Result.success("文件删除成功", null);
    }
}
