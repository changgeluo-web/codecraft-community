package com.jiangma.server.controller;

import com.jiangma.server.common.Result;
import com.jiangma.server.dto.TagRequest;
import com.jiangma.server.service.TagService;
import com.jiangma.server.vo.TagVO;
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

import java.util.List;

@RestController
@RequestMapping("/api/tags")
@RequiredArgsConstructor
public class TagController {

    private final TagService tagService;

    @GetMapping
    public Result<List<TagVO>> list(@RequestParam(required = false) Long categoryId) {
        return Result.success(tagService.listTags(categoryId));
    }

    @PostMapping
    public Result<Long> create(@Valid @RequestBody TagRequest request) {
        return Result.success(tagService.createTag(request));
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @Valid @RequestBody TagRequest request) {
        tagService.updateTag(id, request);
        return Result.success(null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        tagService.deleteTag(id);
        return Result.success(null);
    }
}
