package com.ruoyi.system.service.impl;

import com.alibaba.dashscope.aigc.generation.Generation;
import com.alibaba.dashscope.aigc.generation.GenerationParam;
import com.alibaba.dashscope.aigc.generation.GenerationResult;
import com.alibaba.dashscope.common.Message;
import com.alibaba.dashscope.common.Role;
import com.alibaba.dashscope.exception.ApiException;
import com.alibaba.dashscope.exception.InputRequiredException;
import com.alibaba.dashscope.exception.NoApiKeyException;
import com.alibaba.fastjson2.JSON;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.Assignment;
import com.ruoyi.system.domain.KnowledgePoint;
import com.ruoyi.system.domain.PersonalizedRecommendation;
import com.ruoyi.system.domain.vo.AiRecommendResultVo;
import com.ruoyi.system.domain.vo.KpResourceVo;
import com.ruoyi.system.domain.vo.PersonalizedRecommendItemVo;
import com.ruoyi.system.domain.vo.QuestionKpRelationVo;
import com.ruoyi.system.domain.vo.StudentLearnStatusVo;
import com.ruoyi.system.mapper.*;
import com.ruoyi.system.service.IAiRecommendService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
@Slf4j
public class AiRecommendServiceImpl implements IAiRecommendService {

    @Autowired
    private StudentKpMasteryMapper studentKpMasteryMapper;
    @Autowired
    private SectionKpMapper sectionKpMapper;
    @Autowired
    private StudentAnswerMapper studentAnswerMapper;
    @Autowired
    private AssignmentQuestionMapper assignmentQuestionMapper;
    @Autowired
    private PersonalizedRecommendationMapper recommendationMapper;
    @Autowired
    private AssignmentMapper assignmentMapper;
    @Autowired
    private KnowledgePointMapper knowledgePointMapper;
    // 通义千问配置
    @Value("${tongyi.qianwen.model:qwen-turbo}")
    private String aiModelVersion;
    @Value("${tongyi.qianwen.timeout:30000}")
    private int timeout;

    @Override
    public String generateModelInput(Long studentUserId, Long courseId) {
        return "此方法已被废弃，请使用带参数的generateModelInput";
    }

