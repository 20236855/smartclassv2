package com.ruoyi.system.service.impl;

import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Set;
import java.util.HashSet;
import java.util.Arrays;
import java.util.stream.Collectors;
import com.ruoyi.common.utils.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.mapper.KnowledgeGraphMapper;
import com.ruoyi.system.domain.KnowledgeGraph;
import com.ruoyi.system.service.IKnowledgeGraphService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import com.ruoyi.common.utils.SecurityUtils;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * 知识图谱Service业务层处理
 * 
 * @author ruoyi
 * @date 2025-11-21
 */
@Service
public class KnowledgeGraphServiceImpl implements IKnowledgeGraphService 
{
    private static final Logger logger = LoggerFactory.getLogger(KnowledgeGraphServiceImpl.class);
    @Autowired
    private KnowledgeGraphMapper knowledgeGraphMapper;
    @Autowired
    private com.ruoyi.system.service.ICourseService courseService;
    @Autowired
    private com.ruoyi.system.service.ICourseResourceService courseResourceService;
    @Autowired
    private com.ruoyi.system.service.IQuestionService questionService;
    @Autowired
    private com.ruoyi.system.service.IVideoService videoService;
    @Autowired
    private com.ruoyi.system.mapper.VideoMapper videoMapper;
    @Autowired
    private com.ruoyi.system.service.IChapterService chapterService;
    @Autowired
    private AiExtractionService aiExtractionService;
    @Autowired
    private VideoTranscriptionService videoTranscriptionService;

    // 允许的关系类型（对应数据库ENUM）
    private static final Set<String> VALID_RELATION_TYPES = new HashSet<>(Arrays.asList(
        "prerequisite_of", "similar_to", "extension_of", "derived_from", "counterexample_of"
    ));
    @Autowired
    private com.ruoyi.system.service.IKnowledgePointService knowledgePointService;
    @Autowired
    private com.ruoyi.system.service.IKpRelationService kpRelationService;
    @Autowired
    private com.ruoyi.system.service.ISectionService sectionService;
    @Autowired
    private com.ruoyi.system.mapper.SectionKpMapper sectionKpMapper;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 将 sys_user 表的 user_id 映射到 user 表的 id
     * 注意：sys_user 和 user 可能是不同的表，需要通过某种方式关联
     */
    private Long mapSysUserIdToUserId(Long sysUserId) {
        try {
            // 尝试查询 user 表中是否有相同ID的用户
            String sql = "SELECT id FROM user WHERE id = ? LIMIT 1";
            logger.info("查询user表是否存在ID={}", sysUserId);
            List<Long> userIds = jdbcTemplate.queryForList(sql, Long.class, sysUserId);
            if (userIds != null && !userIds.isEmpty()) {
                logger.info("user表中存在ID={}", sysUserId);
                return userIds.get(0);
            }
            logger.warn("user表中不存在ID={}，将使用默认用户ID", sysUserId);
        } catch (Exception e) {
            logger.error("查询user表ID失败", e);
        }
        return null;
    }

    /**
     * 获取一个有效的默认用户ID（用于异步任务无法获取当前用户时）
     * 注意：这里查询的是 user 表（外键约束指向的表），而不是 sys_user 表
     */
    private Long getDefaultCreatorId() {
        try {
            logger.info("开始查询user表获取默认用户ID...");
            // 直接查询 user 表中的第一个用户（按ID排序）
            String sql = "SELECT id FROM user ORDER BY id ASC LIMIT 1";
            logger.info("执行SQL: {}", sql);
            List<Long> userIds = jdbcTemplate.queryForList(sql, Long.class);
            logger.info("查询结果: {}", userIds);
            if (userIds != null && !userIds.isEmpty()) {
                Long userId = userIds.get(0);
                logger.info("从user表查询到默认用户ID: {}", userId);
                return userId;
            }
            logger.warn("user表中没有找到任何用户");
        } catch (Exception e) {
            logger.error("查询user表默认用户ID失败", e);
        }
        return null;
    }

    /**
     * 查询知识图谱
     * 
     * @param id 知识图谱主键
     * @return 知识图谱
     */
    @Override
    public KnowledgeGraph selectKnowledgeGraphById(Long id)
    {
        return knowledgeGraphMapper.selectKnowledgeGraphById(id);
    }

    /**
     * 查询知识图谱列表
     * 
     * @param knowledgeGraph 知识图谱
     * @return 知识图谱
     */
    @Override
    public List<KnowledgeGraph> selectKnowledgeGraphList(KnowledgeGraph knowledgeGraph)
    {
        return knowledgeGraphMapper.selectKnowledgeGraphList(knowledgeGraph);
    }

    /**
     * 新增知识图谱
     * 
     * @param knowledgeGraph 知识图谱
     * @return 结果
     */
    @Override
    public int insertKnowledgeGraph(KnowledgeGraph knowledgeGraph)
    {
        knowledgeGraph.setCreateTime(DateUtils.getNowDate());
        return knowledgeGraphMapper.insertKnowledgeGraph(knowledgeGraph);
    }

    /**
     * 修改知识图谱
     * 
     * @param knowledgeGraph 知识图谱
     * @return 结果
     */
    @Override
    public int updateKnowledgeGraph(KnowledgeGraph knowledgeGraph)
    {
        knowledgeGraph.setUpdateTime(DateUtils.getNowDate());
        return knowledgeGraphMapper.updateKnowledgeGraph(knowledgeGraph);
    }

    /**
     * 批量删除知识图谱
     * 
     * @param ids 需要删除的知识图谱主键
     * @return 结果
     */
    @Override
    public int deleteKnowledgeGraphByIds(Long[] ids)
    {
        return knowledgeGraphMapper.deleteKnowledgeGraphByIds(ids);
    }

    /**
     * 删除知识图谱信息
     * 
     * @param id 知识图谱主键
     * @return 结果
     */
    @Override
    public int deleteKnowledgeGraphById(Long id)
    {
        return knowledgeGraphMapper.deleteKnowledgeGraphById(id);
    }

