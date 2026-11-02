package com.jiangma.server.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/** 新建/编辑项目（分类） */
@Data
public class CategoryRequest {

    @NotBlank(message = "项目名不能为空")
    @Size(max = 100, message = "项目名不能超过100字")
    private String name;

    @Size(max = 500, message = "描述不能超过500字")
    private String description;

    /** 侧边栏项目展示顺序，小的在前 */
    private Integer sortOrder;
}
