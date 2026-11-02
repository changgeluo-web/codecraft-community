package com.jiangma.server.service;

import com.jiangma.server.dto.TagRequest;
import com.jiangma.server.vo.TagVO;

import java.util.List;

public interface TagService {

    /** categoryId 为空返回全部标签；否则返回该项目标签 + 全局标签 */
    List<TagVO> listTags(Long categoryId);
    Long createTag(TagRequest request);
    void updateTag(Long id, TagRequest request);
    void deleteTag(Long id);
}
