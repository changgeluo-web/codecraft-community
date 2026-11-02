package com.jiangma.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangma.server.entity.Tag;
import com.jiangma.server.vo.PostTagItemVO;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

public interface TagMapper extends BaseMapper<Tag> {

    @Select("SELECT * FROM tag WHERE name = #{name} LIMIT 1")
    Tag selectByName(@Param("name") String name);

    /** 恢复逻辑删除的标签（绕过 MyBatis-Plus 逻辑删除对 updateById 的限制） */
    @Update("UPDATE tag SET deleted = 0, category_id = #{categoryId}, created_at = NOW() WHERE id = #{id}")
    int restoreTag(@Param("id") Long id, @Param("categoryId") Long categoryId);

    /** 物理删除已逻辑删除的标签，释放唯一键占用 */
    @Delete("DELETE FROM tag WHERE id = #{id} AND deleted = 1")
    int physicalDeleteDeletedById(@Param("id") Long id);

    @Select("SELECT t.* FROM tag t INNER JOIN post_tag pt ON t.id = pt.tag_id WHERE pt.post_id = #{postId} AND t.deleted = 0")
    List<Tag> selectByPostId(@Param("postId") Long postId);

    /** 批量查询多篇帖子的标签，消除列表页 N+1 */
    @Select("<script>" +
            "SELECT pt.post_id AS postId, t.id AS tagId, t.name AS name " +
            "FROM post_tag pt INNER JOIN tag t ON t.id = pt.tag_id AND t.deleted = 0 " +
            "WHERE pt.post_id IN " +
            "<foreach item='id' collection='postIds' open='(' separator=',' close=')'>#{id}</foreach>" +
            "</script>")
    List<PostTagItemVO> selectTagsByPostIds(@Param("postIds") List<Long> postIds);

    /** 标签列表 + 引用数；按项目过滤时同时返回全局标签 */
    @Select("<script>" +
            "SELECT t.id AS id, t.name AS name, t.category_id AS categoryId, COUNT(p.id) AS postCount " +
            "FROM tag t " +
            "LEFT JOIN post_tag pt ON pt.tag_id = t.id " +
            "LEFT JOIN post p ON p.id = pt.post_id AND p.deleted = 0 " +
            "WHERE t.deleted = 0 " +
            "<if test='categoryId != null'>AND (t.category_id = #{categoryId} OR t.category_id IS NULL) </if>" +
            "GROUP BY t.id, t.name, t.category_id " +
            "ORDER BY t.id ASC" +
            "</script>")
    List<com.jiangma.server.vo.TagVO> selectTagList(@Param("categoryId") Long categoryId);
}