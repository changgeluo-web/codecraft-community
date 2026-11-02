package com.jiangma.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangma.server.entity.Category;
import com.jiangma.server.vo.CategoryVO;
import org.apache.ibatis.annotations.Select;

import java.util.List;

public interface CategoryMapper extends BaseMapper<Category> {

    /** 管理端：项目（分类）列表 + 知识点数量 */
    @Select("SELECT c.id AS id, c.name AS name, c.description AS description, " +
            "c.sort_order AS sortOrder, COUNT(p.id) AS postCount " +
            "FROM category c " +
            "LEFT JOIN post p ON p.category_id = c.id AND p.deleted = 0 " +
            "WHERE c.deleted = 0 " +
            "GROUP BY c.id, c.name, c.description, c.sort_order " +
            "ORDER BY c.sort_order ASC, c.id ASC")
    List<CategoryVO> selectWithPostCount();
}