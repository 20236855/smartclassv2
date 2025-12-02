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
import com.ruoyi.system.domain.User;
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
import com.ruoyi.system.mapper.UserMapper;

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
    @Autowired
    private UserMapper userMapper;
    @Autowired
    private VideoLearningBehaviorMapper videoLearningBehaviorMapper;
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
                .append("===== 核心原则：必须严格按以下规则+样板生成，强制输出结果，任何违规/无输出均视为无效 =====\n")
                .append("1. 学习优先级：掌握状态weak > learning > mastered > unlearned；同状态下准确率越低越优先，每个知识点仅推荐1次（禁止重复）\n")
                .append("2. 输出强制要求：无论数据完整度如何，必须至少输出5条推荐（不足时从unlearned状态补充），禁止无结果返回\n")
                .append("3. 必含字段：每个知识点必须包含「知识点ID+名称」「推荐动作」「视频位置」「重点关注内容」「对应错题」「执行建议」，缺一项即无效；无对应数据时统一填“无”（视频位置无章节信息时填“【未知章节】未知小节”）\n")
                .append("4. 数据来源：所有字段优先取自提供的【学生学习状态数据】【知识点-学习资源关联数据】【作业题目-知识点关联数据】，无数据时按规则补“无”，禁止编造有效数据、刻意遗漏必含字段\n")
                .append("   - 对应错题：仅推荐当前知识点ID明确关联的学生错题（题目序号+作业信息），无则写“无”，禁止添加无关联题目\n")
                .append("   - 视频位置：有资源数据则提取「【xx章节】xx小节」，无则填“【未知章节】未知小节”，禁止空值\n")
                .append("   - 重点关注内容：有资源数据则填「【xx章节】xx小节+核心考点」，无则填「【未知章节】未知小节+知识点核心概念」，禁止无意义表述\n")
                .append("5. 格式要求：严格按以下样板的结构、符号、顺序生成，逐字模仿（包括顿号、破折号、括号、换行格式），不得增减字段顺序、修改符号样式\n")
                .append("6. 禁止内容：\n")
                .append("   - 禁止###、##等层级符号，禁止后端字段类型（String/Integer）、状态（pending）、模型名（qwen-turbo）等无关数据\n")
                .append("   - 关联知识点&目标ID：仅保留数字+英文逗号，紧跟执行建议后（格式：“关联知识点：XXX 目标ID：XXX”），无则填“关联知识点：无 目标ID：无”\n")
                .append("   - 末尾标记：【类型：xxx】【目标ID：xxx】【关联知识点：xxx】（仅数字+英文逗号，无则填“无”），类型优先取resource/video，无则填“resource”\n")
                .append("7. 薄弱点优先规则：必须优先推荐「学生学习状态为weak/准确率<60%」的知识点，且这些知识点必须来自「作业题目-知识点关联数据」中的错题关联知识点，禁止推荐无错题关联的知识点（unlearned状态仅在weak知识点不足2条时补充）；\n" +
                        "8. 错题校验规则：推荐的“对应错题”必须是「学生学习状态数据」中标记的答错题目，且题目ID必须存在于「作业题目-知识点关联数据」中，无则填“无”，禁止编造错题；\n" +
                        "9. 知识点限制：推荐的知识点ID必须来自输入数据中的「学生学习状态数据」「作业题目-知识点关联数据」，禁止添加输入数据中没有的知识点ID。\n")
                .append("\n【输出样板（必须完全模仿，不能变更任何格式、顺序、符号）】\n")
                .append("1、知识点ID=4005（等价无穷小）\n")
                .append("- 推荐动作：复习等价无穷小替换技巧，提升解题准确率\n")
                .append("- 视频位置：【1.极限】等价无穷小\n")
                .append("- 重点关注内容：【1.极限】等价无穷小 等价无穷小替换技巧\n")
                .append("- 对应错题：作业《第二章 函数综合测试》（ID：4004）第5题、第8题、第10题\n")
                .append("- 执行建议：加强对等价无穷小的应用方法，尤其是结合极限计算 关联知识点：4005,4010 目标ID：4004,4006\n")
                .append("【类型：resource】【目标ID：4004,4006】【关联知识点：4005,4010】\n")
                .append("\n2、知识点ID=4032（反函数的图像对称性）\n")
                .append("- 推荐动作：观看视频，理解反函数与原函数图像的对称关系\n")
                .append("- 视频位置：【1.3反函数】反函数的图像对称性\n")
                .append("- 重点关注内容：【1.3反函数】反函数的原理 反函数的图像对称性原理\n")
                .append("- 对应错题：无\n")
                .append("- 执行建议：通过视频学习对称性质，配合例题加深理解 关联知识点：无 目标ID：无\n")
                .append("【类型：video】【目标ID：无】【关联知识点：无】\n")
                .append("\n3、知识点ID=4010（极限的唯一性）\n")
                .append("- 推荐动作：巩固极限唯一性定理，强化解题应用能力\n")
                .append("- 视频位置：【1.极限】极限的性质\n")
                .append("- 重点关注内容：【1.极限】极限的性质 极限唯一性定理的推导与应用\n")
                .append("- 对应错题：无\n")
                .append("- 执行建议：结合基础例题练习，掌握定理适用场景 关联知识点：4010,4005 目标ID：4008 无\n")
                .append("【类型：resource】【目标ID：4008】【关联知识点：4010,4005】\n")
                .append("\n【总结建议样板】\n")
                .append("总结建议：\n")
                .append("针对“等价无穷小（4005）”“反函数的图像对称性（4032）”等薄弱知识点，建议优先观看视频掌握核心概念，再通过对应错题和习题强化训练；“极限的唯一性（4010）”需重点巩固解题技巧，提升准确率；无对应错题的知识点可通过基础例题加深理解，确保学习效果。\n")
                .append("\n===== 强制要求：必须生成至少5条推荐+总结建议，一章至少一个推荐内容，格式与样板100%一致，缺字段/无输出/格式错误均视为无效！ =====\n");
        return input.toString();
    }

    @Override
