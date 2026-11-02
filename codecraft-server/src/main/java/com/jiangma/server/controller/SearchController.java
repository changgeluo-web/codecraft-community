package com.jiangma.server.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangma.server.common.PageUtil;
import com.jiangma.server.common.Result;
import com.jiangma.server.service.PostService;
import com.jiangma.server.vo.PostListVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {

    private final PostService postService;

    /** 搜索知识点（标题/摘要关键词） */
    @GetMapping
    public Result<Page<PostListVO>> search(@RequestParam(required = false) String keyword,
                                           @RequestParam(defaultValue = "1") Long page,
                                           @RequestParam(defaultValue = "10") Long size,
                                           @RequestParam(required = false) Long tagId,
                                           @RequestParam(required = false) Long categoryId) {
        return Result.success(postService.listPosts(
                PageUtil.clampPage(page), PageUtil.clampSize(size), keyword, tagId, categoryId));
    }
}