    @Override
    public void generateCourseGraph(Long courseId)
    {
        // 在主线程中获取用户ID，然后调用异步方法
        Long sysUserId = null;
        try {
            sysUserId = SecurityUtils.getUserId();
            logger.info("从SecurityUtils获取到sys_user ID: {}", sysUserId);
        } catch (Exception e) {
            logger.warn("无法获取当前用户ID：{}", e.getMessage());
        }

        // 将 sys_user ID 映射到 user 表的 ID
        Long creatorId = null;
        if (sysUserId != null) {
            creatorId = mapSysUserIdToUserId(sysUserId);
            if (creatorId == null) {
                logger.warn("sys_user ID={} 在user表中不存在，使用默认用户ID", sysUserId);
            }
        }

        // 如果映射失败或无法获取用户ID，使用默认用户ID
        if (creatorId == null) {
            logger.info("creatorId为null，开始查询默认用户ID...");
            creatorId = getDefaultCreatorId();
            logger.info("查询到默认用户ID: {}", creatorId);
        }
        logger.info("准备调用异步方法生成课程知识图谱，creatorId={}", creatorId);
        generateCourseGraph(courseId, creatorId);
    }

    @Override
    @Async("taskExecutor")
    public void generateCourseGraph(Long courseId, Long creatorId)
    {
        // 最小可用实现：从课程、课件、题目读取文本，调用 AI 抽取（占位），将结果保存为 KnowledgeGraph.graphData JSON
        try {
            StringBuilder sb = new StringBuilder();
            // 读取课程简介
            com.ruoyi.system.domain.Course course = courseService.selectCourseById(courseId);
            if (course != null) {
                if (course.getDescription() != null) sb.append(course.getDescription()).append("。\n");
                if (course.getTitle() != null) sb.append(course.getTitle()).append("。\n");
            }
            // 读取课程资源文本摘要
            com.ruoyi.system.domain.CourseResource qr = new com.ruoyi.system.domain.CourseResource();
            qr.setCourseId(courseId);
            java.util.List<com.ruoyi.system.domain.CourseResource> resources = courseResourceService.selectCourseResourceList(qr);
            for (com.ruoyi.system.domain.CourseResource r : resources) {
                if (r.getDescription() != null) sb.append(r.getDescription()).append("。\n");
                // CourseResource 使用 fileUrl 字段存放文件地址
                if (r.getFileUrl() != null) sb.append(r.getFileUrl()).append("。\n");
            }

            // 【新增】读取视频并批量抽取知识点和关系
            com.ruoyi.system.domain.Video videoQuery = new com.ruoyi.system.domain.Video();
            videoQuery.setCourseId(courseId);
            java.util.List<com.ruoyi.system.domain.Video> videos = videoService.selectVideoList(videoQuery);
            List<Map<String,Object>> allKps = new ArrayList<>();
            List<Map<String,Object>> allRelations = new ArrayList<>();

            logger.info("📹 课程 {} 共有 {} 个视频", courseId, videos.size());
            if (!videos.isEmpty()) {
                StringBuilder allVideosText = new StringBuilder();
                for (com.ruoyi.system.domain.Video video : videos) {
                    logger.info("📹 处理视频 ID={}, 标题={}, 路径={}",
                               video.getId(), video.getTitle(), video.getFilePath());

                    allVideosText.append("=== 视频 ").append(video.getId()).append(" ===\n");
                    allVideosText.append("【类型】视频内容\n");

                    // 使用视频转录服务提取文本
                    String videoText = videoTranscriptionService.extractTextFromVideo(
                        video.getFilePath(),
                        video.getTitle(),
                        video.getDescription()
                    );

                    logger.info("📹 视频 {} 提取文本长度: {} 字符", video.getId(), videoText != null ? videoText.length() : 0);
                    allVideosText.append(videoText).append("\n");
                }

                logger.info("📹 开始批量处理 {} 个视频，总文本长度: {} 字符", videos.size(), allVideosText.length());

                // 只有当文本长度足够时才调用AI
                if (allVideosText.length() > 50) {
                    logger.info("📹 调用AI抽取视频知识点...");
                    Map<String,Object> videoExtractResult = aiExtractionService.extractKnowledgePointsWithRelations(allVideosText.toString());
                    List<Map<String,Object>> videoKps = (List<Map<String,Object>>) videoExtractResult.get("candidates");
                    List<Map<String,Object>> videoRels = (List<Map<String,Object>>) videoExtractResult.get("relations");
                    if (videoKps != null) allKps.addAll(videoKps);
                    if (videoRels != null) allRelations.addAll(videoRels);
                    logger.info("📹 从视频AI抽取到 {} 个知识点，{} 条关系",
                               videoKps != null ? videoKps.size() : 0, videoRels != null ? videoRels.size() : 0);
                } else {
                    logger.warn("📹 视频文本内容太少（{}字符），跳过AI抽取", allVideosText.length());
                }
            } else {
                logger.warn("📹 课程 {} 没有视频数据", courseId);
            }

            // 读取题目并批量抽取知识点和关系
            com.ruoyi.system.domain.Question q = new com.ruoyi.system.domain.Question();
            q.setCourseId(courseId);
            java.util.List<com.ruoyi.system.domain.Question> questions = questionService.selectQuestionList(q);

            // 批量处理所有题目（一次性AI调用）
            if (!questions.isEmpty()) {
                StringBuilder allQuestionsText = new StringBuilder();
                for (com.ruoyi.system.domain.Question qu : questions) {
                    allQuestionsText.append("=== 题目 ").append(qu.getId()).append(" ===\n");
                    if (qu.getTitle() != null) allQuestionsText.append("题干: ").append(qu.getTitle()).append("\n");
                    if (qu.getCorrectAnswer() != null) allQuestionsText.append("答案: ").append(qu.getCorrectAnswer()).append("\n");
                    if (qu.getExplanation() != null) allQuestionsText.append("解析: ").append(qu.getExplanation()).append("\n");
                    if (qu.getOptions() != null) allQuestionsText.append("选项: ").append(qu.getOptions()).append("\n");
                    allQuestionsText.append("\n");
                }

                // 一次性调用AI处理所有题目
                logger.info("开始批量处理 {} 道题目", questions.size());
                Map<String,Object> extractResult = aiExtractionService.extractKnowledgePointsWithRelations(allQuestionsText.toString());
                List<Map<String,Object>> kps = (List<Map<String,Object>>) extractResult.get("candidates");
                List<Map<String,Object>> rels = (List<Map<String,Object>>) extractResult.get("relations");
                if (kps != null) allKps.addAll(kps);
                if (rels != null) allRelations.addAll(rels);
                logger.info("从题库AI抽取到 {} 个知识点，{} 条关系",
                           kps != null ? kps.size() : 0, rels != null ? rels.size() : 0);
            }

            logger.info("多源抽取完成：视频+题库共 {} 个知识点，{} 条关系", allKps.size(), allRelations.size());


            // 去重知识点（按 name 去重）
            Map<String, Map<String,Object>> kpMap = new LinkedHashMap<>();
            for (Map<String,Object> kp : allKps) {
                logger.info("AI返回的知识点数据：{}", kp); // 添加调试日志
                
                // AI可能返回 "title" 或 "name" 字段，都尝试获取
                String name = "";
                if (kp.containsKey("title")) {
                    name = kp.get("title").toString();
                } else if (kp.containsKey("name")) {
                    name = kp.get("name").toString();
                }
                name = name.trim();
                
                logger.info("提取的知识点名称：'{}'", name); // 添加调试日志
                
                if (!name.isEmpty() && !kpMap.containsKey(name)) {
                    // 统一使用 "name" 字段
                    Map<String,Object> normalizedKp = new HashMap<>(kp);
                    normalizedKp.put("name", name);
                    kpMap.put(name, normalizedKp);
                    logger.info("添加知识点到映射：{}", name);
                }
            }
            logger.info("去重后知识点数量：{}", kpMap.size());

            // 保存知识点到数据库，并建立 name -> id 的映射
            Map<String, Long> nameToIdMap = new HashMap<>();
            for (Map<String,Object> kpData : kpMap.values()) {
                com.ruoyi.system.domain.KnowledgePoint kp = new com.ruoyi.system.domain.KnowledgePoint();
                String kpName = kpData.getOrDefault("name", "").toString();
                kp.setTitle(kpName);
                kp.setDescription(kpData.getOrDefault("definition", "").toString());
                kp.setCourseId(courseId);

                // 使用传入的 creatorId，如果为空则查询默认用户ID
                Long finalCreatorId;
                if (creatorId != null) {
                    finalCreatorId = creatorId;
                    logger.debug("使用传入的creatorId: {}", creatorId);
                } else {
                    finalCreatorId = getDefaultCreatorId();
                    logger.debug("从user表查询到的creatorId: {}", finalCreatorId);
                }

                if (finalCreatorId == null) {
                    logger.error("无法获取有效的creatorId，跳过知识点创建：{}", kpName);
                    continue;
                }

                kp.setCreatorUserId(finalCreatorId);
                kp.setCreateTime(DateUtils.getNowDate());

                logger.info("准备插入知识点：{}, creatorId={}", kpName, finalCreatorId);
                knowledgePointService.insertKnowledgePoint(kp);
                nameToIdMap.put(kp.getTitle(), kp.getId());
            }

            // 保存知识点关系到数据库
            int savedRelations = 0;
            for (Map<String,Object> rel : allRelations) {
                String sourceName = rel.getOrDefault("source", "").toString();
                String targetName = rel.getOrDefault("target", "").toString();
                String relType = rel.getOrDefault("type", "related").toString();

                // 映射关系类型到数据库枚举值
                String mappedRelType = mapRelationType(relType);

                Long sourceId = nameToIdMap.get(sourceName);
                Long targetId = nameToIdMap.get(targetName);

                if (sourceId != null && targetId != null) {
                    com.ruoyi.system.domain.KpRelation kpRel = new com.ruoyi.system.domain.KpRelation();
                    kpRel.setFromKpId(sourceId);
                    kpRel.setToKpId(targetId);
                    kpRel.setRelationType(mappedRelType); // 使用映射后的值
                    kpRel.setAiGenerated(1);

                    kpRelationService.insertKpRelation(kpRel);
                    savedRelations++;
                    logger.info("保存知识点关系：{} -> {} (原始: {}, 映射: {})", 
                              sourceName, targetName, relType, mappedRelType);
                }
            }
            logger.info("课程 {} 共保存 {} 个知识点，{} 条关系", courseId, nameToIdMap.size(), savedRelations);

            // ========== 构造完整层级结构 graphData（课程→章节→小节→知识点） ==========
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            java.util.Map<String,Object> graph = new java.util.HashMap<>();
            java.util.List<java.util.Map<String,Object>> nodes = new java.util.ArrayList<>();
            java.util.List<java.util.Map<String,Object>> edges = new java.util.ArrayList<>();
            int edgeId = 1;

            // 定义章节颜色（10种颜色循环使用）
            String[] chapterColors = {"#5470c6", "#91cc75", "#fac858", "#ee6666", "#73c0de",
                                       "#9a60b4", "#ea7ccc", "#3ba272", "#fc8452", "#4876FF"};

            // 1. 添加课程节点（中心节点，最大）
            String courseTitle = course != null ? course.getTitle() : "课程_" + courseId;
            java.util.Map<String,Object> courseNode = new java.util.HashMap<>();
            courseNode.put("id", "course_" + courseId);
            courseNode.put("label", courseTitle);
            courseNode.put("nodeType", "course");
            courseNode.put("category", 0);
            courseNode.put("symbolSize", 70);
            nodes.add(courseNode);

            // 2. 查询课程下的所有章节
            com.ruoyi.system.domain.Chapter chapterQuery = new com.ruoyi.system.domain.Chapter();
            chapterQuery.setCourseId(courseId);
            List<com.ruoyi.system.domain.Chapter> chapters = chapterService.selectChapterList(chapterQuery);

            // 记录小节到章节的映射（用于知识点着色）
            Map<Long, Integer> sectionToChapterIndex = new HashMap<>();

            int chapterIndex = 0;
            for (com.ruoyi.system.domain.Chapter chapter : chapters) {
                String chapterNodeId = "chapter_" + chapter.getId();
                String chapterLabel = "第" + chapter.getSortOrder() + "章 " + chapter.getTitle();
                String color = chapterColors[chapterIndex % chapterColors.length];

                // 添加章节节点
                java.util.Map<String,Object> chapterNode = new java.util.HashMap<>();
                chapterNode.put("id", chapterNodeId);
                chapterNode.put("label", chapterLabel);
                chapterNode.put("nodeType", "chapter");
                chapterNode.put("category", chapterIndex + 1);
                chapterNode.put("chapterIndex", chapterIndex);
                chapterNode.put("color", color);
                chapterNode.put("symbolSize", 50);
                nodes.add(chapterNode);

                // 添加课程→章节的边
                java.util.Map<String,Object> courseToChapterEdge = new java.util.HashMap<>();
                courseToChapterEdge.put("id", "edge_" + edgeId++);
                courseToChapterEdge.put("source", "course_" + courseId);
                courseToChapterEdge.put("target", chapterNodeId);
                courseToChapterEdge.put("type", "CONTAINS");
                edges.add(courseToChapterEdge);

                // 3. 查询章节下的所有小节
                com.ruoyi.system.domain.Section sectionQuery = new com.ruoyi.system.domain.Section();
                sectionQuery.setChapterId(chapter.getId());
                List<com.ruoyi.system.domain.Section> sections = sectionService.selectSectionList(sectionQuery);

                for (com.ruoyi.system.domain.Section section : sections) {
                    String sectionNodeId = "section_" + section.getId();
                    String sectionLabel = section.getSortOrder() + "." + section.getTitle();
                    sectionToChapterIndex.put(section.getId(), chapterIndex);

                    // 添加小节节点
                    java.util.Map<String,Object> sectionNode = new java.util.HashMap<>();
                    sectionNode.put("id", sectionNodeId);
                    sectionNode.put("label", sectionLabel);
                    sectionNode.put("nodeType", "section");
                    sectionNode.put("category", chapterIndex + 1);
                    sectionNode.put("chapterIndex", chapterIndex);
                    sectionNode.put("color", color);
                    sectionNode.put("symbolSize", 35);
                    nodes.add(sectionNode);

                    // 添加章节→小节的边
                    java.util.Map<String,Object> chapterToSectionEdge = new java.util.HashMap<>();
                    chapterToSectionEdge.put("id", "edge_" + edgeId++);
                    chapterToSectionEdge.put("source", chapterNodeId);
                    chapterToSectionEdge.put("target", sectionNodeId);
                    chapterToSectionEdge.put("type", "CONTAINS");
                    edges.add(chapterToSectionEdge);
                }
                chapterIndex++;
            }

            // 4. 添加知识点节点并关联到小节
            // 首先查询小节-知识点关联
            com.ruoyi.system.domain.SectionKp sectionKpQuery = new com.ruoyi.system.domain.SectionKp();
            List<com.ruoyi.system.domain.SectionKp> sectionKpList = sectionKpMapper.selectSectionKpList(sectionKpQuery);
            Map<Long, Long> kpToSection = new HashMap<>();
            for (com.ruoyi.system.domain.SectionKp sk : sectionKpList) {
                kpToSection.put(sk.getKpId(), sk.getSectionId());
            }

            // 添加知识点节点
            for (Map.Entry<String, Long> entry : nameToIdMap.entrySet()) {
                String name = entry.getKey();
                Long kpId = entry.getValue();
                Map<String,Object> kpData = kpMap.get(name);

                // 获取所属小节和章节
                Long sectionId = kpToSection.get(kpId);
                int kpChapterIndex = sectionId != null && sectionToChapterIndex.containsKey(sectionId)
                    ? sectionToChapterIndex.get(sectionId) : 0;
                String kpColor = chapterColors[kpChapterIndex % chapterColors.length];

                java.util.Map<String,Object> kpNode = new java.util.HashMap<>();
                kpNode.put("id", "kp_" + kpId);
                kpNode.put("kpId", kpId);
                kpNode.put("label", name);
                kpNode.put("nodeType", "kp");
                kpNode.put("category", kpChapterIndex + 1);
                kpNode.put("chapterIndex", kpChapterIndex);
                kpNode.put("color", kpColor);
                kpNode.put("definition", kpData.getOrDefault("definition", ""));
                kpNode.put("symbolSize", 22);
                nodes.add(kpNode);

                // 添加小节→知识点的边
                if (sectionId != null) {
                    java.util.Map<String,Object> sectionToKpEdge = new java.util.HashMap<>();
                    sectionToKpEdge.put("id", "edge_" + edgeId++);
                    sectionToKpEdge.put("source", "section_" + sectionId);
                    sectionToKpEdge.put("target", "kp_" + kpId);
                    sectionToKpEdge.put("type", "COVERS");
                    edges.add(sectionToKpEdge);
                }
            }

            // 5. 添加知识点之间的关系边
            for (Map<String,Object> rel : allRelations) {
                String sourceName = rel.getOrDefault("source", "").toString();
                String targetName = rel.getOrDefault("target", "").toString();
                Long sourceId = nameToIdMap.get(sourceName);
                Long targetId = nameToIdMap.get(targetName);

                if (sourceId != null && targetId != null) {
                    java.util.Map<String,Object> edge = new java.util.HashMap<>();
                    edge.put("id", "edge_" + edgeId++);
                    edge.put("source", "kp_" + sourceId);
                    edge.put("target", "kp_" + targetId);
                    edge.put("type", rel.getOrDefault("type", "RELATED"));
                    edges.add(edge);
                }
            }

            graph.put("nodes", nodes);
            graph.put("edges", edges);

            String graphJson = mapper.writeValueAsString(graph);

             // 保存为 KnowledgeGraph 记录
            KnowledgeGraph kg = new KnowledgeGraph();
            kg.setTitle((course!=null?course.getTitle():"course_"+courseId) + " 知识图谱");
            kg.setDescription("自动生成的课程知识图谱（最小可用）");
            kg.setCourseId(courseId);
            kg.setGraphType("COURSE");
            kg.setGraphData(graphJson);
            kg.setStatus("active");
            // 使用传入的 creatorId，如果为空则查询默认用户ID
            if (creatorId != null) {
                kg.setCreatorId(creatorId);
            } else {
                Long defaultId = getDefaultCreatorId();
                if (defaultId != null) {
                    kg.setCreatorId(defaultId);
                    logger.info("使用默认用户ID: {}", defaultId);
                }
            }
            knowledgeGraphMapper.insertKnowledgeGraph(kg);
        } catch (Exception ex) {
            logger.error("生成课程知识图谱失败，courseId={}", courseId, ex);
        }
    }

