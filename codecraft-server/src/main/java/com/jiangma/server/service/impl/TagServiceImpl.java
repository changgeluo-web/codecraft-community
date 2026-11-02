package com.jiangma.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.jiangma.server.common.BusinessException;
import com.jiangma.server.dto.TagRequest;
import com.jiangma.server.entity.Tag;
import com.jiangma.server.mapper.CategoryMapper;
import com.jiangma.server.mapper.PostTagMapper;
import com.jiangma.server.mapper.TagMapper;
import com.jiangma.server.service.TagService;
import com.jiangma.server.vo.TagVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TagServiceImpl implements TagService {

    private final TagMapper tagMapper;
    private final PostTagMapper postTagMapper;
    private final CategoryMapper categoryMapper;

    @Override
    public List<TagVO> listTags(Long categoryId) {
        return tagMapper.selectTagList(categoryId);
    }

    @Override
    public Long createTag(TagRequest request) {
        requireCategoryExistsIfGiven(request.getCategoryId());
        // selectByName 不过滤 deleted：若存在已逻辑删除的同名标签则恢复，避免唯一键冲突
        Tag exists = tagMapper.selectByName(request.getName());
        if (exists != null) {
            if (exists.getDeleted() == null || exists.getDeleted() == 0) {
                throw new BusinessException("同名标签已存在");
            }
            tagMapper.restoreTag(exists.getId(), request.getCategoryId());
            return exists.getId();
        }
        Tag tag = new Tag();
        tag.setName(request.getName());
        tag.setCategoryId(request.getCategoryId());
        tag.setCreatedAt(LocalDateTime.now());
        tag.setDeleted(0);
        tagMapper.insert(tag);
        return tag.getId();
    }

    @Override
    public void updateTag(Long id, TagRequest request) {
        Tag tag = tagMapper.selectById(id);
        if (tag == null) {
            throw new BusinessException(404, "标签不存在");
        }
        requireTagNameUnique(request.getName(), id);
        requireCategoryExistsIfGiven(request.getCategoryId());
        // 改名目标名若被已逻辑删除的标签占用，先物理清理，避免唯一键冲突
        Tag nameHolder = tagMapper.selectByName(request.getName());
        if (nameHolder != null && !nameHolder.getId().equals(id)
                && nameHolder.getDeleted() != null && nameHolder.getDeleted() == 1) {
            tagMapper.physicalDeleteDeletedById(nameHolder.getId());
        }
        tag.setName(request.getName());
        tag.setCategoryId(request.getCategoryId());
        tagMapper.updateById(tag);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTag(Long id) {
        Tag tag = tagMapper.selectById(id);
        if (tag == null) {
            throw new BusinessException(404, "标签不存在");
        }
        postTagMapper.deleteByTagId(id);
        tagMapper.deleteById(id);
    }

    private void requireTagNameUnique(String name, Long excludeId) {
        LambdaQueryWrapper<Tag> wrapper = new LambdaQueryWrapper<Tag>()
                .eq(Tag::getName, name);
        if (excludeId != null) {
            wrapper.ne(Tag::getId, excludeId);
        }
        if (tagMapper.selectCount(wrapper) > 0) {
            throw new BusinessException("同名标签已存在");
        }
    }

    private void requireCategoryExistsIfGiven(Long categoryId) {
        if (categoryId != null && categoryMapper.selectById(categoryId) == null) {
            throw new BusinessException("归属项目不存在");
        }
    }
}
