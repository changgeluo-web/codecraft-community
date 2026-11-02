package com.jiangma.server.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class PostListVO {

    private Long id;
    private String title;
    private String summary;
    private String coverImage;
    private Integer sortOrder;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long authorId;
    private Long categoryId;
    private String categoryName;
    private List<TagVO> tags;
    /** 当前登录用户的学习状态: 0待学 1学习中 2已掌握（未登录恒为0） */
    private Integer studyStatus;
}