    // 重载方法：接收已经查好的数据，避免重复查询，同时方便加日志
    private String generateModelInput(Long studentUserId, Long courseId,
                                      List<StudentLearnStatusVo> learnStatusList,
                                      List<QuestionKpRelationVo> questionRelationList,
                                      List<KpResourceVo> resourceList) {

        // 修复：作业名称/ID获取逻辑（支持多个作业）
        Set<Long> assignmentIdSet = new HashSet<>();
        Map<Long, String> assignmentNameMap = new HashMap<>();
        if (CollectionUtils.isNotEmpty(learnStatusList)) {
            learnStatusList.forEach(status -> {
                if (status != null && status.getAssignmentId() != null) {
                    assignmentIdSet.add(status.getAssignmentId());
                }
            });
        }
        if (CollectionUtils.isNotEmpty(questionRelationList)) {
            questionRelationList.forEach(relation -> {
                if (relation != null && relation.getAssignmentId() != null) {
                    assignmentIdSet.add(relation.getAssignmentId());
                }
            });
        }
        // 批量查询作业名称（优化性能）
        assignmentIdSet.forEach(assId -> {
            Assignment assignment = assignmentMapper.selectAssignmentById(assId);
            assignmentNameMap.put(assId, assignment != null ? assignment.getTitle() : "未知作业");
        });

        StringBuilder input = new StringBuilder();

        input.append("【学生学习状态数据】\n");
        input.append("学生ID=").append(studentUserId)
                .append("，课程ID=").append(courseId)
                .append("，关联作业=").append(assignmentNameMap.values().stream().collect(Collectors.joining("、")))
                .append("（作业ID=").append(assignmentIdSet.stream().map(String::valueOf).collect(Collectors.joining(","))).append("）\n");
        if (CollectionUtils.isEmpty(learnStatusList)) {
            input.append("暂无学生知识点掌握状态数据（可能未做相关作业/测试）\n");
        } else {
            for (StudentLearnStatusVo status : learnStatusList) {
                if (status == null) continue;
                Long kpId = status.getKpId() == null ? -1 : status.getKpId();
                String kpTitle = status.getKpTitle() == null ? "未知知识点" : status.getKpTitle();
                String masteryStatus = status.getMasteryStatus() == null ? "未定义" : status.getMasteryStatus();
                String accuracy = status.getAccuracy() == null ? "0.00" : status.getAccuracy();
                Long assId = status.getAssignmentId() == null ? -1 : status.getAssignmentId();
                String wrongQues = status.getWrongQuestionNo() == null ? "无" : status.getWrongQuestionNo();
                String assignmentName = assignmentNameMap.getOrDefault(assId, "未知作业");

                input.append("1. 知识点ID=").append(kpId)
                        .append("，名称=").append(kpTitle)
                        .append("，掌握状态=").append(masteryStatus)
                        .append("，准确率=").append(accuracy)
                        .append("，关联作业=").append(assignmentName)
                        .append("（作业ID=").append(assId == -1 ? "无" : assId).append("）")
                        .append("，答错题目=").append(wrongQues).append("\n");
            }
        }

        input.append("\n【知识点-学习资源关联数据】\n");
        if (CollectionUtils.isEmpty(resourceList)) {
            input.append("暂无知识点关联的学习资源数据\n");
        } else {
            for (KpResourceVo resource : resourceList) {
                if (resource == null) continue;
                Long kpId = resource.getKpId() == null ? -1 : resource.getKpId();
                String kpTitle = resource.getKpTitle() == null ? "未知知识点" : resource.getKpTitle();
                String chapterTitle = resource.getChapterTitle() == null ? "未知章节" : resource.getChapterTitle();
                String sectionTitle = resource.getSectionTitle() == null ? "未知小节" : resource.getSectionTitle();
                String coreKnowledge = resource.getCoreKnowledge() == null ? "暂无" : resource.getCoreKnowledge();

                String videoLocation = String.format("【%s】%s", chapterTitle, sectionTitle);

                input.append("1. 知识点ID=").append(kpId).append("（").append(kpTitle).append("）\n")
                        .append("   - 对应章节-小节：").append(videoLocation).append("\n")
                        .append("   - 核心考点：").append(coreKnowledge).append("\n");
            }
        }

        // 关键日志3：组装AI输入前验证错题数据
        log.info("传入AI的作业-知识点-题目关联数据总数：{}", questionRelationList.size());
        input.append("\n【作业题目-知识点关联数据】\n");
        if (CollectionUtils.isEmpty(questionRelationList)) {
            input.append("无（无法提取对应错题）\n");
            log.warn("传入AI的关联数据为空，AI无法生成错题！");
        } else {
            // 按作业分组展示（避免混乱）
            Map<Long, List<QuestionKpRelationVo>> assRelationMap = questionRelationList.stream()
                    .filter(Objects::nonNull)
                    .collect(Collectors.groupingBy(QuestionKpRelationVo::getAssignmentId));

            for (Map.Entry<Long, List<QuestionKpRelationVo>> entry : assRelationMap.entrySet()) {
                Long assId = entry.getKey();
                String assName = assignmentNameMap.getOrDefault(assId, "未知作业");
                input.append("作业名称=").append(assName)
                        .append("（作业ID=").append(assId).append("）\n");

                entry.getValue().forEach(relation -> {
                    if (relation == null) return;
                    List<String> kpTitleList = new ArrayList<>();
                    if (StringUtils.isNotBlank(relation.getKpIds())) {
                        kpTitleList = Arrays.stream(relation.getKpIds().split(","))
                                .map(String::trim)
                                .filter(StringUtils::isNotBlank)
                                .map(kpId -> {
                                    // 补充知识点名称（从缓存获取）
                                    KnowledgePoint kp = knowledgePointMapper.selectKnowledgePointById(Long.parseLong(kpId));
                                    return kp != null ? kp.getTitle() : "未知知识点";
                                })
                                .collect(Collectors.toList());
                    }
                    String kpTitleStr = CollectionUtils.isEmpty(kpTitleList) ? "无" : String.join("、", kpTitleList);
                    Integer questionSeq = relation.getQuestionSequence() == null ? -1 : relation.getQuestionSequence();

                    input.append("   1. 第").append(questionSeq == -1 ? "未知" : questionSeq).append("题")
                            .append(" (题目ID:").append(relation.getQuestionId() == null ? "无" : relation.getQuestionId()).append(")")
                            .append(" → 关联知识点IDs：").append(relation.getKpIds() == null ? "无" : relation.getKpIds())
                            .append(" (名称：").append(kpTitleStr).append(")\n");
                });
            }
            // 打印前5条示例到日志
            log.info("传入AI的关联数据示例（前5条）：{}",
                    JSON.toJSONString(questionRelationList.subList(0, Math.min(5, questionRelationList.size()))));
        }

        input.append("\n【推荐规则说明】\n")
                .append("===== 核心原则：必须严格按以下规则+样板生成，任何违规均视为无效推荐 =====\n")
                .append("1. 学习优先级：掌握状态weak > learning > mastered > unlearned；同状态下准确率越低越优先，每个知识点仅推荐1次（禁止重复）\n")
                .append("2. 必含字段：每个知识点必须包含「知识点ID+名称」「推荐动作」「视频位置」「重点关注内容」「对应错题」「执行建议」，缺一项即无效\n")
                .append("3. 数据来源：所有字段必须来自提供的【学生学习状态数据】【知识点-学习资源关联数据】【作业题目-知识点关联数据】，禁止编造、遗漏\n")
                .append("   - 对应错题：仅推荐当前知识点ID在【作业题目-知识点关联数据】中明确关联的题目序号，且该题目必须是学生的错题（来自【学生学习状态数据】）；无则写“无”，禁止刻意省略或添加无关联题目！\n")
                .append("   - 视频位置：从【知识点-学习资源关联数据】中提取「【xx章节】xx小节」，禁止写“无”（除非无章节信息）\n")
                .append("   - 重点关注内容：必须包含「【xx章节】xx小节+核心考点」，禁止无意义表述\n")
                .append("4. 格式要求：严格按以下样板的结构、符号、顺序生成，逐字模仿（包括顿号、破折号、括号格式）\n")
                .append("5. 禁止内容：\n")
                .append("   - 禁止###、##等层级符号，禁止后端字段类型（String/Integer）、状态（pending）、模型名（qwen-turbo）等垃圾数据\n")
                .append("   - 关联知识点&目标ID：仅保留数字+英文逗号，紧跟执行建议后（格式：“关联知识点：XXX 目标ID：XXX”）\n")
                .append("   - 末尾标记：【类型：xxx】【目标ID：xxx】【关联知识点：xxx】（仅数字+英文逗号）\n")
                .append("\n【输出样板（必须完全模仿，不能变更任何格式）】\n")
                .append("1、知识点ID=4005（等价无穷小）\n")
                .append("- 推荐动作：复习等价无穷小替换技巧，提升解题准确率\n")
                .append("- 视频位置：【1.极限】等价无穷小\n")
                .append("- 重点关注内容：【1.极限】等价无穷小 等价无穷小替换技巧\n")
                .append("- 对应错题：作业《第二章 函数综合测试》（ID：4004）第5题、第8题、第10题\n")
                .append("- 执行建议：加强对等价无穷小的应用方法，尤其是结合极限计算 关联知识点：4005,4010 目标ID：4004,4006\n")
                .append("【类型：resource】【目标ID：4004,4006】【关联知识点：4005,4010】\n")
                .append("\n3、知识点ID=4032（反函数的图像对称性）\n")
                .append("- 推荐动作：观看视频，理解反函数与原函数图像的对称关系\n")
                .append("- 视频位置：【2.函数】函数的应用\n")
                .append("- 重点关注内容：【2.函数】函数的应用 反函数的图像对称性原理\n")
                .append("- 对应错题：无\n")
                .append("- 执行建议：通过视频学习对称性质，配合例题加深理解 关联知识点：4032,4005 目标ID：4004,4015\n")
                .append("【类型：video】【目标ID：4004,4015】【关联知识点：4032,4005】\n")
                .append("\n【总结建议样板】\n")
                .append("总结建议：\n")
                .append("针对“等价无穷小（4005）”“反函数的图像对称性（4032）”等薄弱知识点，建议优先观看视频掌握核心概念，再通过对应错题和习题强化训练；“极限的唯一性（4010）”需重点巩固解题技巧，提升准确率。\n")
                .append("\n===== 要求：生成结果必须和样板格式100%一致，否则视为无效！ =====\n");
        return input.toString();
    }