    @Override
    public void generateChapterGraph(Long courseId, Long chapterId) {
        // 在主线程中获取用户ID，然后调用异步方法
        Long sysUserId = null;
        try {
            sysUserId = SecurityUtils.getUserId();
            logger.info("从SecurityUtils获取到sys_user ID: {}", sysUserId);
        } catch (Exception e) {
            logger.warn("无法获取当前用户ID：{}", e.getMessage());
        }

        // 将 sys_user ID 映射到 user 表的 ID
        Long creatorId = null;
        if (sysUserId != null) {
            creatorId = mapSysUserIdToUserId(sysUserId);
            if (creatorId == null) {
                logger.warn("sys_user ID={} 在user表中不存在，使用默认用户ID", sysUserId);
            }
        }

        // 如果映射失败或无法获取用户ID，使用默认用户ID
        if (creatorId == null) {
            logger.info("creatorId为null，开始查询默认用户ID...");
            creatorId = getDefaultCreatorId();
            logger.info("查询到默认用户ID: {}", creatorId);
        }
        logger.info("准备调用异步方法生成章节知识图谱，creatorId={}", creatorId);
        generateChapterGraph(courseId, chapterId, creatorId);
    }

    @Override
    @Async("taskExecutor")
    public void generateChapterGraph(Long courseId, Long chapterId, Long creatorId) {
        try {
            logger.info("开始生成章节知识图谱：courseId={}, chapterId={}, creatorId={}", courseId, chapterId, creatorId);

            // 获取章节信息（用于显示标题）
            com.ruoyi.system.domain.Chapter chapter = chapterService.selectChapterById(chapterId);
            if (chapter == null) {
                logger.warn("章节不存在：chapterId={}", chapterId);
                return;
            }
            Long chapterSortOrder = chapter.getSortOrder();
            String chapterTitle = chapter.getTitle();
            logger.info("章节信息：id={}, sortOrder={}, title={}", chapterId, chapterSortOrder, chapterTitle);

            // 收集所有知识点和关系
            List<Map<String,Object>> allKps = new ArrayList<>();
            List<Map<String,Object>> allRelations = new ArrayList<>();

            // 【新增】1. 处理视频数据
            // 通过VideoMapper的自定义方法查询章节的视频（通过section表关联）
            java.util.List<com.ruoyi.system.domain.Video> videos = videoMapper.selectVideosByChapterId(chapterId);
            logger.info("📹 章节 {} (sortOrder={}) 关联的视频数量：{}", chapterId, chapterSortOrder, videos.size());

            if (!videos.isEmpty()) {
                StringBuilder allVideosText = new StringBuilder();
                for (com.ruoyi.system.domain.Video video : videos) {
                    logger.info("📹 处理章节视频 ID={}, 标题={}, 路径={}",
                               video.getId(), video.getTitle(), video.getFilePath());

                    allVideosText.append("=== 视频 ").append(video.getId()).append(" ===\n");
                    allVideosText.append("【类型】视频内容\n");

                    // 使用视频转录服务提取文本
                    String videoText = videoTranscriptionService.extractTextFromVideo(
                        video.getFilePath(),
                        video.getTitle(),
                        video.getDescription()
                    );

                    logger.info("📹 章节视频 {} 提取文本长度: {} 字符", video.getId(), videoText != null ? videoText.length() : 0);
                    allVideosText.append(videoText).append("\n");
                }

                logger.info("📹 开始批量处理章节 {} 个视频，总文本长度: {} 字符", videos.size(), allVideosText.length());

                // 只有当文本长度足够时才调用AI
                if (allVideosText.length() > 50) {
                    logger.info("📹 调用AI抽取章节视频知识点...");
                    Map<String,Object> videoExtractResult = aiExtractionService.extractKnowledgePointsWithRelations(allVideosText.toString());
                    List<Map<String,Object>> videoKps = (List<Map<String,Object>>) videoExtractResult.get("candidates");
                    List<Map<String,Object>> videoRels = (List<Map<String,Object>>) videoExtractResult.get("relations");
                    if (videoKps != null) allKps.addAll(videoKps);
                    if (videoRels != null) allRelations.addAll(videoRels);
                    logger.info("📹 从章节视频AI抽取到 {} 个知识点，{} 条关系",
                               videoKps != null ? videoKps.size() : 0, videoRels != null ? videoRels.size() : 0);
                } else {
                    logger.warn("📹 章节视频文本内容太少（{}字符），跳过AI抽取", allVideosText.length());
                }
            } else {
                logger.warn("📹 章节 {} 没有关联的视频", chapterId);
            }

            // 2. 读取该章节的所有题目
            com.ruoyi.system.domain.Question q = new com.ruoyi.system.domain.Question();
            q.setCourseId(courseId);
            q.setChapterId(chapterId);
            java.util.List<com.ruoyi.system.domain.Question> questions = questionService.selectQuestionList(q);

            if (questions == null || questions.isEmpty()) {
                logger.warn("章节 {} 没有题目", chapterId);
                // 即使没有题目，也可能有视频数据，继续处理
            } else {
                // 检查已处理的题目，分离已处理和未处理的题目
                List<Long> processedQuestionIds = getProcessedQuestionIds(courseId, chapterId);
                List<com.ruoyi.system.domain.Question> unprocessedQuestions = new ArrayList<>();
                List<com.ruoyi.system.domain.Question> processedQuestions = new ArrayList<>();

                for (com.ruoyi.system.domain.Question question : questions) {
                    if (processedQuestionIds.contains(question.getId())) {
                        processedQuestions.add(question);
                    } else {
                        unprocessedQuestions.add(question);
                    }
                }

                logger.info("章节 {} 共 {} 道题目，其中 {} 道已处理，{} 道待处理",
                           chapterId, questions.size(), processedQuestions.size(), unprocessedQuestions.size());

                // 3. 获取已处理题目的知识点（直接关联，不重新生成）
                if (!processedQuestions.isEmpty()) {
                    List<Map<String,Object>> existingKps = getExistingKnowledgePoints(processedQuestions);
                    allKps.addAll(existingKps);
                    logger.info("从已处理题目中获取 {} 个现有知识点", existingKps.size());
                }

                // 4. 批量处理未处理的题目（一次性AI调用）
                if (!unprocessedQuestions.isEmpty()) {
                    logger.info("开始批量处理 {} 道未处理题目", unprocessedQuestions.size());

                    // 将所有未处理题目合并为一个文本，使用标准分隔符
                    StringBuilder allQuestionsText = new StringBuilder();
                    for (com.ruoyi.system.domain.Question qu : unprocessedQuestions) {
                        allQuestionsText.append("=== 题目 ").append(qu.getId()).append(" ===\n");
                        allQuestionsText.append("题干: ").append(qu.getTitle() != null ? qu.getTitle() : "").append("\n");
                        if (qu.getCorrectAnswer() != null) {
                            allQuestionsText.append("答案: ").append(qu.getCorrectAnswer()).append("\n");
                        }
                        if (qu.getExplanation() != null) {
                            allQuestionsText.append("解析: ").append(qu.getExplanation()).append("\n");
                        }
                        if (qu.getOptions() != null) {
                            allQuestionsText.append("选项: ").append(qu.getOptions()).append("\n");
                        }
                        allQuestionsText.append("\n");
                    }

                    // 一次性调用AI处理所有未处理题目，使用分隔符分隔题目，以便于提取每个题目的知识点和关系
                    Map<String,Object> extractResult = aiExtractionService.extractKnowledgePointsWithRelations(allQuestionsText.toString());
                    List<Map<String,Object>> newKps = (List<Map<String,Object>>) extractResult.get("candidates");
                    List<Map<String,Object>> newRelations = (List<Map<String,Object>>) extractResult.get("relations");

                    if (newKps != null) {
                        allKps.addAll(newKps);
                        logger.info("从题库AI批量抽取到 {} 个新知识点", newKps.size());
                    }
                    if (newRelations != null) {
                        allRelations.addAll(newRelations);
                        logger.info("从题库AI批量抽取到 {} 条新关系", newRelations.size());
                    }

                    // 标记这些题目为已处理
                    List<Long> newQuestionIds = unprocessedQuestions.stream()
                        .map(com.ruoyi.system.domain.Question::getId)
                        .collect(Collectors.toList());
                    markQuestionsAsProcessed(newQuestionIds, courseId, chapterId);
                }
            }

            logger.info("章节 {} 多源抽取完成：视频+题库共 {} 个知识点，{} 条关系", chapterId, allKps.size(), allRelations.size());

            // 如果没有提取到任何知识点，记录日志并返回
            if (allKps.isEmpty()) {
                logger.warn("章节 {} 没有提取到任何知识点（可能没有视频和题目），跳过知识图谱生成", chapterId);
                return;
            }

            // 去重知识点（基于名称）
            Map<String, Map<String,Object>> uniqueKps = new LinkedHashMap<>();
            for (Map<String,Object> kp : allKps) {
                // AI可能返回 "title" 或 "name" 字段，都尝试获取
                String name = "";
                if (kp.containsKey("title")) {
                    name = kp.get("title").toString();
                } else if (kp.containsKey("name")) {
                    name = kp.get("name").toString();
                }
                name = name.trim();

                if (!name.isEmpty() && !uniqueKps.containsKey(name)) {
                    // 统一使用 "name" 字段
                    Map<String,Object> normalizedKp = new HashMap<>(kp);
                    normalizedKp.put("name", name);
                    uniqueKps.put(name, normalizedKp);
                }
            }
            logger.info("去重后保留 {} 个唯一知识点", uniqueKps.size());

            // 保存知识点到数据库
            Map<String, Long> nameToIdMap = new HashMap<>();
            Map<String, Map<String,Object>> kpMap = new HashMap<>();
            
            for (Map.Entry<String, Map<String,Object>> entry : uniqueKps.entrySet()) {
                String name = entry.getKey();
                Map<String,Object> kpData = entry.getValue();
                
                // 检查是否已存在同名知识点
                Long existingKpId = findExistingKnowledgePointId(name, courseId);
                if (existingKpId != null) {
                    nameToIdMap.put(name, existingKpId);
                    kpMap.put(name, kpData);
                    logger.info("复用现有知识点：{} (ID: {})", name, existingKpId);
                } else {
                    // 创建新知识点
                    com.ruoyi.system.domain.KnowledgePoint kp = new com.ruoyi.system.domain.KnowledgePoint();
                    kp.setTitle(name);  // 使用 setTitle 而不是 setName
                    kp.setDescription(kpData.getOrDefault("definition", "").toString());
                    kp.setCourseId(courseId);
                    kp.setLevel("BASIC");
                    // 使用传入的 creatorId，如果为空则查询默认用户ID
                    Long finalCreatorId;
                    if (creatorId != null) {
                        finalCreatorId = creatorId;
                        logger.debug("使用传入的creatorId: {}", creatorId);
                    } else {
                        finalCreatorId = getDefaultCreatorId();
                        logger.debug("从user表查询到的creatorId: {}", finalCreatorId);
                    }

                    if (finalCreatorId == null) {
                        logger.error("无法获取有效的creatorId，跳过知识点创建：{}", name);
                        continue;
                    }

                    kp.setCreatorUserId(finalCreatorId);
                    logger.info("准备插入知识点：{}, creatorId={}", name, finalCreatorId);
                    knowledgePointService.insertKnowledgePoint(kp);
                    nameToIdMap.put(name, kp.getId());
                    kpMap.put(name, kpData);
                    logger.info("保存新知识点：{} (ID: {})", name, kp.getId());
                }
            }

            // 保存知识点关系到数据库
            int savedRelations = 0;
            for (Map<String,Object> rel : allRelations) {
                String sourceName = rel.getOrDefault("source", "").toString();
                String targetName = rel.getOrDefault("target", "").toString();
                String relType = rel.getOrDefault("type", "related").toString();

                // 映射关系类型到数据库枚举值
                String mappedRelType = mapRelationType(relType);

                Long sourceId = nameToIdMap.get(sourceName);
                Long targetId = nameToIdMap.get(targetName);

                if (sourceId != null && targetId != null) {
                    logger.info("准备保存关系：{} -> {}，原始类型={}，映射后类型={}", sourceName, targetName, relType, mappedRelType);

                    // 检查关系是否已存在
                    if (!relationExists(sourceId, targetId, mappedRelType)) {
                        com.ruoyi.system.domain.KpRelation kpRel = new com.ruoyi.system.domain.KpRelation();
                        kpRel.setFromKpId(sourceId);
                        kpRel.setToKpId(targetId);
                        kpRel.setRelationType(mappedRelType);
                        kpRel.setAiGenerated(1);

                        try {
                            kpRelationService.insertKpRelation(kpRel);
                            savedRelations++;
                            logger.info("保存知识点关系成功：{} -> {} (类型: {})", sourceName, targetName, mappedRelType);
                        } catch (Exception e) {
                            logger.error("保存关系失败：{} -> {} ({}), 错误：{}", sourceName, targetName, mappedRelType, e.getMessage());
                            // 打印详细的异常堆栈，帮助调试
                            e.printStackTrace();
                        }
                    } else {
                        logger.debug("关系已存在，跳过：{} -> {} (类型: {})", sourceName, targetName, mappedRelType);
                    }
                }
            }
            logger.info("章节 {} 共保存 {} 个知识点，{} 条关系", chapterId, nameToIdMap.size(), savedRelations);

            // 构造 graphData（用于前端可视化）
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            java.util.Map<String,Object> graph = new java.util.HashMap<>();
            java.util.List<java.util.Map<String,Object>> nodes = new java.util.ArrayList<>();
            java.util.List<java.util.Map<String,Object>> edges = new java.util.ArrayList<>();

            // 构造节点（包含level字段用于前端分组着色）
            for (Map.Entry<String, Long> entry : nameToIdMap.entrySet()) {
                String name = entry.getKey();
                Long kpId = entry.getValue();
                Map<String,Object> kpData = kpMap.get(name);

                // 查询知识点的level
                com.ruoyi.system.domain.KnowledgePoint kp = knowledgePointService.selectKnowledgePointById(kpId);
                String level = (kp != null && kp.getLevel() != null) ? kp.getLevel() : "BASIC";

                java.util.Map<String,Object> node = new java.util.HashMap<>();
                node.put("id", "kp_" + kpId);
                node.put("kpId", kpId);
                node.put("label", name);
                node.put("definition", kpData.getOrDefault("definition", ""));
                node.put("confidence", kpData.getOrDefault("confidence", 0.0));
                node.put("level", level);
                nodes.add(node);
            }

            // 构造边
            int edgeId = 1;
            for (Map<String,Object> rel : allRelations) {
                String sourceName = rel.getOrDefault("source", "").toString();
                String targetName = rel.getOrDefault("target", "").toString();
                Long sourceId = nameToIdMap.get(sourceName);
                Long targetId = nameToIdMap.get(targetName);

                if (sourceId != null && targetId != null) {
                    java.util.Map<String,Object> edge = new java.util.HashMap<>();
                    edge.put("id", "edge_" + edgeId++);
                    edge.put("source", "kp_" + sourceId);
                    edge.put("target", "kp_" + targetId);
                    edge.put("type", rel.getOrDefault("type", "related"));
                    edge.put("confidence", rel.getOrDefault("confidence", 0.0));
                    edges.add(edge);
                }
            }

            graph.put("nodes", nodes);
            graph.put("edges", edges);
            // 【新增】在 graph_data 中存储 chapterId，用于前端过滤
            graph.put("chapterId", chapterId);
            graph.put("chapterSortOrder", chapterSortOrder);
            graph.put("chapterTitle", chapterTitle);

            String graphJson = mapper.writeValueAsString(graph);

            // 保存为 KnowledgeGraph 记录
            KnowledgeGraph kg = new KnowledgeGraph();
            // 使用 sortOrder 作为章节序号显示
            kg.setTitle("第" + chapterSortOrder + "章 " + chapterTitle + " 知识图谱");
            kg.setDescription("自动生成的章节知识图谱（从视频+题库抽取）");
            kg.setCourseId(courseId);
            kg.setGraphType("CHAPTER");
            kg.setGraphData(graphJson);
            kg.setStatus("active");
            // 使用传入的 creatorId，如果为空则查询默认用户ID
            if (creatorId != null) {
                kg.setCreatorId(creatorId);
            } else {
                Long defaultId = getDefaultCreatorId();
                if (defaultId != null) {
                    kg.setCreatorId(defaultId);
                    logger.info("使用默认用户ID: {}", defaultId);
                }
            }
            knowledgeGraphMapper.insertKnowledgeGraph(kg);
            logger.info("章节知识图谱生成完成：courseId={}, chapterId={}, sortOrder={}, title={}, graphId={}",
                courseId, chapterId, chapterSortOrder, chapterTitle, kg.getId());
        } catch (Exception ex) {
            logger.error("生成章节知识图谱失败，courseId={}, chapterId={}", courseId, chapterId, ex);
        }
    }

