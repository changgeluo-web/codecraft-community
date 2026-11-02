package com.jiangma.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.jiangma.server.entity.PostTag;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

public interface PostTagMapper extends BaseMapper<PostTag> {

    @Select("SELECT tag_id FROM post_tag WHERE post_id = #{postId}")
    List<Long> selectTagIdsByPostId(@Param("postId") Long postId);

    int deleteByPostId(@Param("postId") Long postId);

    @Delete("DELETE FROM post_tag WHERE tag_id = #{tagId}")
    int deleteByTagId(@Param("tagId") Long tagId);
}
