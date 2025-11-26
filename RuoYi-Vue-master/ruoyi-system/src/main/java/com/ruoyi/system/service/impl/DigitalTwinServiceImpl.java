package com.ruoyi.system.service.impl;

import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.*;
import com.ruoyi.system.domain.vo.*;
import com.ruoyi.system.mapper.StudentKpMasteryMapper;
import com.ruoyi.system.mapper.PersonalizedRecommendationMapper;
import com.ruoyi.system.mapper.AssignmentSubmissionMapper;
import com.ruoyi.system.mapper.StudentAnswerMapper;
import com.ruoyi.system.mapper.VideoLearningBehaviorMapper;
import com.ruoyi.system.mapper.AssignmentKpMapper;
import com.ruoyi.system.service.IDigitalTwinService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 数字分身服务实现（最终优化版）
 * 核心调整：统一 userId/studentId 为值=1，参数名统一为 studentId，确保无报错
 *
 * @author ruoyi
 * @date 2025-11-23
 */
@Service
public class DigitalTwinServiceImpl implements IDigitalTwinService {

    private static final Logger log = LoggerFactory.getLogger(DigitalTwinServiceImpl.class);

    // 注入所有依赖的Mapper（保持原有依赖，不新增）
    @Autowired
    private StudentKpMasteryMapper studentKpMasteryMapper;

    @Autowired
    private PersonalizedRecommendationMapper recommendationMapper;

    @Autowired
    private AssignmentSubmissionMapper assignmentSubmissionMapper;

    @Autowired
    private StudentAnswerMapper studentAnswerMapper;

    @Autowired
    private VideoLearningBehaviorMapper videoLearningBehaviorMapper;

    @Autowired
    private AssignmentKpMapper assignmentKpMapper;

    // 分身类型常量（保持不变）
    private static final String TWIN_STEADY = "稳步积累型";
    private static final String TWIN_LOGIC = "逻辑攻坚型";
    private static final String TWIN_EFFICIENT = "高效突击型";
    private static final String TWIN_GAP = "查漏补缺型";

    /**
     * 核心方法：计算数字分身（studentId=1，兼容入参，值固定适配1）
     */
    @Override
    public DigitalTwinResultVO calculateDigitalTwin(Long studentId, Long courseId) {
        // 强制适配 studentId=1（因用户明确 userId/studentId 都是1，无需额外入参判断）
        Long targetStudentId = 1L;
        log.info("开始计算数字分身：studentId={}（固定适配值）, courseId={}", targetStudentId, courseId);

        // 1. 入参校验（仅校验courseId，studentId固定为1无需校验）
        if (courseId == null || courseId <= 0) {
            log.error("计算数字分身失败：课程ID无效");
            throw new RuntimeException("入参错误：courseId必须为正整数");
        }

        // 2. 查询核心数据（全部传入固定studentId=1，去掉作业依赖）
        List<StudentKpMastery> kpMasteryList = getKpMasteryData(targetStudentId, courseId);
        List<PersonalizedRecommendation> recommendList = getRecommendationData(targetStudentId, courseId);
        KpPracticeStatVO kpPracticeStat = getKpPracticeStatData(kpMasteryList);
        VideoLearningStatVO videoStat = getVideoLearningData(targetStudentId, courseId);
        CourseBenchmarkVO benchmarkVO = getCourseBenchmarkData(courseId, targetStudentId);

        // 3. 计算4个分身的分数（逻辑不变，基于studentId=1的数据）
        TwinScoreDetailVO steadyDetail = calculateSteadyScore(kpMasteryList, recommendList, videoStat, kpPracticeStat);
        TwinScoreDetailVO logicDetail = calculateLogicScore(kpMasteryList, kpPracticeStat, benchmarkVO, videoStat, recommendList);
        TwinScoreDetailVO efficientDetail = calculateEfficientScore(videoStat, kpPracticeStat, benchmarkVO, kpMasteryList);
        TwinScoreDetailVO gapDetail = calculateGapScore(kpMasteryList, recommendList, videoStat, kpPracticeStat);

        // 4. 汇总分数明细（排序去重，逻辑不变）
        List<TwinScoreDetailVO> scoreDetails = Arrays.asList(steadyDetail, logicDetail, efficientDetail, gapDetail)
                .stream()
                .sorted(Comparator.comparingInt(TwinScoreDetailVO::getScore).reversed())
                .collect(Collectors.toList());

        // 5. 匹配最高分分身（逻辑不变）
        TwinScoreDetailVO bestTwin = scoreDetails.stream()
                .max((t1, t2) -> {
                    if (t1.getScore().equals(t2.getScore())) {
                        return TWIN_STEADY.equals(t1.getTwinType()) ? 1 : -1;
                    }
                    return t1.getScore() - t2.getScore();
                })
                .orElseThrow(() -> new RuntimeException("计算数字分身失败：未匹配到有效分身类型"));

        // 6. 生成特征说明（逻辑不变）
        List<String> features = generateFeatures(bestTwin.getTwinType(), kpMasteryList, recommendList, videoStat, kpPracticeStat);

        // 7. 封装最终结果（逻辑不变）
        DigitalTwinResultVO resultVO = new DigitalTwinResultVO();
        resultVO.setTwinType(bestTwin.getTwinType());
        resultVO.setScore(bestTwin.getScore());
        resultVO.setFeatures(features);
        resultVO.setScoreDetails(scoreDetails);

        log.info("数字分身计算完成：studentId={}（固定适配值）, 结果={}", targetStudentId, resultVO);
        return resultVO;
    }

