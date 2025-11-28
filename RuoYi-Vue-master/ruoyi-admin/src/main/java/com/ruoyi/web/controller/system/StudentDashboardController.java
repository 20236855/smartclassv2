package com.ruoyi.web.controller.system;

import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 学生数据看板Controller
 * 提供学生首页Dashboard所需的统计数据
 *
 * @author ruoyi
 * @date 2025-11-26
 */
@RestController
@RequestMapping("/system/dashboard")
public class StudentDashboardController extends BaseController {
    private static final Logger logger = LoggerFactory.getLogger(StudentDashboardController.class);

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 获取当前学生的user.id（根据sys_user.user_id查询）
     */
    private Long getStudentUserId() {
        Long sysUserId = getUserId();
        logger.info("当前登录用户 sys_user_id={}", sysUserId);
        try {
            String sql = "SELECT id FROM user WHERE sys_user_id = ?";
            Long userId = jdbcTemplate.queryForObject(sql, Long.class, sysUserId);
            logger.info("查询到 user.id={}", userId);
            return userId;
        } catch (Exception e) {
            logger.warn("用户 sys_user_id={} 在 user 表中不存在: {}", sysUserId, e.getMessage());
            return null;
        }
    }

    /**
     * 获取学生Dashboard数据
     * 包含：课程列表、作业提交状态、成绩数据、视频学习行为
     */
    @GetMapping("/student-data")
    public AjaxResult getStudentDashboardData() {
        logger.info("=== 开始获取学生Dashboard数据 ===");
        Long studentUserId = getStudentUserId();
        Map<String, Object> result = new HashMap<>();

        if (studentUserId == null) {
            logger.warn("studentUserId 为 null，返回空数据");
            result.put("courses", new ArrayList<>());
            result.put("submissions", new ArrayList<>());
            Map<String, Integer> emptyTaskStats = new HashMap<>();
            emptyTaskStats.put("total", 0);
            emptyTaskStats.put("submitted", 0);
            emptyTaskStats.put("pending", 0);
            emptyTaskStats.put("expired", 0);
            result.put("taskStats", emptyTaskStats);
            Map<String, Object> emptyVideoStats = new HashMap<>();
            emptyVideoStats.put("totalVideos", 0);
            emptyVideoStats.put("completedVideos", 0);
            emptyVideoStats.put("totalWatchDuration", 0);
            result.put("videoStats", emptyVideoStats);
            result.put("knowledgePointCount", 0);
            return AjaxResult.success(result);
        }

        try {
            // 1. 获取学生选课的课程列表
            String courseSql = "SELECT c.id, c.title as name FROM course c " +
                    "JOIN course_student cs ON c.id = cs.course_id " +
                    "WHERE cs.student_user_id = ? AND c.is_deleted = 0 AND cs.is_deleted = 0";
            logger.info("执行课程查询SQL, studentUserId={}", studentUserId);
            List<Map<String, Object>> courses = jdbcTemplate.queryForList(courseSql, studentUserId);
            logger.info("查询到课程数量: {}, 课程列表: {}", courses.size(), courses);
            result.put("courses", courses);

            // 2. 获取该学生所有已提交作业的成绩（直接从 assignment_submission 表查询）
            String scoreSql = "SELECT " +
                    "asub.id as submissionId, " +
                    "asub.assignment_id as assignmentId, " +
                    "a.title as assignmentName, " +
                    "a.course_id as courseId, " +
                    "c.title as courseName, " +
                    "a.end_time as endTime, " +
                    "a.total_score as totalScore, " +
                    "asub.status as submitStatus, " +
                    "asub.score as score, " +
                    "asub.submit_time as submitTime " +
                    "FROM assignment_submission asub " +
                    "JOIN assignment a ON asub.assignment_id = a.id " +
                    "JOIN course c ON a.course_id = c.id " +
                    "WHERE asub.student_user_id = ? AND asub.is_deleted = 0 AND a.is_deleted = 0 " +
                    "ORDER BY asub.submit_time DESC";
            logger.info("执行成绩查询SQL, studentUserId={}", studentUserId);
            List<Map<String, Object>> scoreRecords = jdbcTemplate.queryForList(scoreSql, studentUserId);
            logger.info("查询到成绩记录数量: {}, 记录详情: {}", scoreRecords.size(), scoreRecords);

            // 3. 获取学生的作业列表（用于统计任务完成情况）
            String submissionSql = "SELECT " +
                    "a.id as assignmentId, " +
                    "a.title as assignmentName, " +
                    "a.course_id as courseId, " +
                    "c.title as courseName, " +
                    "a.end_time as endTime, " +
                    "a.status as assignmentStatus, " +
                    "a.total_score as totalScore, " +
                    "asub.status as submitStatus, " +
                    "asub.score as score, " +
                    "asub.submit_time as submitTime " +
                    "FROM assignment a " +
                    "JOIN course c ON a.course_id = c.id " +
                    "JOIN course_student cs ON c.id = cs.course_id AND cs.student_user_id = ? AND cs.is_deleted = 0 " +
                    "LEFT JOIN assignment_submission asub ON a.id = asub.assignment_id AND asub.student_user_id = ? AND asub.is_deleted = 0 " +
                    "WHERE a.is_deleted = 0 AND a.status = 1 " +
                    "ORDER BY a.end_time DESC";
            List<Map<String, Object>> submissions = jdbcTemplate.queryForList(submissionSql, studentUserId, studentUserId);
            logger.info("查询到作业列表数量: {}", submissions.size());

            // 合并成绩数据到作业列表（用 scoreRecords 中的数据）
            result.put("submissions", submissions);
            result.put("scoreRecords", scoreRecords);  // 单独返回成绩记录

            // 3. 统计任务完成情况（与作业考试页面保持一致）
            // total: 作业总数
            // submitted: 已提交（有提交记录的）
            // pending: 待提交（未提交且未截止）
            // expired: 已截止（截止时间已过，不管是否提交）
            int total = submissions.size();
            int submitted = 0, pending = 0, expired = 0;
            LocalDateTime now = LocalDateTime.now();
            for (Map<String, Object> sub : submissions) {
                Integer submitStatus = (Integer) sub.get("submitStatus");
                Object endTimeObj = sub.get("endTime");
                boolean isSubmitted = submitStatus != null && submitStatus >= 1;

                // 处理日期比较（兼容 LocalDateTime 类型）
                boolean isExpired = false;
                if (endTimeObj != null) {
                    if (endTimeObj instanceof LocalDateTime) {
                        isExpired = ((LocalDateTime) endTimeObj).isBefore(now);
                    } else if (endTimeObj instanceof Date) {
                        isExpired = ((Date) endTimeObj).before(new Date());
                    }
                }

                // 已提交
                if (isSubmitted) {
                    submitted++;
                }
                // 已截止（不管是否提交）
                if (isExpired) {
                    expired++;
                }
                // 待提交（未提交且未截止）
                if (!isSubmitted && !isExpired) {
                    pending++;
                }
            }
            Map<String, Integer> taskStats = new HashMap<>();
            taskStats.put("total", total);
            taskStats.put("submitted", submitted);
            taskStats.put("pending", pending);
            taskStats.put("expired", expired);
            result.put("taskStats", taskStats);

            // 4. 获取视频学习行为统计
            Map<String, Object> videoStats = new HashMap<>();
            try {
                String videoStatsSql = "SELECT " +
                        "COUNT(*) as totalVideos, " +
                        "SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completedVideos, " +
                        "SUM(COALESCE(watch_duration, 0)) as totalWatchDuration " +
                        "FROM video_learning_behavior WHERE student_id = ?";
                Map<String, Object> videoData = jdbcTemplate.queryForMap(videoStatsSql, studentUserId);
                videoStats.put("totalVideos", videoData.get("totalVideos") != null ? ((Number)videoData.get("totalVideos")).intValue() : 0);
                videoStats.put("completedVideos", videoData.get("completedVideos") != null ? ((Number)videoData.get("completedVideos")).intValue() : 0);
                videoStats.put("totalWatchDuration", videoData.get("totalWatchDuration") != null ? ((Number)videoData.get("totalWatchDuration")).intValue() : 0);
            } catch (Exception e) {
                logger.warn("获取视频学习行为失败: {}", e.getMessage());
                videoStats.put("totalVideos", 0);
                videoStats.put("completedVideos", 0);
                videoStats.put("totalWatchDuration", 0);
            }
            result.put("videoStats", videoStats);

            // 5. 获取知识点统计
            int knowledgePointCount = 0;
            try {
                // 获取学生所选课程的知识点总数
                if (!courses.isEmpty()) {
                    StringBuilder courseIds = new StringBuilder();
                    for (int i = 0; i < courses.size(); i++) {
                        if (i > 0) courseIds.append(",");
                        courseIds.append(courses.get(i).get("id"));
                    }
                    String kpSql = "SELECT COUNT(*) FROM knowledge_point WHERE course_id IN (" + courseIds + ") AND is_deleted = 0";
                    Integer kpCount = jdbcTemplate.queryForObject(kpSql, Integer.class);
                    knowledgePointCount = kpCount != null ? kpCount : 0;
                }
            } catch (Exception e) {
                logger.warn("获取知识点统计失败: {}", e.getMessage());
            }
            result.put("knowledgePointCount", knowledgePointCount);

            logger.info("=== Dashboard数据获取成功 ===");
            logger.info("任务统计: total={}, submitted={}, pending={}, expired={}",
                    taskStats.get("total"), taskStats.get("submitted"), taskStats.get("pending"), taskStats.get("expired"));
            return AjaxResult.success(result);

        } catch (Exception e) {
            logger.error("获取学生Dashboard数据失败", e);
            result.put("courses", new ArrayList<>());
            result.put("submissions", new ArrayList<>());
            Map<String, Integer> emptyTaskStats = new HashMap<>();
            emptyTaskStats.put("total", 0);
            emptyTaskStats.put("submitted", 0);
            emptyTaskStats.put("pending", 0);
            emptyTaskStats.put("expired", 0);
            result.put("taskStats", emptyTaskStats);
            Map<String, Object> emptyVideoStats = new HashMap<>();
            emptyVideoStats.put("totalVideos", 0);
            emptyVideoStats.put("completedVideos", 0);
            emptyVideoStats.put("totalWatchDuration", 0);
            result.put("videoStats", emptyVideoStats);
            result.put("knowledgePointCount", 0);
            return AjaxResult.success(result);
        }
    }
}