    /**
     * 获取已处理过的题目ID列表
     */
    private List<Long> getProcessedQuestionIds(Long courseId, Long chapterId) {
        try {
            // 查询该课程章节下所有题目，然后过滤出已有知识点的题目
            List<com.ruoyi.system.domain.Question> allQuestions = questionService.selectQuestionList(new com.ruoyi.system.domain.Question());
            return allQuestions.stream()
                .filter(q -> q.getCourseId().equals(courseId) && 
                            q.getChapterId().equals(chapterId) && 
                            q.getKnowledgePoint() != null && 
                            !q.getKnowledgePoint().trim().isEmpty())
                .map(com.ruoyi.system.domain.Question::getId)
                .collect(Collectors.toList());
        } catch (Exception e) {
            logger.warn("获取已处理题目列表失败：{}", e.getMessage());
            return new ArrayList<>();
        }
    }

    /**
     * 获取已处理题目的现有知识点
     */
    private List<Map<String,Object>> getExistingKnowledgePoints(List<com.ruoyi.system.domain.Question> processedQuestions) {
        List<Map<String,Object>> existingKps = new ArrayList<>();
        
        for (com.ruoyi.system.domain.Question question : processedQuestions) {
            if (question.getKnowledgePoint() != null && !question.getKnowledgePoint().trim().isEmpty()) {
                // 根据题目的knowledge_point字段查找对应的知识点
                com.ruoyi.system.domain.KnowledgePoint searchKp = new com.ruoyi.system.domain.KnowledgePoint();
                searchKp.setCourseId(question.getCourseId());
                searchKp.setTitle(question.getKnowledgePoint());
                List<com.ruoyi.system.domain.KnowledgePoint> kps = knowledgePointService.selectKnowledgePointList(searchKp);
                
                for (com.ruoyi.system.domain.KnowledgePoint kp : kps) {
                    Map<String,Object> kpData = new HashMap<>();
                    kpData.put("name", kp.getTitle());
                    kpData.put("definition", kp.getDescription());
                    kpData.put("confidence", 1.0);
                    existingKps.add(kpData);
                }
            }
        }
        
        return existingKps;
    }

