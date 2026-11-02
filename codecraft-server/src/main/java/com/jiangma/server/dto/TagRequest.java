package com.jiangma.server.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/** 新建/编辑标签 */
@Data
public class TagRequest {

    @NotBlank(message = "标签名不能为空")
    @Size(max = 50, message = "标签名不能超过50字")
    private String name;

    /** 归属项目，NULL=全局标签 */
    private Long categoryId;
}
