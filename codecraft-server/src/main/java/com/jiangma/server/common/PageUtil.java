package com.jiangma.server.common;

/**
 * 分页参数工具：统一夹取页码与每页条数，防止超大分页拖垮数据库。
 */
public final class PageUtil {

    public static final long MAX_PAGE_SIZE = 100;

    private PageUtil() {
    }

    public static long clampPage(Long page) {
        return page == null || page < 1 ? 1 : page;
    }

    public static long clampSize(Long size) {
        if (size == null || size < 1) {
            return 10;
        }
        return Math.min(size, MAX_PAGE_SIZE);
    }
}