    /**
     * 查找现有知识点ID
     */
    private Long findExistingKnowledgePointId(String name, Long courseId) {
        try {
            com.ruoyi.system.domain.KnowledgePoint searchKp = new com.ruoyi.system.domain.KnowledgePoint();
            searchKp.setTitle(name);
            searchKp.setCourseId(courseId);
            List<com.ruoyi.system.domain.KnowledgePoint> existingKps = knowledgePointService.selectKnowledgePointList(searchKp);
            return existingKps.isEmpty() ? null : existingKps.get(0).getId();
        } catch (Exception e) {
            logger.debug("查找现有知识点失败：{}", e.getMessage());
            return null;
        }
    }

    /**
     * 检查关系是否已存在
     */
    private boolean relationExists(Long sourceId, Long targetId, String relationType) {
        try {
            com.ruoyi.system.domain.KpRelation searchRelation = new com.ruoyi.system.domain.KpRelation();
            searchRelation.setFromKpId(sourceId);
            searchRelation.setToKpId(targetId);
            searchRelation.setRelationType(relationType);
            List<com.ruoyi.system.domain.KpRelation> existingRelations = kpRelationService.selectKpRelationList(searchRelation);
            return !existingRelations.isEmpty();
        } catch (Exception e) {
            logger.debug("检查关系是否存在失败：{}", e.getMessage());
            return false;
        }
    }

