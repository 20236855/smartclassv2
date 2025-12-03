package com.ruoyi.web.controller.system;

import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.system.domain.Assignment;
import com.ruoyi.system.service.IAssignmentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * 作业或考试Controller
 *
 * @author ruoyi
 * @date 2025-11-18
 */
@RestController
@RequestMapping("/system/assignment")
public class AssignmentController extends BaseController
{
    private static final Logger logger = LoggerFactory.getLogger(AssignmentController.class);

    @Autowired
    private IAssignmentService assignmentService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 查询作业或考试列表
     */
    @PreAuthorize("@ss.hasPermi('system:assignment:list')")
    @GetMapping("/list")
    public TableDataInfo list(Assignment assignment)
    {
        startPage();
        List<Assignment> list = assignmentService.selectAssignmentList(assignment);
        return getDataTable(list);
    }

    /**
     * 导出作业或考试列表
     */
    @PreAuthorize("@ss.hasPermi('system:assignment:export')")
    @Log(title = "作业或考试", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, Assignment assignment)
    {
        List<Assignment> list = assignmentService.selectAssignmentList(assignment);
        ExcelUtil<Assignment> util = new ExcelUtil<Assignment>(Assignment.class);
        util.exportExcel(response, list, "作业或考试数据");
    }

    /**
     * 获取作业或考试详细信息
     */
    @PreAuthorize("@ss.hasPermi('system:assignment:query')")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id)
    {
        return success(assignmentService.selectAssignmentById(id));
    }

    /**
     * 新增作业或考试
     */
    @PreAuthorize("@ss.hasPermi('system:assignment:add')")
    @Log(title = "作业或考试", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Assignment assignment)
    {
        return toAjax(assignmentService.insertAssignment(assignment));
    }

    /**
     * 修改作业或考试
     */
    @PreAuthorize("@ss.hasPermi('system:assignment:edit')")
    @Log(title = "作业或考试", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Assignment assignment)
    {
        return toAjax(assignmentService.updateAssignment(assignment));
    }

    /**
     * 删除作业或考试
     */
    @PreAuthorize("@ss.hasPermi('system:assignment:remove')")
    @Log(title = "作业或考试", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids)
    {
        return toAjax(assignmentService.deleteAssignmentByIds(ids));
    }

    /**
     * 获取作业的题目列表（包含题目详情和选项）
     */
    @PreAuthorize("@ss.hasPermi('system:assignment:query')")
    @GetMapping("/{id}/questions")
    public AjaxResult getAssignmentQuestions(@PathVariable("id") Long id)
    {
        return success(assignmentService.getAssignmentQuestions(id));
    }

    /**
     * 获取当前学生的user.id（根据sys_user.user_id查询）
     */
    private Long getStudentUserId() {
        Long sysUserId = getUserId();
        try {
            String sql = "SELECT id FROM user WHERE sys_user_id = ?";
            return jdbcTemplate.queryForObject(sql, Long.class, sysUserId);
        } catch (Exception e) {
            logger.warn("用户 sys_user_id={} 在 user 表中不存在", sysUserId);
            return null;
        }
    }

    /**
     * 学生提交作业（答题型）
     * 接收学生的答案并保存到数据库
     */
    @PreAuthorize("@ss.hasPermi('system:assignment:list')")
    @Log(title = "提交作业", businessType = BusinessType.INSERT)
    @PostMapping("/{id}/submit")
    public AjaxResult submitAssignment(@PathVariable("id") Long assignmentId, @RequestBody Map<String, Object> submitData)
    {
        Long studentUserId = getStudentUserId();
        if (studentUserId == null) {
            return error("用户信息不存在，请联系管理员");
        }

        try {
            // 1. 检查作业是否存在
            Assignment assignment = assignmentService.selectAssignmentById(assignmentId);
            if (assignment == null) {
                return error("作业不存在");
            }

            // 2. 检查是否已截止
            if (assignment.getEndTime() != null && new Date().after(assignment.getEndTime())) {
                return error("作业已截止，无法提交");
            }

            // 3. 查询是否已有提交记录
            String checkSql = "SELECT id FROM assignment_submission WHERE assignment_id = ? AND student_user_id = ? AND is_deleted = 0";
            List<Map<String, Object>> existingSubmissions = jdbcTemplate.queryForList(checkSql, assignmentId, studentUserId);

            Date now = new Date();

            if (!existingSubmissions.isEmpty()) {
                // 如果是考试类型，不允许重复提交
                if ("exam".equals(assignment.getType())) {
                    return error("考试只能提交一次，不允许重复作答");
                }
                // 更新已有提交记录（作业可以重新提交）
                Long submissionId = ((Number) existingSubmissions.get(0).get("id")).longValue();
                String updateSql = "UPDATE assignment_submission SET status = 1, submit_time = ?, content = ?, update_time = ? WHERE id = ?";
                String content = submitData.get("content") != null ? submitData.get("content").toString() : "";
                jdbcTemplate.update(updateSql, now, content, now, submissionId);
                logger.info("更新作业提交记录: submissionId={}, assignmentId={}, studentUserId={}", submissionId, assignmentId, studentUserId);
            } else {
                // 创建新的提交记录
                String insertSql = "INSERT INTO assignment_submission (assignment_id, student_user_id, status, submit_time, content, is_deleted, create_time) VALUES (?, ?, 1, ?, ?, 0, ?)";
                String content = submitData.get("content") != null ? submitData.get("content").toString() : "";
                jdbcTemplate.update(insertSql, assignmentId, studentUserId, now, content, now);
                logger.info("创建作业提交记录: assignmentId={}, studentUserId={}", assignmentId, studentUserId);
            }

            // 4. 如果有答案数据，保存学生答案（可选：保存到 student_answer 表或 JSON 字段）
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> answers = (List<Map<String, Object>>) submitData.get("answers");
            if (answers != null && !answers.isEmpty()) {
                // 将答案保存为 JSON 字符串存入 content 字段
                StringBuilder contentBuilder = new StringBuilder();
                for (Map<String, Object> answer : answers) {
                    if (contentBuilder.length() > 0) contentBuilder.append(";");
                    contentBuilder.append(answer.get("questionId")).append(":").append(answer.get("answer"));
                }
                String answerContent = contentBuilder.toString();

                // 更新 content 字段
                String updateContentSql = "UPDATE assignment_submission SET content = ? WHERE assignment_id = ? AND student_user_id = ? AND is_deleted = 0";
                jdbcTemplate.update(updateContentSql, answerContent, assignmentId, studentUserId);
            }

            return success("提交成功");

        } catch (Exception e) {
            logger.error("提交作业失败: assignmentId={}, studentUserId={}", assignmentId, studentUserId, e);
            return error("提交失败，请稍后重试");
        }
    }

    /**
     * 学生提交作业（上传型）
     * 接收文件路径和备注信息
     */
    @PreAuthorize("@ss.hasPermi('system:assignment:list')")
    @Log(title = "上传作业", businessType = BusinessType.INSERT)
    @PostMapping("/{id}/upload")
    public AjaxResult uploadAssignment(@PathVariable("id") Long assignmentId, @RequestBody Map<String, Object> uploadData)
    {
        Long studentUserId = getStudentUserId();
        if (studentUserId == null) {
            return error("用户信息不存在，请联系管理员");
        }

        try {
            // 1. 检查作业是否存在
            Assignment assignment = assignmentService.selectAssignmentById(assignmentId);
            if (assignment == null) {
                return error("作业不存在");
            }

            // 2. 检查是否已截止
            if (assignment.getEndTime() != null && new Date().after(assignment.getEndTime())) {
                return error("作业已截止，无法提交");
            }

            String filePath = uploadData.get("files") != null ? uploadData.get("files").toString() : "";
            String remark = uploadData.get("remark") != null ? uploadData.get("remark").toString() : "";

            // 3. 查询是否已有提交记录
            String checkSql = "SELECT id FROM assignment_submission WHERE assignment_id = ? AND student_user_id = ? AND is_deleted = 0";
            List<Map<String, Object>> existingSubmissions = jdbcTemplate.queryForList(checkSql, assignmentId, studentUserId);

            Date now = new Date();

            if (!existingSubmissions.isEmpty()) {
                // 更新已有提交记录
                Long submissionId = ((Number) existingSubmissions.get(0).get("id")).longValue();
                String updateSql = "UPDATE assignment_submission SET status = 1, submit_time = ?, file_path = ?, content = ?, update_time = ? WHERE id = ?";
                jdbcTemplate.update(updateSql, now, filePath, remark, now, submissionId);
                logger.info("更新上传作业记录: submissionId={}, assignmentId={}, studentUserId={}", submissionId, assignmentId, studentUserId);
            } else {
                // 创建新的提交记录
                String insertSql = "INSERT INTO assignment_submission (assignment_id, student_user_id, status, submit_time, file_path, content, is_deleted, create_time) VALUES (?, ?, 1, ?, ?, ?, 0, ?)";
                jdbcTemplate.update(insertSql, assignmentId, studentUserId, now, filePath, remark, now);
                logger.info("创建上传作业记录: assignmentId={}, studentUserId={}", assignmentId, studentUserId);
            }

            return success("提交成功");

        } catch (Exception e) {
            logger.error("上传作业失败: assignmentId={}, studentUserId={}", assignmentId, studentUserId, e);
            return error("提交失败，请稍后重试");
        }
    }

    /**
     * 获取当前学生的作业提交记录
     * 用于前端判断哪些作业已提交
     */
    @PreAuthorize("@ss.hasPermi('system:assignment:list')")
    @GetMapping("/my-submissions")
    public AjaxResult getMySubmissions()
    {
        Long studentUserId = getStudentUserId();
        if (studentUserId == null) {
            return success(new java.util.ArrayList<>());
        }

        try {
            String sql = "SELECT assignment_id as assignmentId, status, score, submit_time as submitTime " +
                    "FROM assignment_submission WHERE student_user_id = ? AND is_deleted = 0";
            List<Map<String, Object>> submissions = jdbcTemplate.queryForList(sql, studentUserId);
            return success(submissions);
        } catch (Exception e) {
            logger.error("获取提交记录失败: studentUserId={}", studentUserId, e);
            return success(new java.util.ArrayList<>());
        }
    }
}