    @Override
    public AiRecommendResultVo getRecommendResult(Long studentUserId, Long courseId) {
        AiRecommendResultVo resultVo = new AiRecommendResultVo();
        try {
            // 关键日志1：验证基础数据查询情况
            // 1. 查询题目关联数据
            List<QuestionKpRelationVo> questionRelationList = getQuestionKpRelationList(studentUserId, courseId);
            log.info("查询到课程{}的作业-知识点-题目关联数据总数：{}", courseId, questionRelationList.size());
            if (!CollectionUtils.isEmpty(questionRelationList)) {
                log.info("关联数据前3条示例：{}", JSON.toJSONString(questionRelationList.subList(0, Math.min(3, questionRelationList.size()))));
            } else {
                log.error("警告：课程{}未查询到任何作业-知识点-题目关联数据，无法生成错题！", courseId);
            }

            // 3. 查询学生学习状态（用于复用或日志）
            List<StudentLearnStatusVo> learnStatusList = studentKpMasteryMapper.selectStudentLearnStatus(studentUserId, courseId);
            log.info("查询到学生{}在课程{}的学习状态数据总数：{}", studentUserId, courseId, learnStatusList.size());
            // 打印学习状态中的错题字段，看是否本身就为空
            learnStatusList.forEach(status -> {
                if (status != null && StringUtils.isNotBlank(status.getWrongQuestionNo()) && !"无".equals(status.getWrongQuestionNo())) {
                    log.info("知识点ID：{}，答错题目字段原值：{}", status.getKpId(), status.getWrongQuestionNo());
                }
            });
            // 4. 学习资源
            List<KpResourceVo> resourceList = sectionKpMapper.selectKpResourceByCourseId(courseId);
            // 修正后（直接用当前方法里已有的参数）：
            Map<String, String> kpNameMap = buildKpIdToNameMap(studentUserId, courseId, learnStatusList, resourceList);


            // --- 分支逻辑开始 ---
            // 第一步：检查数据库缓存
            List<PersonalizedRecommendation> existingRecs = recommendationMapper.selectValidRecommendations(studentUserId, courseId);
            if (CollectionUtils.isNotEmpty(existingRecs)) {
                log.info("数据库中存在{}条有效推荐，直接返回", existingRecs.size());
                // 修复：传入learnStatusList参数
                String existingRecContent = assembleExistingRecommendations(existingRecs, questionRelationList, kpNameMap, learnStatusList);
                resultVo.setRecommendContent(existingRecContent);
                resultVo.setAvatarStatus("completed");

                // 修复：转换ItemVo时传入learnStatusList
                List<PersonalizedRecommendItemVo> itemVoList = existingRecs.stream()
                        .map(rec -> convertToItemVo(rec, questionRelationList, kpNameMap, learnStatusList))
                        .collect(Collectors.toList());
                resultVo.setRecommendItemList(itemVoList);
                return resultVo;
            }

            // 第二步：调用大模型
            log.info("数据库无有效推荐，调用大模型生成");
            // 使用重载方法，传入所有数据，确保日志和Prompt生成逻辑一致
            String modelInput = generateModelInput(studentUserId, courseId, learnStatusList, questionRelationList, resourceList);
            String recommendContent = callTongyiQianwenByApiKey(modelInput);

            resultVo.setRecommendContent(recommendContent);
            resultVo.setAvatarStatus("completed");
            resultVo.setModelInput(modelInput);

            // 第三步：解析结果并入库
            // 修复：传入learnStatusList参数
            List<PersonalizedRecommendation> recommendationList = parseRecommendContent(studentUserId, courseId, recommendContent, questionRelationList, learnStatusList);
            if (CollectionUtils.isNotEmpty(recommendationList)) {
                List<PersonalizedRecommendation> uniqueRecList = filterDuplicateRecommendations(recommendationList);
                if (CollectionUtils.isNotEmpty(uniqueRecList)) {
                    String batchId = UUID.randomUUID().toString().replace("-", "");
                    uniqueRecList.forEach(rec -> rec.setBatchId(batchId));
                    recommendationMapper.insertPersonalizedRecommendationBatch(uniqueRecList);
                    log.info("推荐入库成功：{}条", uniqueRecList.size());

                    // 修复：转换ItemVo时传入learnStatusList
                    List<PersonalizedRecommendItemVo> itemVoList = uniqueRecList.stream()
                            .map(rec -> convertToItemVo(rec, questionRelationList, kpNameMap, learnStatusList))
                            .collect(Collectors.toList());
                    resultVo.setRecommendItemList(itemVoList);
                } else {
                    resultVo.setRecommendItemList(new ArrayList<>());
                }
            } else {
                resultVo.setRecommendItemList(new ArrayList<>());
            }

        } catch (NoApiKeyException e) {
            log.error("大模型认证失败", e);
            resultVo.setRecommendContent("推荐失败：API-Key无效");
            resultVo.setAvatarStatus("error");
            resultVo.setRecommendItemList(new ArrayList<>());
        } catch (Exception e) {
            log.error("个性化推荐整体失败", e);
            resultVo.setRecommendContent("推荐失败：" + e.getMessage());
            resultVo.setAvatarStatus("error");
            resultVo.setRecommendItemList(new ArrayList<>());
        }
        return resultVo;
    }

