package com.jiangma.server.vo;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class PostDetailVO extends PostListVO {

    private String content;
}
