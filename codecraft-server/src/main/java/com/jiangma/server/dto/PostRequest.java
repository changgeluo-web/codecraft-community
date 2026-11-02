package com.jiangma.server.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
public class PostRequest {

    @NotBlank(message = "标题不能为空")
    @Size(max = 200, message = "标题长度不能超过200")
    private String title;

    @NotBlank(message = "内容不能为空")
    @Size(max = 200000, message = "内容过长")
    private String content;

    @Size(max = 500, message = "摘要长度不能超过500")
    private String summary;

    @Size(max = 500, message = "封面地址过长")
    private String coverImage;

    @NotNull(message = "请选择分类")
    private Long categoryId;

    /** 项目内排序序号，小的在前；留空则排在已编号知识点之后（按录入顺序） */
    @Min(value = 0, message = "序号不能为负数")
    private Integer sortOrder;

    private List<Long> tagIds;
}