    /**
     * 构建知识点ID→名称映射（全量查询，缓存复用）
     */
    /**
     * 构建知识点ID→名称映射（仅基于已有查询结果，不依赖额外Mapper方法）
     */
    private Map<String, String> buildKpIdToNameMap(Long studentUserId, Long courseId,
                                                   List<StudentLearnStatusVo> learnStatusList,
                                                   List<KpResourceVo> resourceList) {
        Map<String, String> map = new HashMap<>();

        // 1. 从学生学习状态数据中提取知识点
        if (CollectionUtils.isNotEmpty(learnStatusList)) {
            learnStatusList.forEach(status -> {
                if (status != null && status.getKpId() != null && StringUtils.isNotBlank(status.getKpTitle())) {
                    map.put(String.valueOf(status.getKpId()), status.getKpTitle());
                    log.debug("从学习状态添加知识点映射：ID={}, 名称={}", status.getKpId(), status.getKpTitle());
                }
            });
        }

        // 2. 从资源数据中提取知识点（补充学习状态中没有的）
        if (CollectionUtils.isNotEmpty(resourceList)) {
            resourceList.forEach(resource -> {
                if (resource != null && resource.getKpId() != null && StringUtils.isNotBlank(resource.getKpTitle())) {
                    // 仅添加映射中没有的，避免覆盖
                    map.putIfAbsent(String.valueOf(resource.getKpId()), resource.getKpTitle());
                    log.debug("从资源数据添加知识点映射：ID={}, 名称={}", resource.getKpId(), resource.getKpTitle());
                }
            });
        }

        log.info("知识点ID-名称映射构建完成，共{}条数据（仅基于已有查询结果）", map.size());
        return map;
    }

