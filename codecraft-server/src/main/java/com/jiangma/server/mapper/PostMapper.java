package com.jiangma.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangma.server.entity.Post;
import com.jiangma.server.vo.PostListVO;
import com.jiangma.server.vo.PostNodeVO;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

public interface PostMapper extends BaseMapper<Post> {

    Page<PostListVO> selectPostPage(Page<PostListVO> page,
                                    @Param("keyword") String keyword,
                                    @Param("tagId") Long tagId,
                                    @Param("categoryId") Long categoryId,
                                    @Param("userId") Long userId);

    PostListVO selectPostDetail(@Param("id") Long id, @Param("userId") Long userId);

    /** 同项目内，按排序序号（NULL 视为最大、同值按 id）取下一条 */
    @Select("SELECT n.id AS id, n.title AS title FROM post p " +
            "JOIN post n ON n.category_id = p.category_id AND n.deleted = 0 AND n.status = 1 " +
            "WHERE p.id = #{id} AND p.deleted = 0 AND p.status = 1 " +
            "AND (COALESCE(n.sort_order, 999999) > COALESCE(p.sort_order, 999999) " +
            "     OR (COALESCE(n.sort_order, 999999) = COALESCE(p.sort_order, 999999) AND n.id > p.id)) " +
            "ORDER BY COALESCE(n.sort_order, 999999) ASC, n.id ASC LIMIT 1")
    PostNodeVO selectNextNode(@Param("id") Long id);

    /** 同项目内，按排序序号取上一条 */
    @Select("SELECT n.id AS id, n.title AS title FROM post p " +
            "JOIN post n ON n.category_id = p.category_id AND n.deleted = 0 AND n.status = 1 " +
            "WHERE p.id = #{id} AND p.deleted = 0 AND p.status = 1 " +
            "AND (COALESCE(n.sort_order, 999999) < COALESCE(p.sort_order, 999999) " +
            "     OR (COALESCE(n.sort_order, 999999) = COALESCE(p.sort_order, 999999) AND n.id < p.id)) " +
            "ORDER BY COALESCE(n.sort_order, 999999) DESC, n.id DESC LIMIT 1")
    PostNodeVO selectPrevNode(@Param("id") Long id);
}
