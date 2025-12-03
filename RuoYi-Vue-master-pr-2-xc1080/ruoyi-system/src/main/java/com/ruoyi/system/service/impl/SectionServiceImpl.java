package com.ruoyi.system.service.impl;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.Section;
import com.ruoyi.system.domain.Video;
import com.ruoyi.system.domain.CourseResource;
import com.ruoyi.system.domain.SectionKp;
import com.ruoyi.system.domain.Chapter;
import com.ruoyi.system.domain.Course;
import com.ruoyi.system.mapper.SectionMapper;
import com.ruoyi.system.mapper.ChapterMapper;
import com.ruoyi.system.mapper.CourseMapper;
import com.ruoyi.system.service.ISectionService;
import com.ruoyi.system.service.IVideoService;
import com.ruoyi.system.service.ICourseResourceService;
import com.ruoyi.system.service.ICourseResourceKpService;
import com.ruoyi.system.service.ISectionKpService;
import com.ruoyi.system.utils.BusinessUserUtils;

/**
 * 课程小节 服务层实现
 *
 * @author ruoyi
 */
@Service
public class SectionServiceImpl implements ISectionService
{
    @Autowired
    private SectionMapper sectionMapper;
    
    @Autowired
    private ChapterMapper chapterMapper;
    
    @Autowired
    private CourseMapper courseMapper;
    
    @Autowired
    private IVideoService videoService;
    
    @Autowired
    private ICourseResourceService courseResourceService;
    
    @Autowired
    private ICourseResourceKpService courseResourceKpService;
    
    @Autowired
    private ISectionKpService sectionKpService;
    
    @Value("${ruoyi.profile}")
    private String uploadPath;

    /**
     * 查询小节信息
     *
     * @param id 小节ID
     * @return 小节信息
     */
    @Override
    public Section selectSectionById(Long id)
    {
        return sectionMapper.selectSectionById(id);
    }

    /**
     * 查询小节列表
     *
     * @param section 小节信息
     * @return 小节集合
     */
    @Override
    public List<Section> selectSectionList(Section section)
    {
        return sectionMapper.selectSectionList(section);
    }

    /**
     * 根据章节ID查询小节列表
     *
     * @param chapterId 章节ID
     * @return 小节集合
     */
    @Override
    public List<Section> selectSectionListByChapterId(Long chapterId)
    {
        return sectionMapper.selectSectionListByChapterId(chapterId);
    }

    /**
     * 新增小节
     *
     * @param section 小节信息
     * @return 结果
     */
    @Override
    public int insertSection(Section section)
    {
        return sectionMapper.insertSection(section);
    }

    /**
     * 修改小节
     *
     * @param section 小节信息
     * @return 结果
     */
    @Override
    @Transactional
    public int updateSection(Section section)
    {
        // 先获取旧的小节信息
        Section oldSection = sectionMapper.selectSectionById(section.getId());
        String oldVideoUrl = oldSection != null ? oldSection.getVideoUrl() : null;
        String newVideoUrl = section.getVideoUrl();
        
        // 更新小节基本信息
        int result = sectionMapper.updateSection(section);
        
        // 如果视频URL有变化（新增或更新），则同步到video表和course_resource表
        // 注意：如果newVideoUrl为空字符串，表示删除视频，不需要创建resource记录
        if (result > 0 && newVideoUrl != null && !newVideoUrl.isEmpty() && !newVideoUrl.equals(oldVideoUrl))
        {
            // 获取章节信息以获取课程ID
            Chapter chapter = chapterMapper.selectChapterById(section.getChapterId());
            if (chapter != null)
            {
                Long courseId = chapter.getCourseId();
                // 使用BusinessUserUtils获取当前业务用户ID
                Long uploadUserId = BusinessUserUtils.getCurrentBusinessUserId();
                
                // 1. 写入video表
                Video video = new Video();
                video.setCourseId(courseId);
                video.setTitle(section.getTitle());
                video.setDescription(section.getDescription());
                video.setFilePath(newVideoUrl);
                video.setDuration(section.getDuration());
                video.setStatus("published");
                video.setViewCount(0);
                video.setUploadedBy(uploadUserId);
                
                // 尝试获取文件大小
                try {
                    File videoFile = new File(uploadPath + newVideoUrl);
                    if (videoFile.exists()) {
                        video.setFileSize(videoFile.length());
                    }
                } catch (Exception e) {
                    // 忽略文件大小获取失败的情况
                }
                
                videoService.insertVideo(video);
                
                // 2. 写入course_resource表
                CourseResource resource = new CourseResource();
                resource.setCourseId(courseId);
                resource.setName(section.getTitle());
                
                // 从URL中提取文件扩展名作为文件类型
                String fileType = "mp4"; // 默认类型
                if (newVideoUrl != null && newVideoUrl.contains(".")) {
                    fileType = newVideoUrl.substring(newVideoUrl.lastIndexOf(".") + 1).toLowerCase();
                }
                resource.setFileType(fileType);
                
                // 设置文件大小
                if (video.getFileSize() != null) {
                    resource.setFileSize(video.getFileSize());
                } else {
                    resource.setFileSize(0L);
                }
                
                resource.setFileUrl(newVideoUrl);
                resource.setDescription("小节视频: " + section.getTitle());
                resource.setDownloadCount(0);
                resource.setUploadUserId(uploadUserId);
                
                courseResourceService.insertCourseResource(resource);
                
                // 3. 关联该小节的知识点到course_resource_kp表
                List<SectionKp> sectionKpList = sectionKpService.selectSectionKpListBySectionId(section.getId());
                if (sectionKpList != null && !sectionKpList.isEmpty())
                {
                    Long[] kpIds = sectionKpList.stream()
                        .map(SectionKp::getKpId)
                        .toArray(Long[]::new);
                    courseResourceKpService.batchInsertCourseResourceKp(resource.getId(), kpIds);
                }
            }
        }
        
        return result;
    }