    private List<QuestionKpRelationVo> getQuestionKpRelationList(Long studentUserId, Long courseId) {
        List<QuestionKpRelationVo> questionRelationList = new ArrayList<>();

        // 1. 第一步：查询学生在该课程下实际答题的所有作业ID（去重）
        List<Long> studentAssignmentIds = studentAnswerMapper.selectDistinctAssignmentIdsByStudentAndCourse(studentUserId, courseId);
        log.info("学生{}在课程{}实际答题的作业ID：{}", studentUserId, courseId, studentAssignmentIds);

        // 若学生没有答题记录，返回空
        if (CollectionUtils.isEmpty(studentAssignmentIds)) {
            log.warn("学生{}在课程{}无答题记录，无法查询关联数据", studentUserId, courseId);
            return questionRelationList;
        }

        // 2. 第二步：查询这些作业ID对应的「题目-知识点关联数据」（精准查询，不查无关作业）
        Map<String, Object> params = new HashMap<>();
        params.put("courseId", courseId);
        params.put("assignmentIds", studentAssignmentIds); // 只查学生实际答题的作业
        questionRelationList = assignmentQuestionMapper.selectQuestionKpRelationByAssignmentIdsAndCourse(params);

        // 3. 补充作业名称（批量查询，优化性能）
        if (CollectionUtils.isNotEmpty(questionRelationList)) {
            Map<Long, String> assignmentNameMap = new HashMap<>();
            studentAssignmentIds.forEach(assId -> {
                Assignment assignment = assignmentMapper.selectAssignmentById(assId);
                assignmentNameMap.put(assId, assignment != null ? assignment.getTitle() : "未知作业");
            });
            // 批量设置作业名称
            questionRelationList = questionRelationList.stream().map(relation -> {
                if (relation != null) {
                    relation.setAssignmentName(assignmentNameMap.getOrDefault(relation.getAssignmentId(), "未知作业"));
                }
                return relation;
            }).collect(Collectors.toList());
        }

        log.info("查询到学生{}在课程{}的关联数据总数：{}（作业ID：{}）",
                studentUserId, courseId, questionRelationList.size(), studentAssignmentIds);
        return questionRelationList;
    }

    private String callTongyiQianwenByApiKey(String prompt) throws ApiException, NoApiKeyException, InputRequiredException {
        String apiKey = "sk-92d17cdcbcd74bb4938ce53ac333d25c";
        if (StringUtils.isBlank(prompt)) throw new InputRequiredException("Prompt不能为空");
        if (StringUtils.isBlank(apiKey) || !apiKey.startsWith("sk-")) throw new NoApiKeyException();

        Message userMsg = Message.builder().role(Role.USER.getValue()).content(prompt).build();
        GenerationParam param = GenerationParam.builder()
                .model(aiModelVersion)
                .messages(Arrays.asList(userMsg))
                .resultFormat(GenerationParam.ResultFormat.TEXT)
                .temperature((float) 0.5)
                .maxTokens(3000)
                .apiKey(apiKey)
                .build();

        Generation generation = new Generation();
        GenerationResult result = generation.call(param);
        if (result == null || result.getOutput() == null || StringUtils.isBlank(result.getOutput().getText())) {
            throw new RuntimeException("大模型无有效推荐结果");
        }
        return result.getOutput().getText().trim();
    }

    // 修复：新增learnStatusList参数
    private List<PersonalizedRecommendation> parseRecommendContent(Long studentUserId, Long courseId, String recommendContent,
                                                                   List<QuestionKpRelationVo> questionRelationList,
                                                                   List<StudentLearnStatusVo> learnStatusList) {
        List<PersonalizedRecommendation> recommendationList = new ArrayList<>();
        Pattern pattern = Pattern.compile(
                "【类型：([\\w,]+)】【目标ID：([\\d.,-]+)】【关联知识点：([\\d,]+)】(.*?)(?=\\s*【类型：|$)",
                Pattern.DOTALL
        );
        Matcher matcher = pattern.matcher(recommendContent);

        while (matcher.find()) {
            String typeStr = matcher.group(1);
            String targetIds = matcher.group(2);
            String relatedKps = matcher.group(3);
            String reason = matcher.group(4).trim();

            if (StringUtils.isBlank(typeStr) || StringUtils.isBlank(targetIds) || StringUtils.isBlank(relatedKps) || StringUtils.isBlank(reason)) {
                continue;
            }

            String recommendType = typeStr.split(",")[0].trim();
            List<String> validTypes = Arrays.asList("video", "exercise", "resource", "kp_review");
            if (!validTypes.contains(recommendType)) continue;

            String[] kpIdsArray = relatedKps.split(",");
            Arrays.sort(kpIdsArray);
            String sortedKpIds = String.join(",", kpIdsArray);

            String firstTargetId = targetIds.split(",")[0].trim().replace(".", "").replace("-", "");
            if (!firstTargetId.matches("\\d+")) continue;
            Long targetId = Long.parseLong(firstTargetId);

            // 修复：传入learnStatusList参数，执行精准错题筛选
            String filteredReason = filterIrrelevantWrongQuestions(studentUserId, reason, sortedKpIds, questionRelationList, learnStatusList);

            PersonalizedRecommendation recommendation = new PersonalizedRecommendation();
            recommendation.setStudentUserId(studentUserId);
            recommendation.setCourseId(courseId);
            recommendation.setStatus("pending");
            recommendation.setPriority(3);
            recommendation.setAiModelVersion(aiModelVersion);
            recommendation.setExpireTime(LocalDateTime.now().plus(7, ChronoUnit.DAYS));
            recommendation.setIsDeleted(0);
            recommendation.setRecommendType(recommendType);
            recommendation.setTargetId(targetId);
            recommendation.setRelatedKpIds(sortedKpIds);
            recommendation.setRecommendReason(filteredReason.replaceAll("---", "").replaceAll("\\n+", "\n").trim());
            recommendation.setCreateTime(LocalDateTime.now());
            recommendation.setUpdateTime(LocalDateTime.now());

            recommendationList.add(recommendation);
        }
        return recommendationList;
    }