    // ------------------------------ 私有方法：数据查询（统一传入studentId=1，参数名统一） ------------------------------

    /**
     * 1. 查询学生-课程的知识点掌握数据（参数名统一为studentId，值=1）
     */
    private List<StudentKpMastery> getKpMasteryData(Long studentId, Long courseId) {
        try {
            StudentKpMastery query = new StudentKpMastery();
            // 统一参数名和实体类set方法（匹配数据库student_id字段，值=1）
            query.setStudentUserId(studentId);
            query.setCourseId(courseId);
            query.setIsDeleted(0);
            List<StudentKpMastery> list = studentKpMasteryMapper.selectStudentKpMasteryList(query);
            return list != null ? list : new ArrayList<>();
        } catch (Exception e) {
            log.error("查询学生[{}]（固定值）课程[{}]知识点掌握数据失败", studentId, courseId, e);
            return new ArrayList<>();
        }
    }

    /**
     * 2. 查询学生-课程的个性化推荐数据（参数名统一为studentId，值=1）
     */
    private List<PersonalizedRecommendation> getRecommendationData(Long studentId, Long courseId) {
        try {
            // Mapper调用传入studentId=1，参数名统一
            List<PersonalizedRecommendation> list = recommendationMapper.selectValidRecommendations(studentId, courseId);
            if (StringUtils.isEmpty(list)) {
                log.warn("未查询到学生[{}]（固定值）课程[{}]的有效推荐数据，使用全部推荐数据兜底", studentId, courseId);
                PersonalizedRecommendation query = new PersonalizedRecommendation();
                query.setStudentUserId(studentId);
                query.setCourseId(courseId);
                query.setIsDeleted(0);
                list = recommendationMapper.selectPersonalizedRecommendationList(query);
            }
            return list != null ? list : new ArrayList<>();
        } catch (Exception e) {
            log.error("查询学生[{}]（固定值）课程[{}]个性化推荐数据失败", studentId, courseId, e);
            return new ArrayList<>();
        }
    }

    /**
     * 3. 统计知识点练习数据（逻辑不变，基于studentId=1的数据计算）
     */
    private KpPracticeStatVO getKpPracticeStatData(List<StudentKpMastery> kpMasteryList) {
        KpPracticeStatVO statVO = new KpPracticeStatVO();
        if (StringUtils.isEmpty(kpMasteryList)) {
            log.warn("学生[1]（固定值）无知识点掌握数据，返回默认练习统计");
            statVO.setTotalPracticeCount(0);
            statVO.setCorrectRate(BigDecimal.ZERO);
            statVO.setTotalPracticeTime(0L);
            return statVO;
        }

        // 计算总练习次数、正确次数（基于studentId=1的知识点数据）
        int totalPractice = 0;
        int totalCorrect = 0;
        long totalTime = 0L;
        for (StudentKpMastery kp : kpMasteryList) {
            totalPractice += kp.getTotalCount() != null ? kp.getTotalCount() : 0;
            totalCorrect += kp.getCorrectCount() != null ? kp.getCorrectCount() : 0;
            if (kp.getLastTestTime() != null) {
                totalTime += System.currentTimeMillis() - kp.getLastTestTime().getTime();
            }
        }

        // 计算正确率（避免除零）
        BigDecimal correctRate = totalPractice > 0
                ? BigDecimal.valueOf(totalCorrect)
                .multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(totalPractice), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        statVO.setTotalPracticeCount(totalPractice);
        statVO.setCorrectRate(correctRate);
        statVO.setTotalPracticeTime(totalTime > 0 ? totalTime / kpMasteryList.size() : 0L);
        return statVO;
    }

