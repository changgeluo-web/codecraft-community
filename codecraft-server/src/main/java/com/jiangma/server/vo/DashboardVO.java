package com.jiangma.server.vo;

import lombok.Data;
import java.util.List;

@Data
public class DashboardVO {
    private Long totalProjects;      // 项目总数（category 数）
    private Long totalKnowledge;     // 知识点总数
    private Long totalMastered;      // 已掌握数
    private Double overallProgress;  // 总体进度百分比
    private List<ProjectStat> projects; // 各项目统计

    @Data
    public static class ProjectStat {
        private Long categoryId;
        private String projectName;
        private String description;
        private Long total;
        private Long pending;
        private Long studying;
        private Long mastered;
        private Double progress;
    }
}