    /**
     * 映射 AI 返回的关系类型到数据库枚举值
     * 数据库ENUM值：prerequisite_of, similar_to, extension_of, derived_from, counterexample_of
     */
    private String mapRelationType(String type) {
        if (type == null) return "similar_to";
        type = type.toLowerCase().trim();

        // 直接匹配数据库ENUM值
        if (VALID_RELATION_TYPES.contains(type)) {
            return type;
        }

        // 前置关系映射 -> prerequisite_of
        if (type.contains("prerequisite") || type.contains("前置") || type.contains("基础") ||
            type.contains("depends") || type.contains("依赖")) {
            return "prerequisite_of";
        }

        // 推导关系映射 -> derived_from
        if (type.contains("derived") || type.contains("推导") || type.contains("衍生") ||
            type.contains("belongs") || type.contains("从属") || type.contains("属于")) {
            return "derived_from";
        }

        // 扩展关系映射 -> extension_of
        if (type.contains("extension") || type.contains("扩展") || type.contains("进阶") ||
            type.contains("advanced") || type.contains("深化")) {
            return "extension_of";
        }

        // 反例关系映射 -> counterexample_of
        if (type.contains("counterexample") || type.contains("反例") || type.contains("对比") ||
            type.contains("counter") || type.contains("opposite")) {
            return "counterexample_of";
        }

        // 相似关系映射 -> similar_to (默认值)
        if (type.contains("similar") || type.contains("相似") || type.contains("类似") ||
            type.contains("related") || type.contains("相关") || type.contains("uses") ||
            type.contains("应用") || type.contains("使用") || type.contains("example") ||
            type.contains("示例") || type.contains("实例")) {
            return "similar_to";
        }

        logger.warn("未识别的关系类型：{}，使用默认值 similar_to", type);
        return "similar_to"; // 默认为相似关系
    }

    /**
     * 标记题目为已处理（通过更新题目的knowledge_point字段或其他标识）
     */
    private void markQuestionsAsProcessed(List<Long> questionIds, Long courseId, Long chapterId) {
        try {
            // 由于题目已经通过AI处理并生成了知识点，这里可以简单记录日志
            // 实际的"已处理"状态通过题目是否有knowledge_point字段来判断
            logger.info("标记 {} 道题目为已处理：courseId={}, chapterId={}, questionIds={}",
                       questionIds.size(), courseId, chapterId, questionIds);

            // 如果需要额外的标记逻辑，可以在这里添加
            // 例如：更新题目的某个状态字段，或者插入处理记录表等

        } catch (Exception e) {
            logger.warn("标记题目为已处理失败：{}", e.getMessage());
        }
    }

}