    /**
     * 核心修正：双重验证筛选错题（1.是学生错题；2.真实关联目标知识点）
     */
    private String filterIrrelevantWrongQuestions(Long studentUserId,
                                                  String originalReason,
                                                  String relatedKpIds,
                                                  List<QuestionKpRelationVo> questionRelationList,
                                                  List<StudentLearnStatusVo> studentLearnStatusList) {
        log.info("进入精准错题筛选方法：学生ID={}，目标关联知识点IDs={}，待筛选关联数据总数={}，学习状态数据总数={}",
                studentUserId, relatedKpIds, questionRelationList.size(), studentLearnStatusList.size());

        // 1. 边界条件判断
        if (studentUserId == null || StringUtils.isBlank(originalReason)
                || CollectionUtils.isEmpty(questionRelationList)
                || StringUtils.isBlank(relatedKpIds) || "无".equals(relatedKpIds)
                || CollectionUtils.isEmpty(studentLearnStatusList)) {
            log.warn("错题筛选：边界条件不满足，返回原始理由");
            return originalReason;
        }

        // 2. 解析目标知识点ID集合
        Set<String> targetKpIdSet = Arrays.stream(relatedKpIds.split(","))
                .map(String::trim)
                .filter(StringUtils::isNotBlank)
                .collect(Collectors.toSet());
        log.info("解析后的目标知识点ID集合：{}", targetKpIdSet);

        // 3. 步骤1：查询学生的真实错题（作业ID_序号 → 作业名称）
        Map<String, String> wrongQuestionCache = getStudentWrongQuestionCache(studentUserId);
        log.info("学生真实错题缓存：{}", wrongQuestionCache);

        // 4. 步骤2：从关联数据中匹配「真实错题+关联目标知识点」的记录
        Map<String, Set<Integer>> validAssignmentWrongMap = new LinkedHashMap<>(); // 作业名称→错题序号
        for (QuestionKpRelationVo relation : questionRelationList) {
            if (relation == null || relation.getAssignmentId() == null || relation.getQuestionSequence() == null) {
                log.debug("关联数据无效（作业ID/序号为空）：{}", JSON.toJSONString(relation));
                continue;
            }

            Long assId = relation.getAssignmentId();
            Integer sequence = relation.getQuestionSequence();
            String cacheKey = assId + "_" + sequence;
            String kpIds = relation.getKpIds() == null ? "" : relation.getKpIds();
            String assignmentName = relation.getAssignmentName();

            // 双重验证：①是学生错题；②关联目标知识点
            if (wrongQuestionCache.containsKey(cacheKey) && hasTargetKpRelation(kpIds, targetKpIdSet)) {
                validAssignmentWrongMap.computeIfAbsent(assignmentName, k -> new LinkedHashSet<>())
                        .add(sequence);
                log.info("匹配成功：作业{}（ID：{}）第{}题 → 关联知识点IDs：{}（目标知识点：{}）",
                        assignmentName, assId, sequence, kpIds, targetKpIdSet);
            }
        }

        // 5. 拼接最终错题字符串
        String wrongQuestionStr = buildWrongQuestionString(validAssignmentWrongMap, questionRelationList);
        log.info("筛选后最终错题字符串：{}", wrongQuestionStr);

        // 6. 替换原始理由中的错题部分
        String regex = "对应错题：.*?(\\n|$)";
        return originalReason.replaceAll(regex, "对应错题：" + wrongQuestionStr + "\n");
    }

    /**
     * 辅助方法：查询学生的真实错题（从student_answer表）
     */
    private Map<String, String> getStudentWrongQuestionCache(Long studentUserId) {
        Map<String, String> cache = new HashMap<>();
        List<Map<String, Object>> wrongQuestions = studentAnswerMapper.selectStudentWrongQuestions(studentUserId);
        for (Map<String, Object> wrong : wrongQuestions) {
            Long assId = (Long) wrong.get("assignmentId");
            Integer sequence = (Integer) wrong.get("sequence");
            String assignmentName = (String) wrong.get("assignmentName");
            if (assId != null && sequence != null && StringUtils.isNotBlank(assignmentName)) {
                String key = assId + "_" + sequence;
                cache.put(key, assignmentName);
            }
        }
        return cache;
    }

    /**
     * 辅助方法：判断题目关联的知识点是否包含目标知识点
     */
    private boolean hasTargetKpRelation(String kpIds, Set<String> targetKpIdSet) {
        if (StringUtils.isBlank(kpIds)) return false;
        Set<String> questionKpIdSet = Arrays.stream(kpIds.split(","))
                .map(String::trim)
                .filter(StringUtils::isNotBlank)
                .collect(Collectors.toSet());
        // 交集判断：题目关联的知识点与目标知识点是否有重叠
        return !Collections.disjoint(questionKpIdSet, targetKpIdSet);
    }

