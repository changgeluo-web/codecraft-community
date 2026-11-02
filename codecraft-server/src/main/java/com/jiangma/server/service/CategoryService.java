package com.jiangma.server.service;

import com.jiangma.server.dto.CategoryRequest;
import com.jiangma.server.vo.CategoryVO;

import java.util.List;

public interface CategoryService {

    /** 项目列表（含知识点数量） */
    List<CategoryVO> listCategories();
    Long createCategory(CategoryRequest request);
    void updateCategory(Long id, CategoryRequest request);
    void deleteCategory(Long id);
}
