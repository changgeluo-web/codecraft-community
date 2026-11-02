package com.jiangma.server.vo;

import lombok.Data;

/**
 * 批量查询标签时的中间行：帖子ID + 标签信息。
 */
@Data
public class PostTagItemVO {
    private Long postId;
    private Long tagId;
    private String name;
}