    /**
     * 辅助方法：构建错题字符串（格式：作业《xxx》（ID：xxx）第x题、第y题；）
     */
    private String buildWrongQuestionString(Map<String, Set<Integer>> validAssignmentWrongMap, List<QuestionKpRelationVo> questionRelationList) {
        if (validAssignmentWrongMap.isEmpty() || validAssignmentWrongMap.values().stream().allMatch(Set::isEmpty)) {
            return "无";
        }

        StringBuilder wrongSb = new StringBuilder();
        for (Map.Entry<String, Set<Integer>> entry : validAssignmentWrongMap.entrySet()) {
            String assignmentName = entry.getKey();
            Set<Integer> wrongNos = entry.getValue();
            if (wrongNos.isEmpty()) continue;

            // 排序错题序号
            List<Integer> sortedNos = wrongNos.stream().sorted().collect(Collectors.toList());
            String questionStr = "第" + sortedNos.stream()
                    .map(String::valueOf)
                    .collect(Collectors.joining("题、第")) + "题";

            // 获取作业ID
            String assignmentId = questionRelationList.stream()
                    .filter(r -> assignmentName.equals(r.getAssignmentName()))
                    .findFirst()
                    .map(r -> r.getAssignmentId().toString())
                    .orElse("");

            wrongSb.append("作业《").append(assignmentName).append("》（ID：").append(assignmentId).append("）").append(questionStr).append("；");
        }

        // 移除最后一个分号
        if (wrongSb.length() > 0) {
            wrongSb.setLength(wrongSb.length() - 1);
        }
        return wrongSb.toString();
    }

    /**
     * 辅助方法：从"第5题、第8题、第10题"或"无"中解析出错题序号（兼容旧逻辑）
     */
    @Deprecated
    private Set<Integer> parseWrongQuestionNos(String wrongQuestionNo) {
        Set<Integer> wrongNos = new LinkedHashSet<>();
        if (StringUtils.isBlank(wrongQuestionNo) || "无".equals(wrongQuestionNo)) {
            return wrongNos;
        }
        // 正则匹配所有数字（处理"第5题、第8题"格式）
        Pattern pattern = Pattern.compile("\\d+");
        Matcher matcher = pattern.matcher(wrongQuestionNo);
        while (matcher.find()) {
            String numStr = matcher.group();
            wrongNos.add(Integer.parseInt(numStr));
        }
        log.debug("解析错题序号（兼容旧逻辑）：原始字符串={}，解析结果={}", wrongQuestionNo, wrongNos);
        return wrongNos;
    }

    private List<Integer> extractWrongQuestionNumbers(String reason) {
        List<Integer> questionNumbers = new ArrayList<>();
        Pattern pattern = Pattern.compile("对应错题：(.*?)(\\n|$)");
        Matcher matcher = pattern.matcher(reason);
        if (matcher.find()) {
            String wrongQuestionPart = matcher.group(1);
            if (wrongQuestionPart.contains("无")) return questionNumbers;
            Pattern numPattern = Pattern.compile("(\\d+)");
            Matcher numMatcher = numPattern.matcher(wrongQuestionPart);
            while (numMatcher.find()) {
                try {
                    questionNumbers.add(Integer.parseInt(numMatcher.group(1)));
                } catch (NumberFormatException e) {
                    log.debug("解析错题序号失败：{}", numMatcher.group(1), e);
                }
            }
        }
        return questionNumbers;
    }

    private List<PersonalizedRecommendation> filterDuplicateRecommendations(List<PersonalizedRecommendation> recommendationList) {
        List<PersonalizedRecommendation> uniqueRecList = new ArrayList<>();
        for (PersonalizedRecommendation rec : recommendationList) {
            boolean isDuplicate = recommendationMapper.existsDuplicate(
                    rec.getStudentUserId(),
                    rec.getCourseId(),
                    rec.getRecommendType(),
                    rec.getRelatedKpIds()
            );
            if (!isDuplicate) {
                uniqueRecList.add(rec);
            }
        }
        return uniqueRecList;
    }

