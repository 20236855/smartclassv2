package com.ruoyi.system.domain.vo;

/**
 * 能力雷达图VO（仅用于前端数据渲染，不关联数据库表）
 */
public class CompetencyRadarVo {
    /** 能力点名称（对应 course_competency.competency_name） */
    private String competencyName;

    /** 能力点加权分数（计算结果，保留1位小数） */
    private Double competencyScore;

    // 手动生成getter和setter（无Lombok也能正常使用）
    public String getCompetencyName() {
        return competencyName;
    }

    public void setCompetencyName(String competencyName) {
        this.competencyName = competencyName;
    }

    public Double getCompetencyScore() {
        return competencyScore;
    }

    public void setCompetencyScore(Double competencyScore) {
        this.competencyScore = competencyScore;
    }
}

