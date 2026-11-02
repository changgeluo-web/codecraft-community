package com.jiangma.server.vo;

import lombok.Data;

@Data
public class StudyStatsVO {
    private Long total;
    private Long pending;    // 待学 (status=0)
    private Long studying;   // 学习中 (status=1)
    private Long mastered;   // 已掌握 (status=2)
    private Double progress; // 掌握进度百分比
}
