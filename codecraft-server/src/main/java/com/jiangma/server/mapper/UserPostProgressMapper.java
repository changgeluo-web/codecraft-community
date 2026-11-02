package com.jiangma.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangma.server.entity.UserPostProgress;
import com.jiangma.server.vo.ProgressStatRow;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

public interface UserPostProgressMapper extends BaseMapper<UserPostProgress> {

    @Select("SELECT * FROM user_post_progress WHERE user_id = #{userId} AND post_id = #{postId} LIMIT 1")
    UserPostProgress selectByUserAndPost(@Param("userId") Long userId, @Param("postId") Long postId);

    /** 全局 + 个人进度聚合（可选按分类过滤） */
    @Select("<script>" +
            "SELECT COUNT(*) AS total, " +
            "COALESCE(SUM(CASE WHEN up.status = 1 THEN 1 ELSE 0 END), 0) AS studying, " +
            "COALESCE(SUM(CASE WHEN up.status = 2 THEN 1 ELSE 0 END), 0) AS mastered " +
            "FROM post p " +
            "LEFT JOIN user_post_progress up ON up.post_id = p.id AND up.user_id = #{userId} " +
            "WHERE p.deleted = 0 AND p.status = 1 " +
            "<if test='categoryId != null'>AND p.category_id = #{categoryId} </if>" +
            "</script>")
    ProgressStatRow selectStudyStats(@Param("userId") Long userId, @Param("categoryId") Long categoryId);

    /** 按分类分组的个人进度聚合（项目看板） */
    @Select("SELECT p.category_id AS categoryId, COUNT(*) AS total, " +
            "COALESCE(SUM(CASE WHEN up.status = 1 THEN 1 ELSE 0 END), 0) AS studying, " +
            "COALESCE(SUM(CASE WHEN up.status = 2 THEN 1 ELSE 0 END), 0) AS mastered " +
            "FROM post p " +
            "LEFT JOIN user_post_progress up ON up.post_id = p.id AND up.user_id = #{userId} " +
            "WHERE p.deleted = 0 AND p.status = 1 " +
            "GROUP BY p.category_id")
    List<ProgressStatRow> selectStatsGroupByCategory(@Param("userId") Long userId);
}