package com.jiangma.server.vo;

import lombok.Data;

@Data
public class CategoryVO {

    private Long id;
    private String name;
    private String description;
    private Integer sortOrder;
    /** 项目下知识点数量（管理端返回，公开接口可为 null） */
    private Long postCount;
}