package com.jiangma.server.vo;

import lombok.Data;

/**
 * 学习进度聚合行（SQL GROUP BY 结果承载）。
 */
@Data
public class ProgressStatRow {
    private Long categoryId;
    private Long total;
    private Long studying;
    private Long mastered;
}