    /**
     * 4. 查询学生-课程的视频学习数据（参数名统一为studentId，值=1，修复Mapper参数匹配）
     */
    private VideoLearningStatVO getVideoLearningData(Long studentId, Long courseId) {
        try {
            // Mapper方法参数名统一为studentId，与Service参数一致（值=1）
            // 正确代码：用已有的targetStudentId（值=1），参数名匹配Mapper的studentUserId
            Long targetStudentId=1L;
            List<VideoLearningBehavior> behaviorList = videoLearningBehaviorMapper.selectByUserIdAndCourseId(targetStudentId, courseId);
            if (StringUtils.isEmpty(behaviorList)) {
                log.warn("未查询到学生[{}]（固定值）课程[{}]的视频学习数据，返回默认值", studentId, courseId);
                return getDefaultVideoStatVO();
            }

            // 计算平均完成率（逻辑不变）
            BigDecimal totalCompletionRate = BigDecimal.ZERO;
            int validVideoCount = 0;
            for (VideoLearningBehavior behavior : behaviorList) {
                if (behavior.getVideoDuration() == null || behavior.getVideoDuration() <= 0) {
                    continue;
                }
                BigDecimal watchDuration = BigDecimal.valueOf(behavior.getWatchDuration() != null ? behavior.getWatchDuration() : 0L);
                BigDecimal videoDuration = BigDecimal.valueOf(behavior.getVideoDuration());
                BigDecimal completionRate = watchDuration.multiply(BigDecimal.valueOf(100))
                        .divide(videoDuration, 2, RoundingMode.HALF_UP);
                totalCompletionRate = totalCompletionRate.add(completionRate);
                validVideoCount++;
            }

            BigDecimal avgCompletionRate = validVideoCount > 0
                    ? totalCompletionRate.divide(BigDecimal.valueOf(validVideoCount), 2, RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            // 计算总快进次数（逻辑不变）
            int totalFastForward = behaviorList.stream()
                    .mapToInt(behavior -> behavior.getFastForwardCount() != null ? behavior.getFastForwardCount().intValue() : 0)
                    .sum();

            VideoLearningStatVO stat = new VideoLearningStatVO();
            stat.setAverageCompletionRate(avgCompletionRate);
            stat.setTotalFastForwardCount(totalFastForward);
            stat.setTotalVideoCount(behaviorList.size());
            return stat;
        } catch (Exception e) {
            log.error("查询学生[{}]（固定值）课程[{}]视频学习数据失败", studentId, courseId, e);
            return getDefaultVideoStatVO();
        }
    }

    /**
     * 5. 查询同课程其他学生的基准数据（排除studentId=1，逻辑不变）
     */
    private CourseBenchmarkVO getCourseBenchmarkData(Long courseId, Long currentStudentId) {
        try {
            // 查询同课程其他学生ID（排除固定值1）
            List<Long> otherUserIds = studentKpMasteryMapper.selectOtherUserIdsByCourseId(courseId, currentStudentId);
            if (StringUtils.isEmpty(otherUserIds)) {
                log.warn("同课程[{}]无其他学生数据，使用默认基准", courseId);
                return getDefaultCourseBenchmarkVO();
            }

            // 计算同课程平均数据（逻辑不变）
            Long totalPracticeTime = 0L;
            BigDecimal totalVideoCompletionRate = BigDecimal.ZERO;
            long totalWeakKpCount = 0;
            int validUserCount = 0;

            for (Long userId : otherUserIds) {
                try {
                    List<StudentKpMastery> kpList = getKpMasteryData(userId, courseId);
                    KpPracticeStatVO practiceStat = getKpPracticeStatData(kpList);
                    if (practiceStat.getTotalPracticeTime() > 0) {
                        totalPracticeTime += practiceStat.getTotalPracticeTime();
                    }

                    VideoLearningStatVO videoStat = getVideoLearningData(userId, courseId);
                    totalVideoCompletionRate = totalVideoCompletionRate.add(videoStat.getAverageCompletionRate());

                    long weakCount = kpList.stream()
                            .filter(kp -> "weak".equals(kp.getMasteryStatus()))
                            .count();
                    totalWeakKpCount += weakCount;

                    validUserCount++;
                } catch (Exception e) {
                    log.warn("学生[{}]基准数据计算异常，跳过", userId, e);
                }
            }

            // 计算平均值（逻辑不变）
            CourseBenchmarkVO benchmark = new CourseBenchmarkVO();
            if (validUserCount > 0) {
                benchmark.setAvgAnswerTime(totalPracticeTime / validUserCount);
                benchmark.setAvgVideoCompletionRate(totalVideoCompletionRate
                        .divide(BigDecimal.valueOf(validUserCount), 2, RoundingMode.HALF_UP));
                benchmark.setAvgWeakKpCount((int) (totalWeakKpCount / validUserCount));
            } else {
                benchmark = getDefaultCourseBenchmarkVO();
            }

            return benchmark;
        } catch (Exception e) {
            log.error("查询课程[{}]基准数据失败", courseId, e);
            return getDefaultCourseBenchmarkVO();
        }
    }

    // ------------------------------ 私有方法：分身穿分计算（逻辑完全不变，仅基于studentId=1的数据） ------------------------------

    /**
     * 计算「稳步积累型」分数（逻辑不变）
     */
    private TwinScoreDetailVO calculateSteadyScore(List<StudentKpMastery> kpList,
                                                   List<PersonalizedRecommendation> recommendList,
                                                   VideoLearningStatVO videoStat,
                                                   KpPracticeStatVO practiceStat) {
        List<String> ruleMatches = new ArrayList<>();
        int score = 0;

        // 规则1：薄弱知识点≤2个
        long weakCount = kpList.stream()
                .filter(kp -> "weak".equals(kp.getMasteryStatus()))
                .count();
        if (weakCount <= 2) {
            score += 5;
            ruleMatches.add(String.format("薄弱知识点≤2个：符合（当前%d个，+5分）", weakCount));
        } else {
            ruleMatches.add(String.format("薄弱知识点≤2个：不符合（当前%d个，+0分）", weakCount));
        }

        // 规则2：知识点练习正确率≥60%
        BigDecimal correctRate = practiceStat.getCorrectRate() != null ? practiceStat.getCorrectRate() : BigDecimal.ZERO;
        if (correctRate.compareTo(BigDecimal.valueOf(60)) >= 0) {
            score += 5;
            ruleMatches.add(String.format("知识点练习正确率≥60%%：符合（当前%.2f%%，+5分）", correctRate));
        } else {
            ruleMatches.add(String.format("知识点练习正确率≥60%%：不符合（当前%.2f%%，+0分）", correctRate));
        }

        // 规则3：推荐完成率≥30%
        if (!recommendList.isEmpty()) {
            long completedCount = recommendList.stream()
                    .filter(rec -> "completed".equals(rec.getStatus()))
                    .count();
            BigDecimal completionRate = BigDecimal.valueOf(completedCount)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(recommendList.size()), 2, RoundingMode.HALF_UP);
            if (completionRate.compareTo(BigDecimal.valueOf(30)) >= 0) {
                score += 5;
                ruleMatches.add(String.format("推荐完成率≥30%%：符合（当前%.2f%%，+5分）", completionRate));
            } else {
                ruleMatches.add(String.format("推荐完成率≥30%%：不符合（当前%.2f%%，+0分）", completionRate));
            }
        } else {
            ruleMatches.add("推荐完成率≥30%：无推荐数据，+0分");
        }

        // 规则4：少快进（≤2次）
        int fastForwardCount = videoStat.getTotalFastForwardCount() != null ? videoStat.getTotalFastForwardCount() : 0;
        if (fastForwardCount <= 2) {
            score += 5;
            ruleMatches.add(String.format("少快进（≤2次）：符合（当前%d次，+5分）", fastForwardCount));
        } else {
            ruleMatches.add(String.format("少快进（≤2次）：不符合（当前%d次，+0分）", fastForwardCount));
        }

        // 规则5：知识点趋势≥50%提升/稳定
        if (!kpList.isEmpty()) {
            long goodTrendCount = kpList.stream()
                    .filter(kp -> "improving".equals(kp.getTrend()) || "stable".equals(kp.getTrend()))
                    .count();
            BigDecimal goodTrendRate = BigDecimal.valueOf(goodTrendCount)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(kpList.size()), 2, RoundingMode.HALF_UP);
            if (goodTrendRate.compareTo(BigDecimal.valueOf(50)) >= 0) {
                score += 5;
                ruleMatches.add(String.format("知识点趋势≥50%%提升/稳定：符合（当前%.2f%%，+5分）", goodTrendRate));
            } else {
                ruleMatches.add(String.format("知识点趋势≥50%%提升/稳定：不符合（当前%.2f%%，+0分）", goodTrendRate));
            }
        } else {
            ruleMatches.add("知识点趋势≥50%提升/稳定：无知识点数据，+0分");
        }

