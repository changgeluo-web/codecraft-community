package com.jiangma.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.jiangma.server.common.BusinessException;
import com.jiangma.server.dto.CategoryRequest;
import com.jiangma.server.entity.Category;
import com.jiangma.server.mapper.CategoryMapper;
import com.jiangma.server.service.CategoryService;
import com.jiangma.server.vo.CategoryVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryMapper categoryMapper;

    @Override
    public List<CategoryVO> listCategories() {
        return categoryMapper.selectWithPostCount();
    }

    @Override
    public Long createCategory(CategoryRequest request) {
        requireCategoryNameUnique(request.getName(), null);
        Category category = new Category();
        category.setName(request.getName());
        category.setDescription(request.getDescription());
        category.setSortOrder(request.getSortOrder() == null
                ? nextSortOrder() : request.getSortOrder());
        category.setCreatedAt(LocalDateTime.now());
        category.setDeleted(0);
        categoryMapper.insert(category);
        return category.getId();
    }

    @Override
    public void updateCategory(Long id, CategoryRequest request) {
        Category category = categoryMapper.selectById(id);
        if (category == null) {
            throw new BusinessException(404, "项目不存在");
        }
        requireCategoryNameUnique(request.getName(), id);
        category.setName(request.getName());
        category.setDescription(request.getDescription());
        if (request.getSortOrder() != null) {
            category.setSortOrder(request.getSortOrder());
        }
        categoryMapper.updateById(category);
    }

    @Override
    public void deleteCategory(Long id) {
        Category category = categoryMapper.selectById(id);
        if (category == null) {
            throw new BusinessException(404, "项目不存在");
        }
        long postCount = categoryMapper.selectWithPostCount().stream()
                .filter(c -> c.getId().equals(id))
                .map(CategoryVO::getPostCount)
                .findFirst()
                .orElse(0L);
        if (postCount > 0) {
            throw new BusinessException("该项目下还有 " + postCount + " 条知识点，不能删除");
        }
        categoryMapper.deleteById(id);
    }

    /** 新项目默认排到最后 */
    private Integer nextSortOrder() {
        return categoryMapper.selectList(new LambdaQueryWrapper<Category>()
                        .select(Category::getSortOrder)
                        .isNotNull(Category::getSortOrder))
                .stream()
                .map(Category::getSortOrder)
                .max(Integer::compareTo)
                .map(max -> max + 1)
                .orElse(1);
    }

    private void requireCategoryNameUnique(String name, Long excludeId) {
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<Category>()
                .eq(Category::getName, name);
        if (excludeId != null) {
            wrapper.ne(Category::getId, excludeId);
        }
        if (categoryMapper.selectCount(wrapper) > 0) {
            throw new BusinessException("同名项目已存在");
        }
    }
}
