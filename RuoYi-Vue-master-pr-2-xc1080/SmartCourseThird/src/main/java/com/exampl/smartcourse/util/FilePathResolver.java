package com.exampl.smartcourse.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Component
@Slf4j
public class FilePathResolver {

    @Value("${smartcourse.file.storage.mode:local}")
    private String mode;

    @Value("${smartcourse.file.storage.server-base:}")
    private String serverBase;

    @Value("${smartcourse.file.storage.local-base:}")
    private String localBase;

    public String resolve(String dbPath) {
        if (dbPath == null || dbPath.isEmpty()) {
            throw new IllegalArgumentException("db file path is empty");
        }
        String normalized = dbPath.replace('\\', '/');
        if (normalized.startsWith("/")) {
            normalized = normalized.substring(1);
        }
        String base = isServerMode() ? serverBase : localBase;
        if (base == null || base.isEmpty()) {
            throw new IllegalStateException("file storage base path is not configured for mode: " + mode);
        }
        Path resolved = Paths.get(base, normalized).normalize();
        if (Files.exists(resolved)) {
            String p = resolved.toString();
            log.info("FilePathResolver: primary path exists: {}", p);
            return p;
        }
        Path dataResolved = Paths.get("d:/githubRepository/smartclassv2/RuoYi-Vue-master-pr-2-xc1080/SmartCourseThird/data", normalized).normalize();
        if (Files.exists(dataResolved)) {
            String p = dataResolved.toString();
            log.info("FilePathResolver: fallback data path exists: {}", p);
            return p;
        }
        log.warn("FilePathResolver: file not found, returning primary constructed path: {}", resolved.toString());
        return resolved.toString();
    }

    private boolean isServerMode() {
        return "server".equalsIgnoreCase(mode);
    }
}