    // 修复：新增learnStatusList参数
    private String assembleExistingRecommendations(List<PersonalizedRecommendation> existingRecs,
                                                   List<QuestionKpRelationVo> questionRelationList,
                                                   Map<String, String> kpNameMap,
                                                   List<StudentLearnStatusVo> learnStatusList) {
        StringBuilder sb = new StringBuilder();
        sb.append("以下是为你推荐的个性化提升方案（基于历史有效推荐）：\n\n---\n\n");

        for (int i = 0; i < existingRecs.size(); i++) {
            PersonalizedRecommendation rec = existingRecs.get(i);
            if (rec == null) continue;

            sb.append("**").append(i + 1).append(". 推荐动作：");
            String recommendType = StringUtils.isNotBlank(rec.getRecommendType()) ? rec.getRecommendType() : "unknown";
            switch (recommendType) {
                case "video": sb.append("观看视频学习"); break;
                case "exercise": sb.append("复习错题+习题训练"); break;
                case "resource": sb.append("学习资料补充"); break;
                case "kp_review": sb.append("知识点复盘巩固"); break;
                default: sb.append("个性化提升");
            }
            sb.append("**  \n");

            String targetIdStr = rec.getTargetId() != null ? rec.getTargetId().toString() : "0";
            String relatedKpsStr = StringUtils.isNotBlank(rec.getRelatedKpIds()) ? rec.getRelatedKpIds() : "无";
            sb.append("【类型：").append(recommendType).append("】")
                    .append("【目标ID：").append(targetIdStr).append("】")
                    .append("【关联知识点：").append(relatedKpsStr).append("】  \n");

            // 修复：传入学生ID和learnStatusList，执行精准筛选
            String filteredReason = filterIrrelevantWrongQuestions(
                    rec.getStudentUserId(),
                    rec.getRecommendReason() != null ? rec.getRecommendReason() : "",
                    relatedKpsStr,
                    questionRelationList,
                    learnStatusList
            );

            if ("video".equals(recommendType) && rec.getTargetId() != null) {
                String videoLocation = getVideoLocationBySectionId(rec.getTargetId());
                filteredReason = filteredReason.replaceAll("视频URL：.*?(\\n|$)", "视频位置：" + videoLocation + "\n");
            }

            String recommendReason = StringUtils.isNotBlank(filteredReason)
                    ? filteredReason.replace("\n", "  \n")
                    : "该推荐暂无详细说明，可直接按推荐类型执行提升动作～";
            sb.append(recommendReason).append("  \n\n---\n\n");
        }
        sb.append("以上推荐为历史有效方案，可直接执行提升学习效果～");
        return sb.toString();
    }

    private String getVideoLocationBySectionId(Long sectionId) {
        if (sectionId == null) return "无";
        try {
            Map<String, String> locationMap = sectionKpMapper.selectChapterSectionBySectionId(sectionId);
            if (locationMap == null || locationMap.isEmpty()) {
                return "未知位置";
            }
            String chapterTitle = locationMap.getOrDefault("chapterTitle", "未知章节");
            String sectionTitle = locationMap.getOrDefault("sectionTitle", "未知小节");
            return String.format("【%s】%s", chapterTitle, sectionTitle);
        } catch (Exception e) {
            log.error("查询小节{}的章节位置失败", sectionId, e);
            return "未知位置";
        }
    }

    // 修复：新增learnStatusList参数
    private PersonalizedRecommendItemVo convertToItemVo(PersonalizedRecommendation rec,
                                                        List<QuestionKpRelationVo> questionRelationList,
                                                        Map<String, String> kpNameMap,
                                                        List<StudentLearnStatusVo> learnStatusList) {
        PersonalizedRecommendItemVo vo = new PersonalizedRecommendItemVo();
        vo.setId(rec.getId() != null ? rec.getId() : 0L);
        vo.setBatchId(StringUtils.isNotBlank(rec.getBatchId()) ? rec.getBatchId() : "");
        vo.setRecommendType(StringUtils.isNotBlank(rec.getRecommendType()) ? rec.getRecommendType() : "");
        vo.setTargetId(rec.getTargetId() != null ? rec.getTargetId() : 0L);

        // 修复：传入学生ID和learnStatusList，执行精准筛选
        String filteredReason = filterIrrelevantWrongQuestions(
                rec.getStudentUserId(),
                rec.getRecommendReason() != null ? rec.getRecommendReason() : "",
                rec.getRelatedKpIds() != null ? rec.getRelatedKpIds() : "",
                questionRelationList,
                learnStatusList
        );

        if ("video".equals(vo.getRecommendType()) && vo.getTargetId() != null) {
            String videoLocation = getVideoLocationBySectionId(vo.getTargetId());
            filteredReason = filteredReason.replaceAll("视频URL：.*?(\\n|$)", "视频位置：" + videoLocation + "\n");
        }

        vo.setRecommendReason(StringUtils.isNotBlank(filteredReason) ? filteredReason : "暂无推荐说明");
        vo.setRelatedKpIds(StringUtils.isNotBlank(rec.getRelatedKpIds()) ? rec.getRelatedKpIds() : "无");

        if (StringUtils.isNotBlank(rec.getRelatedKpIds()) && !rec.getRelatedKpIds().equals("无")) {
            String kpNames = Arrays.stream(rec.getRelatedKpIds().split(","))
                    .map(String::trim)
                    .map(id -> kpNameMap.getOrDefault(id, "知识点" + id))
                    .collect(Collectors.joining("、"));
            vo.setRelatedKpNames(kpNames);
        } else {
            vo.setRelatedKpNames("暂无关联");
        }

        vo.setStatus(StringUtils.isNotBlank(rec.getStatus()) ? rec.getStatus() : "pending");
        vo.setCreateTime(rec.getCreateTime() != null ? rec.getCreateTime() : LocalDateTime.now());
        return vo;
    }
}