    /**
     * 删除小节信息
     *
     * @param id 小节ID
     * @return 结果
     */
    @Override
    public int deleteSectionById(Long id)
    {
        return sectionMapper.deleteSectionById(id);
    }

    /**
     * 批量删除小节信息
     *
     * @param ids 需要删除的小节ID
     * @return 结果
     */
    @Override
    public int deleteSectionByIds(Long[] ids)
    {
        return sectionMapper.deleteSectionByIds(ids);
    }

    /**
     * 根据视频URL查询小节
     *
     * @param videoUrl 视频URL
     * @return 小节信息
     */
    @Override
    public Section selectSectionByVideoUrl(String videoUrl)
    {
        return sectionMapper.selectSectionByVideoUrl(videoUrl);
    }
    
    /**
     * 获取课时燃尽图数据
     * 统计教师所有课程的小节数量和上课时间
     *
     * @return 燃尽图数据
     */
    @Override
    public Map<String, Object> getBurndownChartData()
    {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 获取当前教师ID
            Long teacherId = BusinessUserUtils.getCurrentBusinessUserId();
            if (teacherId == null) {
                result.put("totalSections", 0);
                result.put("timeline", new ArrayList<>());
                return result;
            }
            
            // 查询教师的所有课程
            Course courseQuery = new Course();
            courseQuery.setTeacherUserId(teacherId);
            List<Course> courses = courseMapper.selectCourseList(courseQuery);
            
            if (courses == null || courses.isEmpty()) {
                result.put("totalSections", 0);
                result.put("timeline", new ArrayList<>());
                return result;
            }
            
            // 获取所有课程的章节ID
            List<Long> courseIds = courses.stream().map(Course::getId).collect(Collectors.toList());
            List<Long> chapterIds = new ArrayList<>();
            for (Long courseId : courseIds) {
                Chapter chapterQuery = new Chapter();
                chapterQuery.setCourseId(courseId);
                List<Chapter> chapters = chapterMapper.selectChapterList(chapterQuery);
                chapterIds.addAll(chapters.stream().map(Chapter::getId).collect(Collectors.toList()));
            }
            
            if (chapterIds.isEmpty()) {
                result.put("totalSections", 0);
                result.put("timeline", new ArrayList<>());
                return result;
            }
            
            // 查询所有小节
            List<Section> allSections = new ArrayList<>();
            for (Long chapterId : chapterIds) {
                List<Section> sections = sectionMapper.selectSectionListByChapterId(chapterId);
                allSections.addAll(sections);
            }
            
            // 统计总小节数
            int totalSections = allSections.size();
            result.put("totalSections", totalSections);
            
            // 获取课程的开始和结束时间
            Date startDate = null;
            Date endDate = null;
            
            for (Course course : courses) {
                if (course.getStartTime() != null) {
                    if (startDate == null || course.getStartTime().before(startDate)) {
                        startDate = course.getStartTime();
                    }
                }
                if (course.getEndTime() != null) {
                    if (endDate == null || course.getEndTime().after(endDate)) {
                        endDate = course.getEndTime();
                    }
                }
            }
            
            // 如果没有设置开始结束时间，使用默认值
            Calendar cal = Calendar.getInstance();
            if (startDate == null) {
                cal.add(Calendar.MONTH, -3); // 默认3个月前
                startDate = cal.getTime();
            }
            if (endDate == null) {
                cal = Calendar.getInstance();
                cal.add(Calendar.MONTH, 3); // 默认3个月后
                endDate = cal.getTime();
            }
            
            // 生成时间轴数据（按月日格式）
            SimpleDateFormat sdf = new SimpleDateFormat("MM-dd");
            List<Map<String, Object>> timeline = new ArrayList<>();
            
            cal = Calendar.getInstance();
            cal.setTime(startDate);
            Date currentDate = new Date();
            
            while (!cal.getTime().after(endDate)) {
                Map<String, Object> point = new HashMap<>();
                Date date = cal.getTime();
                point.put("date", sdf.format(date));
                
                // 统计该日期之前有多少小节已上课
                int completedCount = 0;
                for (Section section : allSections) {
                    if (section.getClassTime() != null && !section.getClassTime().after(date)) {
                        completedCount++;
                    }
                }
                
                // 剩余课时 = 总课时 - 已上课时
                int remaining = totalSections - completedCount;
                point.put("remaining", remaining);
                
                timeline.add(point);
                
                // 增加天数（前期按周，后期按天）
                long daysDiff = (date.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24);
                if (daysDiff < 30) {
                    cal.add(Calendar.DAY_OF_MONTH, 7); // 第一个月按周
                } else {
                    cal.add(Calendar.DAY_OF_MONTH, 3); // 之后每3天一个点
                }
            }
            
            result.put("timeline", timeline);
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("totalSections", 0);
            result.put("timeline", new ArrayList<>());
        }
        
        return result;
    }
}
