package com.jiangma.server.vo;

import lombok.Data;

/** 上一条/下一条导航节点：只带 id 与标题 */
@Data
public class PostNodeVO {

    private Long id;
    private String title;
}
