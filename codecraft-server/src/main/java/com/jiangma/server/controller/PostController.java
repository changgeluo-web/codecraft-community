package com.jiangma.server.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangma.server.common.PageUtil;
import com.jiangma.server.common.Result;
import com.jiangma.server.dto.PostRequest;
import com.jiangma.server.service.PostService;
import com.jiangma.server.vo.DashboardVO;
import com.jiangma.server.vo.PostDetailVO;
import com.jiangma.server.vo.PostListVO;
import com.jiangma.server.vo.PostNavVO;
import com.jiangma.server.vo.StudyStatsVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/posts")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;

    @GetMapping
    public Result<Page<PostListVO>> list(@RequestParam(defaultValue = "1") Long page,
                                         @RequestParam(defaultValue = "10") Long size,
                                         @RequestParam(required = false) String keyword,
                                         @RequestParam(required = false) Long tagId,
                                         @RequestParam(required = false) Long categoryId) {
        return Result.success(postService.listPosts(
                PageUtil.clampPage(page), PageUtil.clampSize(size), keyword, tagId, categoryId));
    }

    @GetMapping("/study-stats")
    public Result<StudyStatsVO> studyStats(@RequestParam(required = false) Long categoryId) {
        return Result.success(postService.getStudyStats(categoryId));
    }

    @GetMapping("/dashboard")
    public Result<DashboardVO> dashboard() {
        return Result.success(postService.getDashboard());
    }

    /** 同一项目内的上一条/下一条（按排序序号） */
    @GetMapping("/{id}/neighbors")
    public Result<PostNavVO> neighbors(@PathVariable Long id) {
        return Result.success(postService.getNeighbors(id));
    }

    @GetMapping("/{id}")
    public Result<PostDetailVO> get(@PathVariable Long id) {
        return Result.success(postService.getPost(id));
    }

    @PostMapping
    public Result<Long> create(@Valid @RequestBody PostRequest request) {
        return Result.success(postService.createPost(request));
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody PostRequest request) {
        postService.updatePost(id, request);
        return Result.success(null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        postService.deletePost(id);
        return Result.success(null);
    }

    @PutMapping("/{id}/study-status")
    public Result<Void> updateStudyStatus(@PathVariable Long id, @RequestParam Integer status) {
        postService.updateStudyStatus(id, status);
        return Result.success(null);
    }
}
