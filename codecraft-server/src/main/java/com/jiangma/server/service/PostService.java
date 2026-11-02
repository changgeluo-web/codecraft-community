package com.jiangma.server.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangma.server.dto.PostRequest;
import com.jiangma.server.vo.DashboardVO;
import com.jiangma.server.vo.PostDetailVO;
import com.jiangma.server.vo.PostListVO;
import com.jiangma.server.vo.PostNavVO;
import com.jiangma.server.vo.StudyStatsVO;

public interface PostService {

    Page<PostListVO> listPosts(Long page, Long size, String keyword, Long tagId, Long categoryId);
    PostDetailVO getPost(Long id);
    Long createPost(PostRequest request);
    void updatePost(Long id, PostRequest request);
    void deletePost(Long id);
    /** 同一项目内按排序序号的上一条/下一条 */
    PostNavVO getNeighbors(Long id);
    void updateStudyStatus(Long id, Integer status);
    StudyStatsVO getStudyStats(Long categoryId);
    DashboardVO getDashboard();
}
