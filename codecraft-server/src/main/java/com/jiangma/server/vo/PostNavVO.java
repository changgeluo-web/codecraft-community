package com.jiangma.server.vo;

import lombok.Data;

/** 同一项目内按排序序号的相邻知识点导航 */
@Data
public class PostNavVO {

    /** 上一条，不存在时为 null */
    private PostNodeVO prev;
    /** 下一条，不存在时为 null */
    private PostNodeVO next;
}
