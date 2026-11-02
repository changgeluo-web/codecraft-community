package com.jiangma.server.common;

import lombok.Data;
import java.util.List;

@Data
public class PageResult<T> {

    private Long total;
    private Long pages;
    private Long current;
    private Long size;
    private List<T> records;
}
