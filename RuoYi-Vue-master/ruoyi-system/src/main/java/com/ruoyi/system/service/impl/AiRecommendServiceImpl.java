package com.ruoyi.system.service.impl;

import com.alibaba.dashscope.aigc.generation.Generation;
import com.alibaba.dashscope.aigc.generation.GenerationParam;
import com.alibaba.dashscope.aigc.generation.GenerationResult;
import com.alibaba.dashscope.common.Message;
import com.alibaba.dashscope.common.Role;
import com.alibaba.dashscope.exception.ApiException;
import com.alibaba.dashscope.exception.InputRequiredException;
import com.alibaba.dashscope.exception.NoApiKeyException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.Assignment;
import com.ruoyi.system.domain.PersonalizedRecommendation;
import com.ruoyi.system.domain.vo.AiRecommendResultVo;
import com.ruoyi.system.domain.vo.KpResourceVo;
import com.ruoyi.system.domain.vo.PersonalizedRecommendItemVo;
import com.ruoyi.system.domain.vo.QuestionKpRelationVo;
import com.ruoyi.system.domain.vo.StudentLearnStatusVo;
import com.ruoyi.system.mapper.AssignmentMapper;
import com.ruoyi.system.mapper.AssignmentQuestionMapper;
import com.ruoyi.system.mapper.PersonalizedRecommendationMapper;
import com.ruoyi.system.mapper.SectionKpMapper;
import com.ruoyi.system.mapper.StudentKpMasteryMapper;
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
    private AssignmentQuestionMapper assignmentQuestionMapper;
    @Autowired
    private PersonalizedRecommendationMapper recommendationMapper;
    @Autowired
    private AssignmentMapper assignmentMapper;

    // 通义千问配置
    @Value("${tongyi.qianwen.model:qwen-turbo}")
    private String aiModelVersion;
    @Value("${tongyi.qianwen.timeout:30000}")
    private int timeout;

    @Override
    public String generateModelInput(Long studentUserId, Long courseId) {
        List<StudentLearnStatusVo> learnStatusList = studentKpMasteryMapper.selectStudentLearnStatus(studentUserId, courseId);
        List<KpResourceVo> resourceList = sectionKpMapper.selectKpResourceByCourseId(courseId);

        Long assignmentId = null;
        String assignmentName = "未知作业";
        if (CollectionUtils.isNotEmpty(learnStatusList)) {
            StudentLearnStatusVo firstStatus = learnStatusList.get(0);
            if (firstStatus != null) {
                assignmentId = firstStatus.getAssignmentId();
                if (assignmentId != null) {
                    Assignment assignment = assignmentMapper.selectAssignmentById(assignmentId);
                    assignmentName = assignment != null ? assignment.getTitle() : "未知作业";
                }
            }
        }

        List<QuestionKpRelationVo> questionRelationList = getQuestionKpRelationList(studentUserId, courseId);
        StringBuilder input = new StringBuilder();

        input.append("【学生学习状态数据】\n");
        input.append("学生ID=").append(studentUserId)
                .append("，课程ID=").append(courseId)
                .append("，关联作业=").append(assignmentName).append("（作业ID=").append(assignmentId == null ? "无" : assignmentId).append("）\n");
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

                input.append("1. 知识点ID=").append(kpId)
                        .append("，名称=").append(kpTitle)
                        .append("，掌握状态=").append(masteryStatus)
                        .append("，准确率=").append(accuracy)
                        .append("，关联作业=").append(assId == -1 ? "无" : assignmentName)
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
                String sectionTitle = resource.getSectionTitle() == null ? "未知小节" : resource.getSectionTitle();
                String videoUrl = resource.getVideoUrl() == null ? "暂无" : resource.getVideoUrl();
                String coreKnowledge = resource.getCoreKnowledge() == null ? "暂无" : resource.getCoreKnowledge();

                input.append("1. 知识点ID=").append(kpId).append("（").append(kpTitle).append("）\n")
                        .append("   - 对应小节：").append(sectionTitle).append("\n")
                        .append("   - 视频URL：").append(videoUrl).append("\n")
                        .append("   - 核心考点：").append(coreKnowledge).append("\n");
            }
        }

        input.append("\n【作业题目-知识点关联数据】\n");
        if (CollectionUtils.isNotEmpty(questionRelationList)) {
            input.append("作业名称=").append(assignmentName)
                    .append("（作业ID=").append(assignmentId == null ? "无" : assignmentId)
                    .append("，课程ID=").append(courseId).append("）\n");
            for (QuestionKpRelationVo relation : questionRelationList) {
                if (relation == null) continue;
                List<String> kpTitleList = new ArrayList<>();
                if (StringUtils.isNotBlank(relation.getKpTitles())) {
                    kpTitleList = Arrays.stream(relation.getKpTitles().split(","))
                            .map(String::trim)
                            .collect(Collectors.toList());
                }
                String kpTitleStr = CollectionUtils.isEmpty(kpTitleList) ? "无" : String.join("、", kpTitleList);
                Integer questionSeq = relation.getQuestionSequence() == null ? -1 : relation.getQuestionSequence();
                input.append("1. 第").append(questionSeq == -1 ? "未知" : questionSeq).append("题 → 关联知识点：")
                        .append(kpTitleStr).append("\n");
            }
        } else {
            input.append("当前课程暂无作业题目-知识点关联数据\n");
        }

        input.append("\n【推荐规则说明】\n")
                .append("1. 学习优先级：掌握状态weak > learning > mastered > unlearned；同状态下准确率越低越优先\n")
                .append("2. 推荐数量限制：每个知识点仅推荐1-2个核心动作（如1个视频+1个习题），避免重复推荐同一类型内容\n")
                .append("3. 推荐内容要求：分点列出每个需提升的知识点，每个知识点尽量包含「推荐动作」「视频URL（如有）」「重点关注内容」「对应错题」「执行建议」\n")
                .append("   - 重点关注内容：格式必须为「【xx小节】+核心内容」（小节名称从【知识点-学习资源关联数据】中提取，如“【1.2 空间复杂度优化技巧】空间复杂度优化相关题目”）\n")
                .append("   - 对应错题：格式必须为「作业《XXX》（ID：XXX）第X题、第X题」（如“作业《算法基础第3章测试》（ID：1001）第2题、第9题”）\n")
                .append("   - 仅列出「考察当前知识点」的题目，不相关错题不显示；无相关错题则写“无”，禁止复用全量错题\n")
                .append("4. 格式要求（必须满足，否则视为无效）：\n")
                .append("   - 每条推荐末尾必须附加标记【类型：xxx】【目标ID：xxx】【关联知识点：xxx】\n")
                .append("   - 类型：只能是单个值（video=视频、exercise=习题、resource=资料、kp_review=知识点复盘），禁止多类型拼接\n")
                .append("   - 目标ID：小节ID（视频类型）、题目ID（习题类型）、资源ID（资料类型）、知识点ID（复盘类型），多个用逗号分隔\n")
                .append("   - 关联知识点：多个用逗号分隔（如1001,1002）\n")
                .append("5. 语言要求：口语化、简洁明了，学生能直接按推荐执行，无需额外解释\n")
                .append("6. 若部分数据缺失（如无视频URL、无错题），可跳过，重点保证推荐内容完整和标记格式正确\n");
        return input.toString();
    }

    @Override
    public AiRecommendResultVo getRecommendResult(Long studentUserId, Long courseId) {
        AiRecommendResultVo resultVo = new AiRecommendResultVo();
        try {
            // 1. 提前获取「题目-知识点关联数据」（用于过滤错题）
            List<QuestionKpRelationVo> questionRelationList = getQuestionKpRelationList(studentUserId, courseId);

            // ✅ 新增：提前构建「知识点ID -> 知识点名称」的映射表
            // 这样无论数据库推荐还是AI新生成的推荐，都能查到名字
            Map<String, String> kpNameMap = buildKpIdToNameMap(studentUserId, courseId);

            // 第一步：查询数据库已有有效推荐
            List<PersonalizedRecommendation> existingRecs = recommendationMapper.selectValidRecommendations(studentUserId, courseId);
            if (CollectionUtils.isNotEmpty(existingRecs)) {
                log.info("数据库中存在{}条有效推荐，直接返回", existingRecs.size());
                String existingRecContent = assembleExistingRecommendations(existingRecs, questionRelationList);
                resultVo.setRecommendContent(existingRecContent);
                resultVo.setAvatarStatus("completed");

                // 转换VO（传入映射表）
                List<PersonalizedRecommendItemVo> itemVoList = existingRecs.stream()
                        .map(rec -> convertToItemVo(rec, questionRelationList, kpNameMap))
                        .collect(Collectors.toList());
                resultVo.setRecommendItemList(itemVoList);
                return resultVo;
            }

            // 第二步：无数据库推荐，调用大模型生成
            log.info("数据库无有效推荐，调用大模型生成");
            String modelInput = generateModelInput(studentUserId, courseId);
            String recommendContent = callTongyiQianwenByApiKey(modelInput);

            resultVo.setRecommendContent(recommendContent);
            resultVo.setAvatarStatus("completed");
            resultVo.setModelInput(modelInput);

            // 第三步：解析推荐内容
            List<PersonalizedRecommendation> recommendationList = parseRecommendContent(studentUserId, courseId, recommendContent, questionRelationList);
            if (CollectionUtils.isNotEmpty(recommendationList)) {
                List<PersonalizedRecommendation> uniqueRecList = filterDuplicateRecommendations(recommendationList);
                if (CollectionUtils.isNotEmpty(uniqueRecList)) {
                    String batchId = UUID.randomUUID().toString().replace("-", "");
                    uniqueRecList.forEach(rec -> rec.setBatchId(batchId));
                    recommendationMapper.insertPersonalizedRecommendationBatch(uniqueRecList);
                    log.info("推荐入库成功：{}条", uniqueRecList.size());

                    // 转换VO（传入映射表）
                    List<PersonalizedRecommendItemVo> itemVoList = uniqueRecList.stream()
                            .map(rec -> convertToItemVo(rec, questionRelationList, kpNameMap))
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

    // ✅ 新增方法：构建知识点ID到名称的映射（合并学习状态和资源表的数据）
    private Map<String, String> buildKpIdToNameMap(Long studentUserId, Long courseId) {
        Map<String, String> map = new HashMap<>();

        // 1. 从学习状态表中获取（涵盖学生已学知识点）
        List<StudentLearnStatusVo> learnStatusList = studentKpMasteryMapper.selectStudentLearnStatus(studentUserId, courseId);
        if (CollectionUtils.isNotEmpty(learnStatusList)) {
            for (StudentLearnStatusVo vo : learnStatusList) {
                if (vo.getKpId() != null && StringUtils.isNotBlank(vo.getKpTitle())) {
                    map.put(String.valueOf(vo.getKpId()), vo.getKpTitle());
                }
            }
        }

        // 2. 从课程资源表中获取（涵盖课程所有知识点，防止遗漏）
        List<KpResourceVo> resourceList = sectionKpMapper.selectKpResourceByCourseId(courseId);
        if (CollectionUtils.isNotEmpty(resourceList)) {
            for (KpResourceVo vo : resourceList) {
                if (vo.getKpId() != null && StringUtils.isNotBlank(vo.getKpTitle())) {
                    // 如果map里已经有了，put会覆盖，效果一样
                    map.put(String.valueOf(vo.getKpId()), vo.getKpTitle());
                }
            }
        }
        return map;
    }

    private List<QuestionKpRelationVo> getQuestionKpRelationList(Long studentUserId, Long courseId) {
        List<QuestionKpRelationVo> questionRelationList = new ArrayList<>();
        List<StudentLearnStatusVo> learnStatusList = studentKpMasteryMapper.selectStudentLearnStatus(studentUserId, courseId);
        Long assignmentId = null;
        if (CollectionUtils.isNotEmpty(learnStatusList)) {
            StudentLearnStatusVo firstStatus = learnStatusList.get(0);
            assignmentId = firstStatus != null ? firstStatus.getAssignmentId() : null;
        }

        if (assignmentId == null || courseId == null) return questionRelationList;

        Assignment assignment = assignmentMapper.selectAssignmentById(assignmentId);
        String assignmentName = assignment != null ? assignment.getTitle() : "未知作业";

        Map<String, Object> params = new HashMap<>();
        params.put("courseId", courseId);
        params.put("assignmentId", assignmentId);
        List<QuestionKpRelationVo> tempList = assignmentQuestionMapper.selectQuestionKpRelation(params);

        if (CollectionUtils.isNotEmpty(tempList)) {
            questionRelationList = tempList.stream().map(relation -> {
                relation.setAssignmentName(assignmentName);
                return relation;
            }).collect(Collectors.toList());
        }

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

    private List<PersonalizedRecommendation> parseRecommendContent(Long studentUserId, Long courseId, String recommendContent, List<QuestionKpRelationVo> questionRelationList) {
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

            String filteredReason = filterIrrelevantWrongQuestions(reason, sortedKpIds, questionRelationList);

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

    private String filterIrrelevantWrongQuestions(String originalReason, String sortedKpIds, List<QuestionKpRelationVo> questionRelationList) {
        if (StringUtils.isBlank(originalReason) || CollectionUtils.isEmpty(questionRelationList)) {
            return originalReason;
        }

        List<Integer> originalWrongQuestions = extractWrongQuestionNumbers(originalReason);
        if (CollectionUtils.isEmpty(originalWrongQuestions)) {
            return originalReason.replaceAll("对应错题：.*?(\\n|$)", "对应错题：无\n");
        }

        String assignmentName = "未知作业";
        Long assignmentId = null;
        List<Integer> relevantQuestions = new ArrayList<>();
        String[] targetKpIds = sortedKpIds.split(",");
        Set<String> targetKpIdSet = new HashSet<>(Arrays.asList(targetKpIds));

        for (QuestionKpRelationVo relation : questionRelationList) {
            if (relation == null || relation.getQuestionSequence() == null) continue;

            if (StringUtils.isNotBlank(relation.getAssignmentName()) && "未知作业".equals(assignmentName)) {
                assignmentName = relation.getAssignmentName();
            }
            if (relation.getAssignmentId() != null && assignmentId == null) {
                assignmentId = relation.getAssignmentId();
            }

            String kpIds = relation.getKpIds() != null ? relation.getKpIds() : relation.getKpTitles();
            if (StringUtils.isBlank(kpIds)) continue;
            List<String> questionKpList = Arrays.stream(kpIds.split(","))
                    .map(String::trim)
                    .collect(Collectors.toList());

            boolean isRelevant = questionKpList.stream().anyMatch(targetKpIdSet::contains);
            if (isRelevant && originalWrongQuestions.contains(relation.getQuestionSequence())) {
                relevantQuestions.add(relation.getQuestionSequence());
            }
        }

        String wrongQuestionStr;
        if (CollectionUtils.isEmpty(relevantQuestions)) {
            wrongQuestionStr = "无";
        } else {
            String questionSeqStr = "第" + relevantQuestions.stream()
                    .map(String::valueOf)
                    .collect(Collectors.joining("题、第")) + "题";
            wrongQuestionStr = String.format("作业《%s》（ID：%s）%s",
                    assignmentName,
                    assignmentId == null ? "未知" : assignmentId,
                    questionSeqStr);
        }

        return originalReason.replaceAll("对应错题：.*?(\\n|$)", "对应错题：" + wrongQuestionStr + "\n");
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
                } catch (NumberFormatException e) { }
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

    private String assembleExistingRecommendations(List<PersonalizedRecommendation> existingRecs, List<QuestionKpRelationVo> questionRelationList) {
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

            String filteredReason = filterIrrelevantWrongQuestions(
                    rec.getRecommendReason() != null ? rec.getRecommendReason() : "",
                    relatedKpsStr,
                    questionRelationList
            );
            String recommendReason = StringUtils.isNotBlank(filteredReason)
                    ? filteredReason.replace("\n", "  \n")
                    : "该推荐暂无详细说明，可直接按推荐类型执行提升动作～";
            sb.append(recommendReason).append("  \n\n---\n\n");
        }
        sb.append("以上推荐为历史有效方案，可直接执行提升学习效果～");
        return sb.toString();
    }

    // ✅ 修改：增加 Map 参数，并回填 relatedKpNames 字段
    private PersonalizedRecommendItemVo convertToItemVo(PersonalizedRecommendation rec,
                                                        List<QuestionKpRelationVo> questionRelationList,
                                                        Map<String, String> kpNameMap) {
        PersonalizedRecommendItemVo vo = new PersonalizedRecommendItemVo();
        vo.setId(rec.getId() != null ? rec.getId() : 0L);
        vo.setBatchId(StringUtils.isNotBlank(rec.getBatchId()) ? rec.getBatchId() : "");
        vo.setRecommendType(StringUtils.isNotBlank(rec.getRecommendType()) ? rec.getRecommendType() : "");
        vo.setTargetId(rec.getTargetId() != null ? rec.getTargetId() : 0L);

        String filteredReason = filterIrrelevantWrongQuestions(
                rec.getRecommendReason() != null ? rec.getRecommendReason() : "",
                rec.getRelatedKpIds() != null ? rec.getRelatedKpIds() : "",
                questionRelationList
        );
        vo.setRecommendReason(StringUtils.isNotBlank(filteredReason) ? filteredReason : "暂无推荐说明");
        vo.setRelatedKpIds(StringUtils.isNotBlank(rec.getRelatedKpIds()) ? rec.getRelatedKpIds() : "无");

        // 核心修改：根据 ID 查 Map，拼装名称字符串
        if (StringUtils.isNotBlank(rec.getRelatedKpIds()) && !rec.getRelatedKpIds().equals("无")) {
            String kpNames = Arrays.stream(rec.getRelatedKpIds().split(","))
                    .map(String::trim)
                    .map(id -> kpNameMap.getOrDefault(id, "知识点" + id)) // 查不到则兜底
                    .collect(Collectors.joining("、")); // 使用顿号分隔
            vo.setRelatedKpNames(kpNames);
        } else {
            vo.setRelatedKpNames("暂无关联");
        }

        vo.setStatus(StringUtils.isNotBlank(rec.getStatus()) ? rec.getStatus() : "pending");
        vo.setCreateTime(rec.getCreateTime() != null ? rec.getCreateTime() : LocalDateTime.now());
        return vo;
    }
}