// 原参数名studentUserId容易混淆，建议重命名为sysUserId（明确是sys_user表的ID）
    public AiRecommendResultVo getRecommendResult(Long sysUserId, Long courseId) {
        AiRecommendResultVo resultVo = new AiRecommendResultVo();
        try {
            // 1. 关键步骤：通过sys_user_id查询业务用户表（user）的真实ID（外键要求的ID）
            User businessUser = userMapper.selectUserBySysUserId(sysUserId);
            if (businessUser == null || businessUser.getId() == null) {
                log.error("未查询到系统用户ID={}对应的业务用户（user表）记录，无法生成推荐", sysUserId);
                resultVo.setRecommendContent("推荐失败：用户信息不存在");
                resultVo.setAvatarStatus("error");
                return resultVo;
            }
            Long businessUserId = businessUser.getId(); // 这才是要存入数据库的student_user_id（如38）
            log.info("系统用户ID={} 映射到业务用户ID={}", sysUserId, businessUserId);

            // 2. 后续所有数据库操作，都用 businessUserId 替代原来的 sysUserId
            // 2.1 查询题目关联数据（学生答题的作业-知识点-题目关联）
            List<QuestionKpRelationVo> questionRelationList = getQuestionKpRelationList(businessUserId, courseId);
            log.info("查询到课程{}的作业-知识点-题目关联数据总数：{}", courseId, questionRelationList.size());
            if (CollectionUtils.isEmpty(questionRelationList)) {
                log.warn("课程{}未查询到作业-知识点-题目关联数据，无法生成错题推荐", courseId);
            }

            // 2.2 查询学生学习状态（薄弱知识点、准确率等）
            List<StudentLearnStatusVo> learnStatusList = studentKpMasteryMapper.selectStudentLearnStatus(businessUserId, courseId);
            log.info("查询到业务用户{}在课程{}的学习状态数据总数：{}", businessUserId, courseId, learnStatusList.size());

            // 2.3 查询知识点学习资源（视频、章节等）
            List<KpResourceVo> resourceList = sectionKpMapper.selectKpResourceByCourseId(courseId);
            Map<String, String> kpNameMap = buildKpIdToNameMap(businessUserId, courseId, learnStatusList, resourceList);

            // 3. 检查数据库是否有有效推荐（优先用缓存，避免重复调用AI）
            List<PersonalizedRecommendation> existingRecs = recommendationMapper.selectValidRecommendations(businessUserId, courseId);
            if (CollectionUtils.isNotEmpty(existingRecs)) {
                log.info("数据库中存在{}条有效推荐，检查是否需要更新", existingRecs.size());

                // ---------------- 可选优化：判断用户是否有新行为（后面详细说）----------------
                boolean needGenerateNew = checkIfNeedNewRecommendation(businessUserId, courseId, existingRecs);
                if (!needGenerateNew) {
                    // 无新行为，直接返回现有推荐
                    String existingRecContent = assembleExistingRecommendations(existingRecs, questionRelationList, kpNameMap, learnStatusList);
                    resultVo.setRecommendContent(existingRecContent);
                    resultVo.setAvatarStatus("completed");
                    List<PersonalizedRecommendItemVo> itemVoList = existingRecs.stream()
                            .map(rec -> convertToItemVo(rec, questionRelationList, kpNameMap, learnStatusList))
                            .collect(Collectors.toList());
                    resultVo.setRecommendItemList(itemVoList);
                    return resultVo;
                } else {
                    log.info("用户有新的学习行为，忽略现有推荐，生成新推荐");
                }
            }

            // 4. 数据库无有效推荐，或用户有新行为 → 调用大模型生成新推荐
            log.info("调用大模型生成个性化推荐，业务用户ID={}，课程ID={}", businessUserId, courseId);
            String modelInput = generateModelInput(businessUserId, courseId, learnStatusList, questionRelationList, resourceList);
            String recommendContent = callTongyiQianwenByApiKey(modelInput);

            resultVo.setRecommendContent(recommendContent);
            resultVo.setAvatarStatus("completed");
            resultVo.setModelInput(modelInput);

            // 5. 解析AI结果并入库（关键：传入businessUserId）
            List<PersonalizedRecommendation> recommendationList = parseRecommendContent(businessUserId, courseId, recommendContent, questionRelationList, learnStatusList);
            if (CollectionUtils.isNotEmpty(recommendationList)) {
                // 去重（避免重复推荐同一知识点组合）
                List<PersonalizedRecommendation> uniqueRecList = filterDuplicateRecommendations(recommendationList);
                if (CollectionUtils.isNotEmpty(uniqueRecList)) {
                    // 生成新的batchId（每次新推荐都是唯一批次，UUID确保不重复）
                    String batchId = UUID.randomUUID().toString().replace("-", "");
                    uniqueRecList.forEach(rec -> {
                        rec.setBatchId(batchId); // 每个推荐项绑定同一批次ID
                        rec.setStudentUserId(businessUserId); // 确保存入的是业务用户ID
                        // 补充必要字段（避免数据库字段为空）
                        rec.setStatus("pending");
                        rec.setExpireTime(LocalDateTime.now().plusDays(7)); // 7天过期
                        rec.setIsDeleted(0);
                        rec.setCreateTime(LocalDateTime.now());
                        rec.setUpdateTime(LocalDateTime.now());
                    });
                    // 批量插入数据库（此时外键约束会通过，因为businessUserId在user表存在）
                    recommendationMapper.insertPersonalizedRecommendationBatch(uniqueRecList);
                    log.info("新推荐入库成功：{}条，批次ID={}", uniqueRecList.size(), batchId);

                    // 转换为VO返回给前端
                    List<PersonalizedRecommendItemVo> itemVoList = uniqueRecList.stream()
                            .map(rec -> convertToItemVo(rec, questionRelationList, kpNameMap, learnStatusList))
                            .collect(Collectors.toList());
                    resultVo.setRecommendItemList(itemVoList);
                } else {
                    resultVo.setRecommendItemList(new ArrayList<>());
                    log.warn("推荐去重后无有效数据");
                    // 去重后无数据，触发兜底入库
                    doFallbackSave(recommendContent, businessUserId, courseId);
                }
            } else {
                resultVo.setRecommendItemList(new ArrayList<>());
                log.warn("解析AI结果后无有效推荐，执行兜底入库");
                // 解析失败，触发兜底入库（核心修改：保存AI生成的完整文本）
                doFallbackSave(recommendContent, businessUserId, courseId);
            }

        } catch (NoApiKeyException e) {
            log.error("大模型API-Key无效", e);
            resultVo.setRecommendContent("推荐失败：认证无效");
            resultVo.setAvatarStatus("error");
        } catch (Exception e) {
            log.error("个性化推荐整体失败", e);
            resultVo.setRecommendContent("推荐失败：" + e.getMessage());
            resultVo.setAvatarStatus("error");
        }
        return resultVo;
    }

    // ---------------- 新增：兜底入库方法（解析失败时保存AI完整文本）----------------
    private void doFallbackSave(String recommendContent, Long businessUserId, Long courseId) {
        try {
            PersonalizedRecommendation fallbackRec = new PersonalizedRecommendation();
            fallbackRec.setStudentUserId(businessUserId);
            fallbackRec.setCourseId(courseId);

            // 核心：复用枚举中已有的'resource'作为兜底类型（符合数据库约束）
            fallbackRec.setRecommendType("resource");

            fallbackRec.setRecommendReason(recommendContent); // 保存完整AI推荐结果
            fallbackRec.setRelatedKpIds(""); // 无关联知识点，设为空字符串（符合非空）
            fallbackRec.setTargetId(0L); // 无目标ID，设为0L（符合BIGINT非空）
            fallbackRec.setStatus("pending");
            fallbackRec.setPriority(3); // 保持和正常推荐一致的优先级
            fallbackRec.setAiModelVersion(aiModelVersion); // 补充AI模型版本
            fallbackRec.setBatchId(UUID.randomUUID().toString().replace("-", ""));
            fallbackRec.setExpireTime(LocalDateTime.now().plus(7, ChronoUnit.DAYS));
            fallbackRec.setIsDeleted(0);
            fallbackRec.setCreateTime(LocalDateTime.now());
            fallbackRec.setUpdateTime(LocalDateTime.now());

            recommendationMapper.insertPersonalizedRecommendation(fallbackRec);
            log.info("兜底入库成功：推荐类型=resource（复用枚举值），目标ID=0L，业务用户ID={}", businessUserId);
        } catch (Exception e) {
            log.error("兜底入库失败（已使用合法枚举值）", e);
        }
    }

    // ---------------- 新增：从AI推荐文本中提取知识点ID（避免手动填写）----------------
    private String extractKpIdsFromContent(String recommendContent) {
        if (StringUtils.isEmpty(recommendContent)) {
            return "无";
        }
        // 正则匹配“知识点ID=数字”的格式（如“知识点ID=60030”）
        Pattern pattern = Pattern.compile("知识点ID=(\\d+)");
        Matcher matcher = pattern.matcher(recommendContent);
        Set<String> kpIdSet = new HashSet<>(); // 用Set去重
        while (matcher.find()) {
            kpIdSet.add(matcher.group(1)); // 提取数字部分
        }
        return kpIdSet.isEmpty() ? "无" : StringUtils.join(kpIdSet, ",");
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
    private List<PersonalizedRecommendation> parseRecommendContent(Long businessUserId, Long courseId, String recommendContent,
                                                                   List<QuestionKpRelationVo> questionRelationList,
                                                                   List<StudentLearnStatusVo> learnStatusList) {
        List<PersonalizedRecommendation> recommendationList = new ArrayList<>();
        // 核心修改1：调整正则，group(2)支持中文“无”（\\u4e00-\\u9fa5是中文Unicode范围）
        Pattern pattern = Pattern.compile(
                "【类型：([\\w,]+)】【目标ID：([\\d.,-\\u4e00-\\u9fa5]+)】【关联知识点：([\\d,]+)】(.*?)(?=\\s*【类型：|\\s*$)",
                Pattern.DOTALL
        );
        Matcher matcher = pattern.matcher(recommendContent);

        log.info("开始解析AI推荐内容，匹配正则表达式");
        while (matcher.find()) {
            // 解析AI返回的字段（原有逻辑不变，新增日志）
            String typeStr = matcher.group(1);
            String targetIds = matcher.group(2);
            String relatedKps = matcher.group(3);
            String reason = matcher.group(4).trim();

            log.debug("匹配到推荐条目：类型={}, 目标ID={}, 关联知识点={}", typeStr, targetIds, relatedKps);

            // 过滤无效数据（原有逻辑不变，补充relatedKps非空校验）
            if (StringUtils.isBlank(typeStr) || StringUtils.isBlank(targetIds) || StringUtils.isBlank(relatedKps) || StringUtils.isBlank(reason)) {
                log.warn("过滤无效推荐条目（存在空字段）：类型={}, 目标ID={}, 关联知识点={}", typeStr, targetIds, relatedKps);
                continue;
            }

            // 解析推荐类型（新增默认值处理）
            String[] typeArr = typeStr.split(",");
            String recommendType = typeArr.length > 0 ? typeArr[0].trim() : "resource";
            List<String> validTypes = Arrays.asList("video", "exercise", "resource", "kp_review");
            if (!validTypes.contains(recommendType)) {
                log.warn("过滤无效推荐类型：{}，有效类型={}", recommendType, validTypes);
                continue;
            }

            // 构建推荐对象
            PersonalizedRecommendation recommendation = new PersonalizedRecommendation();
            recommendation.setStudentUserId(businessUserId);
            recommendation.setCourseId(courseId);
            recommendation.setStatus("pending");
            recommendation.setPriority(3);
            recommendation.setAiModelVersion(aiModelVersion);
            recommendation.setExpireTime(LocalDateTime.now().plus(7, ChronoUnit.DAYS));
            recommendation.setIsDeleted(0);
            recommendation.setRecommendType(recommendType);
            recommendation.setRelatedKpIds(relatedKps); // 已做非空校验

            // 核心修改2：解析目标ID，处理“无”的情况
            String firstTargetId = targetIds.split(",")[0].trim()
                    .replace(".", "")
                    .replace("-", "")
                    .replace("无", ""); // 把“无”替换为空字符串
            if (StringUtils.isNotBlank(firstTargetId) && firstTargetId.matches("\\d+")) {
                recommendation.setTargetId(Long.parseLong(firstTargetId));
                log.debug("目标ID解析成功：{}", firstTargetId);
            } else {
                recommendation.setTargetId(0L); // 无有效目标ID时设为0L（满足非空约束）
                log.debug("目标ID无效或为“无”，设为默认值0L");
            }

            // 筛选无效错题（原有逻辑不变）
            String filteredReason = filterIrrelevantWrongQuestions(businessUserId, reason, relatedKps, questionRelationList, learnStatusList);
            recommendation.setRecommendReason(filteredReason.replaceAll("---", "").replaceAll("\\n+", "\n").trim());
            recommendation.setCreateTime(LocalDateTime.now());
            recommendation.setUpdateTime(LocalDateTime.now());

            recommendationList.add(recommendation);
            log.debug("推荐条目添加成功：{}", recommendation);
        }

        log.info("推荐内容解析完成，有效条目数：{}", recommendationList.size());
        return recommendationList;
    }
    private boolean checkIfNeedNewRecommendation(Long businessUserId, Long courseId, List<PersonalizedRecommendation> existingRecs) {
        // 1. 获取现有推荐的最新创建时间（取最新的一条，避免旧推荐影响）
        LocalDateTime latestRecCreateTime = existingRecs.stream()
                .map(PersonalizedRecommendation::getCreateTime)
                .filter(Objects::nonNull)
                .max(LocalDateTime::compareTo)
                .orElse(LocalDateTime.MIN); // 无创建时间则视为需要新推荐

        // 2. 查询用户在该课程下的最新学习行为时间（判断是否有新动作）
        // 2.1 最新答题时间（student_answer表：提交作业）
        LocalDateTime latestAnswerTime = studentAnswerMapper.selectLatestSubmitTimeByStudentAndCourse(businessUserId, courseId);
        // 2.2 最新视频学习时间（video_learning_behavior表：观看视频）
        LocalDateTime latestVideoTime = videoLearningBehaviorMapper.selectLatestUpdateTimeByStudentAndCourse(businessUserId, courseId);

        // 3. 取所有学习行为的最新时间
        LocalDateTime latestLearnTime = LocalDateTime.MIN;
        if (latestAnswerTime != null && latestAnswerTime.isAfter(latestLearnTime)) {
            latestLearnTime = latestAnswerTime;
        }
        if (latestVideoTime != null && latestVideoTime.isAfter(latestLearnTime)) {
            latestLearnTime = latestVideoTime;
        }

        // 4. 核心判断：如果最新学习行为时间 > 现有推荐的创建时间 → 需要生成新推荐
        boolean needNew = latestLearnTime.isAfter(latestRecCreateTime);
        log.info("现有推荐最新创建时间：{}，用户最新学习行为时间：{}，是否需要新推荐：{}",
                latestRecCreateTime, latestLearnTime, needNew);
        return needNew;
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