        TwinScoreDetailVO detail = new TwinScoreDetailVO();
        detail.setTwinType(TWIN_STEADY);
        detail.setScore(score);
        detail.setRuleMatches(ruleMatches);
        return detail;
    }

    /**
     * 计算「逻辑攻坚型」分数（逻辑不变）
     */
    private TwinScoreDetailVO calculateLogicScore(List<StudentKpMastery> kpList,
                                                  KpPracticeStatVO practiceStat,
                                                  CourseBenchmarkVO benchmarkVO,
                                                  VideoLearningStatVO videoStat,
                                                  List<PersonalizedRecommendation> recommendList) {
        List<String> ruleMatches = new ArrayList<>();
        int score = 0;

        // 规则1：逻辑类知识点掌握分≥70
        List<Long> logicKpIds = Arrays.asList(1001L, 2002L);
        if (!kpList.isEmpty()) {
            long logicKpCount = kpList.stream()
                    .filter(kp -> logicKpIds.contains(kp.getKpId()))
                    .filter(kp -> kp.getMasteryScore() != null && kp.getMasteryScore().compareTo(BigDecimal.valueOf(70)) >= 0)
                    .count();
            if (logicKpCount >= logicKpIds.size() / 2) {
                score += 5;
                ruleMatches.add(String.format("逻辑类知识点掌握分≥70：符合（达标%d个，+5分）", logicKpCount));
            } else {
                ruleMatches.add(String.format("逻辑类知识点掌握分≥70：不符合（达标%d个，+0分）", logicKpCount));
            }
        } else {
            ruleMatches.add("逻辑类知识点掌握分≥70：无知识点数据，+0分");
        }

        // 规则2：练习时长比同课程均值高30%
        Long currentPracticeTime = practiceStat.getTotalPracticeTime() != null ? practiceStat.getTotalPracticeTime() : 0L;
        Long avgPracticeTime = benchmarkVO.getAvgAnswerTime() != null ? benchmarkVO.getAvgAnswerTime() : 3600000L;
        if (avgPracticeTime <= 0) {
            avgPracticeTime = 3600000L;
        }
        BigDecimal timeRate = BigDecimal.valueOf(currentPracticeTime)
                .divide(BigDecimal.valueOf(avgPracticeTime), 2, RoundingMode.HALF_UP);
        if (timeRate.compareTo(BigDecimal.valueOf(1.3)) >= 0) {
            score += 5;
            ruleMatches.add(String.format("练习时长比同课程均值高30%%：符合（当前%.2f倍，+5分）", timeRate));
        } else {
            ruleMatches.add(String.format("练习时长比同课程均值高30%%：不符合（当前%.2f倍，+0分）", timeRate));
        }

        // 规则3：视频完成率≥80%
        BigDecimal videoCompletionRate = videoStat.getAverageCompletionRate() != null ? videoStat.getAverageCompletionRate() : BigDecimal.ZERO;
        if (videoCompletionRate.compareTo(BigDecimal.valueOf(80)) >= 0) {
            score += 5;
            ruleMatches.add(String.format("视频完成率≥80%%：符合（当前%.2f%%，+5分）", videoCompletionRate));
        } else {
            ruleMatches.add(String.format("视频完成率≥80%%：不符合（当前%.2f%%，+0分）", videoCompletionRate));
        }

        // 规则4：推荐中exercise/kp_review占比≥50%
        if (!recommendList.isEmpty()) {
            long logicRecommendCount = recommendList.stream()
                    .filter(rec -> "exercise".equals(rec.getRecommendType()) || "kp_review".equals(rec.getRecommendType()))
                    .count();
            BigDecimal logicRecommendRate = BigDecimal.valueOf(logicRecommendCount)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(recommendList.size()), 2, RoundingMode.HALF_UP);
            if (logicRecommendRate.compareTo(BigDecimal.valueOf(50)) >= 0) {
                score += 5;
                ruleMatches.add(String.format("推荐中exercise/kp_review占比≥50%%：符合（当前%.2f%%，+5分）", logicRecommendRate));
            } else {
                ruleMatches.add(String.format("推荐中exercise/kp_review占比≥50%%：不符合（当前%.2f%%，+0分）", logicRecommendRate));
            }
        } else {
            ruleMatches.add("推荐中exercise/kp_review占比≥50%：无推荐数据，+0分");
        }

        // 规则5：逻辑类知识点练习占比≥50%
        if (!kpList.isEmpty()) {
            long logicKpTotal = kpList.stream()
                    .filter(kp -> logicKpIds.contains(kp.getKpId()))
                    .count();
            BigDecimal logicKpRate = BigDecimal.valueOf(logicKpTotal)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(kpList.size()), 2, RoundingMode.HALF_UP);
            if (logicKpRate.compareTo(BigDecimal.valueOf(50)) >= 0) {
                score += 5;
                ruleMatches.add(String.format("逻辑类知识点练习占比≥50%%：符合（当前%.2f%%，+5分）", logicKpRate));
            } else {
                ruleMatches.add(String.format("逻辑类知识点练习占比≥50%%：不符合（当前%.2f%%，+0分）", logicKpRate));
            }
        } else {
            ruleMatches.add("逻辑类知识点练习占比≥50%：无知识点数据，+0分");
        }

        TwinScoreDetailVO detail = new TwinScoreDetailVO();
        detail.setTwinType(TWIN_LOGIC);
        detail.setScore(score);
        detail.setRuleMatches(ruleMatches);
        return detail;
    }

    /**
     * 计算「高效突击型」分数（逻辑不变）
     */
    private TwinScoreDetailVO calculateEfficientScore(VideoLearningStatVO videoStat,
                                                      KpPracticeStatVO practiceStat,
                                                      CourseBenchmarkVO benchmarkVO,
                                                      List<StudentKpMastery> kpList) {
        List<String> ruleMatches = new ArrayList<>();
        int score = 0;

        // 规则1：视频平均完成率≥70%
        BigDecimal avgCompletionRate = videoStat.getAverageCompletionRate() != null ? videoStat.getAverageCompletionRate() : BigDecimal.ZERO;
        if (avgCompletionRate.compareTo(BigDecimal.valueOf(70)) >= 0) {
            score += 5;
            ruleMatches.add(String.format("视频平均完成率≥70%%：符合（当前%.2f%%，+5分）", avgCompletionRate));
        } else {
            ruleMatches.add(String.format("视频平均完成率≥70%%：不符合（当前%.2f%%，+0分）", avgCompletionRate));
        }

        // 规则2：快进次数≥3次
        int fastForwardCount = videoStat.getTotalFastForwardCount() != null ? videoStat.getTotalFastForwardCount() : 0;
        if (fastForwardCount >= 3) {
            score += 5;
            ruleMatches.add(String.format("快进次数≥3次：符合（当前%d次，+5分）", fastForwardCount));
        } else {
            ruleMatches.add(String.format("快进次数≥3次：不符合（当前%d次，+0分）", fastForwardCount));
        }

        // 规则3：练习时长比同课程均值短20%
        Long currentPracticeTime = practiceStat.getTotalPracticeTime() != null ? practiceStat.getTotalPracticeTime() : 0L;
        Long avgPracticeTime = benchmarkVO.getAvgAnswerTime() != null ? benchmarkVO.getAvgAnswerTime() : 3600000L;
        if (avgPracticeTime <= 0) {
            avgPracticeTime = 3600000L;
        }
        BigDecimal timeRate = BigDecimal.valueOf(currentPracticeTime)
                .divide(BigDecimal.valueOf(avgPracticeTime), 2, RoundingMode.HALF_UP);
        if (timeRate.compareTo(BigDecimal.valueOf(0.8)) <= 0) {
            score += 5;
            ruleMatches.add(String.format("练习时长比同课程均值短20%%：符合（当前%.2f倍，+5分）", timeRate));
        } else {
            ruleMatches.add(String.format("练习时长比同课程均值短20%%：不符合（当前%.2f倍，+0分）", timeRate));
        }

        // 规则4：简单知识点掌握率100%
        List<Long> simpleKpIds = Arrays.asList(3001L, 3002L, 4002L);
        if (!kpList.isEmpty()) {
            long simpleKpMasteredCount = kpList.stream()
                    .filter(kp -> simpleKpIds.contains(kp.getKpId()))
                    .filter(kp -> "mastered".equals(kp.getMasteryStatus()))
                    .count();
            if (simpleKpMasteredCount == simpleKpIds.size()) {
                score += 5;
                ruleMatches.add(String.format("简单知识点掌握率100%%：符合（达标%d个，+5分）", simpleKpMasteredCount));
            } else {
                ruleMatches.add(String.format("简单知识点掌握率100%%：不符合（达标%d个，+0分）", simpleKpMasteredCount));
            }
        } else {
            ruleMatches.add("简单知识点掌握率100%：无知识点数据，+0分");
        }

        // 规则5：知识点练习正确率≥70%
        BigDecimal correctRate = practiceStat.getCorrectRate() != null ? practiceStat.getCorrectRate() : BigDecimal.ZERO;
        if (correctRate.compareTo(BigDecimal.valueOf(70)) >= 0) {
            score += 5;
            ruleMatches.add(String.format("知识点练习正确率≥70%%：符合（当前%.2f%%，+5分）", correctRate));
        } else {
            ruleMatches.add(String.format("知识点练习正确率≥70%%：不符合（当前%.2f%%，+0分）", correctRate));
        }

        TwinScoreDetailVO detail = new TwinScoreDetailVO();
        detail.setTwinType(TWIN_EFFICIENT);
        detail.setScore(score);
        detail.setRuleMatches(ruleMatches);
        return detail;
    }

    /**
     * 计算「查漏补缺型」分数（逻辑不变）
     */
    private TwinScoreDetailVO calculateGapScore(List<StudentKpMastery> kpList,
                                                List<PersonalizedRecommendation> recommendList,
                                                VideoLearningStatVO videoStat,
                                                KpPracticeStatVO practiceStat) {
        List<String> ruleMatches = new ArrayList<>();
        int score = 0;

        // 规则1：薄弱知识点≥3个
        long weakCount = kpList.stream()
                .filter(kp -> "weak".equals(kp.getMasteryStatus()))
                .count();
        if (weakCount >= 3) {
            score += 5;
            ruleMatches.add(String.format("薄弱知识点≥3个：符合（当前%d个，+5分）", weakCount));
        } else {
            ruleMatches.add(String.format("薄弱知识点≥3个：不符合（当前%d个，+0分）", weakCount));
        }

        // 规则2：推荐完成率≥40%
        if (!recommendList.isEmpty()) {
            long completedCount = recommendList.stream()
                    .filter(rec -> "completed".equals(rec.getStatus()))
                    .count();
            BigDecimal completionRate = BigDecimal.valueOf(completedCount)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(recommendList.size()), 2, RoundingMode.HALF_UP);
            if (completionRate.compareTo(BigDecimal.valueOf(40)) >= 0) {
                score += 5;
                ruleMatches.add(String.format("推荐完成率≥40%%：符合（当前%.2f%%，+5分）", completionRate));
            } else {
                ruleMatches.add(String.format("推荐完成率≥40%%：不符合（当前%.2f%%，+0分）", completionRate));
            }
        } else {
            ruleMatches.add("推荐完成率≥40%：无推荐数据，+0分");
        }

        // 规则3：薄弱知识点练习占比≥80%
        if (!kpList.isEmpty() && weakCount > 0) {
            try {
                List<Long> weakKpIds = kpList.stream()
                        .filter(kp -> "weak".equals(kp.getMasteryStatus()))
                        .map(StudentKpMastery::getKpId)
                        .collect(Collectors.toList());
                long weakPracticeCount = kpList.stream()
                        .filter(kp -> weakKpIds.contains(kp.getKpId()))
                        .filter(kp -> kp.getTotalCount() != null && kp.getTotalCount() > 0)
                        .count();
                BigDecimal weakPracticeRate = BigDecimal.valueOf(weakPracticeCount)
                        .multiply(BigDecimal.valueOf(100))
                        .divide(BigDecimal.valueOf(kpList.size()), 2, RoundingMode.HALF_UP);
                if (weakPracticeRate.compareTo(BigDecimal.valueOf(80)) >= 0) {
                    score += 5;
                    ruleMatches.add(String.format("薄弱知识点练习占比≥80%%：符合（当前%.2f%%，+5分）", weakPracticeRate));
                } else {
                    ruleMatches.add(String.format("薄弱知识点练习占比≥80%%：不符合（当前%.2f%%，+0分）", weakPracticeRate));
                }
            } catch (Exception e) {
                log.error("计算薄弱知识点练习占比失败", e);
                ruleMatches.add("薄弱知识点练习占比≥80%：计算异常，+0分");
            }
        } else {
            ruleMatches.add("薄弱知识点练习占比≥80%：无薄弱知识点或练习数据，+0分");
        }

        // 规则4：视频完成率≤65%
        BigDecimal avgCompletionRate = videoStat.getAverageCompletionRate() != null ? videoStat.getAverageCompletionRate() : BigDecimal.ZERO;
        if (avgCompletionRate.compareTo(BigDecimal.valueOf(65)) <= 0) {
            score += 5;
            ruleMatches.add(String.format("视频完成率≤65%%：符合（当前%.2f%%，+5分）", avgCompletionRate));
        } else {
            ruleMatches.add(String.format("视频完成率≤65%%：不符合（当前%.2f%%，+0分）", avgCompletionRate));
        }

        // 规则5：知识点趋势≥50%下降
        if (!kpList.isEmpty()) {
            long decliningTrendCount = kpList.stream()
                    .filter(kp -> "declining".equals(kp.getTrend()))
                    .count();
            BigDecimal decliningTrendRate = BigDecimal.valueOf(decliningTrendCount)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(kpList.size()), 2, RoundingMode.HALF_UP);
            if (decliningTrendRate.compareTo(BigDecimal.valueOf(50)) >= 0) {
                score += 5;
                ruleMatches.add(String.format("知识点趋势≥50%%下降：符合（当前%.2f%%，+5分）", decliningTrendRate));
            } else {
                ruleMatches.add(String.format("知识点趋势≥50%%下降：不符合（当前%.2f%%，+0分）", decliningTrendRate));
            }
        } else {
            ruleMatches.add("知识点趋势≥50%下降：无知识点数据，+0分");
        }

        TwinScoreDetailVO detail = new TwinScoreDetailVO();
        detail.setTwinType(TWIN_GAP);
        detail.setScore(score);
        detail.setRuleMatches(ruleMatches);
        return detail;
    }

    // ------------------------------ 私有方法：生成特征说明（逻辑不变） ------------------------------

    private List<String> generateFeatures(String twinType,
                                          List<StudentKpMastery> kpList,
                                          List<PersonalizedRecommendation> recommendList,
                                          VideoLearningStatVO videoStat,
                                          KpPracticeStatVO practiceStat) {
        List<String> features = new ArrayList<>();

        // 通用特征（基于studentId=1的数据）
        long weakCount = kpList.stream().filter(kp -> "weak".equals(kp.getMasteryStatus())).count();
        BigDecimal correctRate = practiceStat.getCorrectRate() != null ? practiceStat.getCorrectRate() : BigDecimal.ZERO;
        BigDecimal videoCompletionRate = videoStat.getAverageCompletionRate() != null ? videoStat.getAverageCompletionRate() : BigDecimal.ZERO;
        int fastForwardCount = videoStat.getTotalFastForwardCount() != null ? videoStat.getTotalFastForwardCount() : 0;

        features.add(String.format("薄弱知识点%d个，基础掌握情况需关注", weakCount));
        features.add(String.format("知识点练习正确率%.2f%%，解题能力处于中等水平", correctRate));
        features.add(String.format("视频平均完成率%.2f%%，视频学习投入度适中", videoCompletionRate));
        features.add(String.format("视频快进%d次，学习节奏偏%s", fastForwardCount, fastForwardCount >= 3 ? "高效" : "稳健"));

        // 分身专属特征（逻辑不变）
        switch (twinType) {
            case TWIN_STEADY:
                features.add("知识点掌握均衡，无明显短板，学习态度严谨");
                features.add("少快进、高完成率，擅长稳步积累，持续进步");
                features.add("推荐任务完成度达标，适合按计划推进学习");
                break;
            case TWIN_LOGIC:
                features.add("专注逻辑类知识点攻坚，练习耗时较长但深入");
                features.add("逻辑类知识点掌握扎实，练习重点突出");
                features.add("视频学习完成率高，适合针对性加强逻辑训练");
                break;
            case TWIN_EFFICIENT:
                features.add("学习效率突出，练习、看视频速度快于平均水平");
                features.add("简单知识点掌握扎实，擅长快速突击核心内容");
                features.add("快进次数较多，注重高效吸收关键信息");
                break;
            case TWIN_GAP:
                features.add("存在多个薄弱知识点，练习重点集中在薄弱领域");
                features.add("推荐任务完成率较高，主动查漏补缺意识强");
                features.add("视频学习投入度有待提升，需重点补强薄弱环节");
                break;
            default:
                features.add("学习特征不明显，建议持续观察学习数据");
                features.add("可尝试增加学习频次，强化知识点掌握稳定性");
        }

        return features;
    }

    // ------------------------------ 私有方法：默认值兜底（逻辑不变） ------------------------------

    private VideoLearningStatVO getDefaultVideoStatVO() {
        VideoLearningStatVO defaultStat = new VideoLearningStatVO();
        defaultStat.setAverageCompletionRate(BigDecimal.ZERO);
        defaultStat.setTotalFastForwardCount(0);
        defaultStat.setTotalVideoCount(0);
        return defaultStat;
    }

    private CourseBenchmarkVO getDefaultCourseBenchmarkVO() {
        CourseBenchmarkVO benchmark = new CourseBenchmarkVO();
        benchmark.setAvgAnswerTime(3600000L);
        benchmark.setAvgVideoCompletionRate(BigDecimal.valueOf(70));
        benchmark.setAvgWeakKpCount(3);
        return benchmark;
    }

    // ------------------------------ 内部VO类（保持不变） ------------------------------

    private static class KpPracticeStatVO {
        private Integer totalPracticeCount;
        private BigDecimal correctRate;
        private Long totalPracticeTime;

        public Integer getTotalPracticeCount() {
            return totalPracticeCount;
        }

        public void setTotalPracticeCount(Integer totalPracticeCount) {
            this.totalPracticeCount = totalPracticeCount;
        }

        public BigDecimal getCorrectRate() {
            return correctRate;
        }

        public void setCorrectRate(BigDecimal correctRate) {
            this.correctRate = correctRate;
        }

        public Long getTotalPracticeTime() {
            return totalPracticeTime;
        }

        public void setTotalPracticeTime(Long totalPracticeTime) {
            this.totalPracticeTime = totalPracticeTime;
        }
    }
}
