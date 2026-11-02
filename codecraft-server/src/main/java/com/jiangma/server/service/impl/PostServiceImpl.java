package com.jiangma.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.jiangma.server.common.BusinessException;
import com.jiangma.server.dto.PostRequest;
import com.jiangma.server.entity.Category;
import com.jiangma.server.entity.Post;
import com.jiangma.server.entity.PostTag;
import com.jiangma.server.entity.UserPostProgress;
import com.jiangma.server.mapper.CategoryMapper;
import com.jiangma.server.mapper.PostMapper;
import com.jiangma.server.mapper.PostTagMapper;
import com.jiangma.server.mapper.TagMapper;
import com.jiangma.server.mapper.UserPostProgressMapper;
import com.jiangma.server.security.SecurityUtil;
import com.jiangma.server.service.PostService;
import com.jiangma.server.vo.DashboardVO;
import com.jiangma.server.vo.PostDetailVO;
import com.jiangma.server.vo.PostListVO;
import com.jiangma.server.vo.PostNavVO;
import com.jiangma.server.vo.PostTagItemVO;
import com.jiangma.server.vo.ProgressStatRow;
import com.jiangma.server.vo.StudyStatsVO;
import com.jiangma.server.vo.TagVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PostServiceImpl implements PostService {

    private final PostMapper postMapper;
    private final PostTagMapper postTagMapper;
    private final TagMapper tagMapper;
    private final CategoryMapper categoryMapper;
    private final UserPostProgressMapper progressMapper;

    @Override
    public Page<PostListVO> listPosts(Long page, Long size, String keyword, Long tagId, Long categoryId) {
        Long userId = SecurityUtil.currentUserId();
        Page<PostListVO> result = postMapper.selectPostPage(new Page<>(page, size), keyword, tagId, categoryId, userId);
        if (result != null && result.getRecords() != null) {
            batchFillTags(result.getRecords());
        }
        return result;
    }

    @Override
    public PostDetailVO getPost(Long id) {
        Long userId = SecurityUtil.currentUserId();
        PostListVO base = postMapper.selectPostDetail(id, userId);
        if (base == null) {
            throw new BusinessException(404, "知识点不存在");
        }
        Post post = postMapper.selectById(id);
        PostDetailVO vo = new PostDetailVO();
        BeanUtils.copyProperties(base, vo);
        vo.setContent(post.getContent());
        vo.setTags(listTagVOs(id));
        return vo;
    }

    @Override
    public PostNavVO getNeighbors(Long id) {
        Post post = postMapper.selectById(id);
        if (post == null || post.getDeleted() == 1) {
            throw new BusinessException(404, "知识点不存在");
        }
        PostNavVO nav = new PostNavVO();
        nav.setPrev(postMapper.selectPrevNode(id));
        nav.setNext(postMapper.selectNextNode(id));
        return nav;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createPost(PostRequest request) {
        requireCategoryExists(request.getCategoryId());
        Post post = new Post();
        post.setAuthorId(SecurityUtil.currentUserId());
        post.setTitle(request.getTitle());
        post.setContent(request.getContent());
        String summary = request.getSummary();
        if (!StringUtils.hasText(summary)) {
            summary = request.getContent().length() > 200
                    ? request.getContent().substring(0, 200)
                    : request.getContent();
        }
        post.setSummary(summary);
        post.setCoverImage(request.getCoverImage());
        post.setCategoryId(request.getCategoryId());
        post.setSortOrder(request.getSortOrder());
        post.setStatus(1);
        post.setCreatedAt(LocalDateTime.now());
        post.setUpdatedAt(LocalDateTime.now());
        post.setDeleted(0);
        postMapper.insert(post);

        savePostTags(post.getId(), request.getTagIds());
        return post.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updatePost(Long id, PostRequest request) {
        Post post = postMapper.selectById(id);
        if (post == null || post.getDeleted() == 1) {
            throw new BusinessException(404, "知识点不存在");
        }
        Long currentId = SecurityUtil.currentUserId();
        if (!currentId.equals(post.getAuthorId())) {
            throw new BusinessException(403, "无权限修改");
        }
        requireCategoryExists(request.getCategoryId());
        String summary = StringUtils.hasText(request.getSummary()) ? request.getSummary() : post.getSummary();
        // UpdateWrapper 显式 set，允许把 sortOrder 置回 NULL（自动排序）
        postMapper.update(null, new LambdaUpdateWrapper<Post>()
                .eq(Post::getId, id)
                .set(Post::getTitle, request.getTitle())
                .set(Post::getContent, request.getContent())
                .set(Post::getSummary, summary)
                .set(Post::getCoverImage, request.getCoverImage())
                .set(Post::getCategoryId, request.getCategoryId())
                .set(Post::getSortOrder, request.getSortOrder())
                .set(Post::getUpdatedAt, LocalDateTime.now()));

        postTagMapper.deleteByPostId(id);
        savePostTags(id, request.getTagIds());
    }

    @Override
    public void deletePost(Long id) {
        Post post = postMapper.selectById(id);
        if (post == null) {
            throw new BusinessException(404, "知识点不存在");
        }
        Long currentId = SecurityUtil.currentUserId();
        if (!currentId.equals(post.getAuthorId())) {
            throw new BusinessException(403, "无权限删除");
        }
        postMapper.deleteById(id);
    }

    // ==================== 学习进度（按用户维度） ====================

    @Override
    public void updateStudyStatus(Long id, Integer status) {
        Long userId = SecurityUtil.currentUserId();
        if (userId == null) {
            throw new BusinessException(401, "未登录");
        }
        Post post = postMapper.selectById(id);
        if (post == null || post.getDeleted() == 1) {
            throw new BusinessException(404, "知识点不存在");
        }
        if (status == null || status < 0 || status > 2) {
            throw new BusinessException("无效的学习状态");
        }
        UserPostProgress progress = progressMapper.selectByUserAndPost(userId, id);
        if (progress == null) {
            progress = new UserPostProgress();
            progress.setUserId(userId);
            progress.setPostId(id);
            progress.setStatus(status);
            progress.setCreatedAt(LocalDateTime.now());
            progress.setUpdatedAt(LocalDateTime.now());
            progressMapper.insert(progress);
        } else {
            progress.setStatus(status);
            progress.setUpdatedAt(LocalDateTime.now());
            progressMapper.updateById(progress);
        }
    }

    @Override
    public StudyStatsVO getStudyStats(Long categoryId) {
        Long userId = SecurityUtil.currentUserId();
        if (userId == null) {
            throw new BusinessException(401, "未登录");
        }
        ProgressStatRow row = progressMapper.selectStudyStats(userId, categoryId);
        StudyStatsVO vo = new StudyStatsVO();
        long total = row == null || row.getTotal() == null ? 0 : row.getTotal();
        long studying = row == null || row.getStudying() == null ? 0 : row.getStudying();
        long mastered = row == null || row.getMastered() == null ? 0 : row.getMastered();
        vo.setTotal(total);
        vo.setStudying(studying);
        vo.setMastered(mastered);
        vo.setPending(Math.max(0, total - studying - mastered));
        vo.setProgress(total > 0 ? Math.round(mastered * 1000.0 / total) / 10.0 : 0.0);
        return vo;
    }

    @Override
    public DashboardVO getDashboard() {
        Long userId = SecurityUtil.currentUserId();
        if (userId == null) {
            throw new BusinessException(401, "未登录");
        }
        DashboardVO dashboard = new DashboardVO();

        List<Category> categories = categoryMapper.selectList(
                new LambdaQueryWrapper<Category>().orderByAsc(Category::getSortOrder)
        );
        Map<Long, ProgressStatRow> statMap = progressMapper.selectStatsGroupByCategory(userId).stream()
                .collect(Collectors.toMap(ProgressStatRow::getCategoryId, Function.identity(), (a, b) -> a));

        long totalKnowledge = 0;
        long totalMastered = 0;
        List<DashboardVO.ProjectStat> projectStats = new ArrayList<>();
        for (Category cat : categories) {
            ProgressStatRow row = statMap.get(cat.getId());
            long total = row == null || row.getTotal() == null ? 0 : row.getTotal();
            long studying = row == null || row.getStudying() == null ? 0 : row.getStudying();
            long mastered = row == null || row.getMastered() == null ? 0 : row.getMastered();

            DashboardVO.ProjectStat stat = new DashboardVO.ProjectStat();
            stat.setCategoryId(cat.getId());
            stat.setProjectName(cat.getName());
            stat.setDescription(cat.getDescription());
            stat.setTotal(total);
            stat.setStudying(studying);
            stat.setMastered(mastered);
            stat.setPending(Math.max(0, total - studying - mastered));
            stat.setProgress(total > 0 ? Math.round(mastered * 1000.0 / total) / 10.0 : 0.0);
            projectStats.add(stat);

            totalKnowledge += total;
            totalMastered += mastered;
        }

        dashboard.setTotalProjects((long) categories.size());
        dashboard.setTotalKnowledge(totalKnowledge);
        dashboard.setTotalMastered(totalMastered);
        dashboard.setOverallProgress(totalKnowledge > 0
                ? Math.round(totalMastered * 1000.0 / totalKnowledge) / 10.0 : 0.0);
        dashboard.setProjects(projectStats);
        return dashboard;
    }

    // ==================== 私有工具 ====================

    private void requireCategoryExists(Long categoryId) {
        if (categoryId == null) {
            return;
        }
        Category category = categoryMapper.selectById(categoryId);
        if (category == null) {
            throw new BusinessException("分类不存在");
        }
    }

    private void savePostTags(Long postId, List<Long> tagIds) {
        if (tagIds == null || tagIds.isEmpty()) {
            return;
        }
        for (Long tagId : new LinkedHashSet<>(tagIds)) {
            if (tagId == null || tagMapper.selectById(tagId) == null) {
                continue;
            }
            PostTag pt = new PostTag();
            pt.setPostId(postId);
            pt.setTagId(tagId);
            postTagMapper.insert(pt);
        }
    }

    private List<TagVO> listTagVOs(Long postId) {
        return tagMapper.selectByPostId(postId).stream().map(t -> {
            TagVO vo = new TagVO();
            vo.setId(t.getId());
            vo.setName(t.getName());
            return vo;
        }).collect(Collectors.toList());
    }

    /** 批量填充标签，消除逐条查询的 N+1 */
    private void batchFillTags(List<PostListVO> records) {
        if (records == null || records.isEmpty()) {
            return;
        }
        List<Long> postIds = records.stream().map(PostListVO::getId).collect(Collectors.toList());
        Map<Long, List<TagVO>> tagMap = tagMapper.selectTagsByPostIds(postIds).stream()
                .collect(Collectors.groupingBy(PostTagItemVO::getPostId,
                        Collectors.mapping(item -> {
                            TagVO vo = new TagVO();
                            vo.setId(item.getTagId());
                            vo.setName(item.getName());
                            return vo;
                        }, Collectors.toList())));
        records.forEach(vo -> vo.setTags(tagMap.getOrDefault(vo.getId(), Collections.emptyList())));
    }
}
