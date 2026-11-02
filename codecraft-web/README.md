# codecraft-web · 码匠社区前端

码匠社区（CodeCraft Community）前端工程，基于 **Vue 3（Composition API）+ Vite 5 + Element Plus + Pinia + Vue Router 4 + Axios**。

## 快速开始

```bash
npm install
npm run dev      # 启动开发服务器 http://localhost:5173
npm run build    # 生产构建，产物输出到 dist/
npm run preview  # 本地预览构建产物
```

开发环境下，`/api` 请求会由 Vite 代理转发到后端 `http://localhost:8080`（见 `vite.config.js`）。

## 目录结构

```
src/
├── api/          # 接口请求封装（axios 实例 + 各模块 API）
│   └── request.js# axios 统一拦截：token 注入、401 自动刷新、业务码处理
├── components/   # 通用组件
│   ├── AppHeader.vue            # 顶部导航：搜索、写文章、通知、用户菜单
│   ├── PostCard.vue             # 帖子卡片
│   ├── CommentTree.vue          # 递归评论树（回复 / 删除）
│   ├── MarkdownEditor.vue       # Markdown 编辑器（工具栏 + 实时预览）
│   ├── MarkdownRenderer.vue     # Markdown 渲染器（DOMPurify 过滤 + highlight.js 高亮）
│   ├── UserAvatar.vue           # 用户头像
│   └── NotificationDropdown.vue # 通知下拉（未读徽标）
├── layouts/
│   └── MainLayout.vue           # 主布局（顶栏 + 内容 + 页脚）
├── router/       # 路由配置（含登录守卫）
├── stores/       # Pinia：user / post / comment / notification
├── styles/       # 全局样式（index.css / markdown.css）
├── utils/        # 工具：auth（token）、format（时间/数字）、markdown（渲染）
└── views/        # 页面
    ├── HomeView.vue         # 首页（最新/热门、分类、标签、分页）
    ├── PostDetailView.vue   # 帖子详情（正文、点赞、关注、评论树）
    ├── UserView.vue         # 用户主页（资料、文章列表、关注）
    ├── EditorView.vue       # 发布 / 编辑文章（Markdown 编辑器）
    ├── NotificationsView.vue# 消息中心
    ├── LoginView.vue        # 登录
    ├── RegisterView.vue     # 注册
    ├── SettingsView.vue     # 个人设置（资料 / 密码）
    ├── SearchView.vue       # 搜索
    └── NotFoundView.vue     # 404
```

## 页面路由

| 页面 | 路径 | 说明 |
|------|------|------|
| 首页 | `/` | 帖子流、热门、分类 |
| 帖子详情 | `/post/:id` | 正文、评论、点赞、作者卡片 |
| 用户主页 | `/user/:id` | 个人资料、帖子列表、关注数 |
| 发布/编辑 | `/editor`、`/editor/:id` | Markdown 编辑器 |
| 消息中心 | `/notifications` | 通知列表（需登录） |
| 登录/注册 | `/login`、`/register` | 认证页面 |
| 个人设置 | `/settings` | 资料修改、密码修改（需登录） |
| 搜索 | `/search?keyword=` | 搜索结果 |

## 与后端对接约定

- **统一响应格式**：`{ code, message, data }`，`code === 200` 时拦截器直接返回 `data`；参数校验失败为 `code=400`。
- **分页响应**：列表接口兼容 `{ records, total }` / `{ list, total }` / 纯数组三种形态。
- **认证**：登录（用户名或邮箱）/注册返回 `{ accessToken, refreshToken, user }`；
  请求头自动携带 `Authorization: Bearer <accessToken>`；401 时用 `POST /api/auth/refresh` 刷新并重试，失败跳转登录页；`POST /api/auth/logout` 会使当前令牌立即失效。
- **登录请求体**：`{ username, password }`（username 支持用户名或邮箱）。
- **注册请求体**：`{ username, nickname, email, password }`。
- **修改密码**：`PUT /api/users/me/password`，body `{ oldPassword, newPassword }`。
- **点赞**：`POST /api/likes`，body `{ targetType: 'POST'|'COMMENT', targetId }`，为切换语义，返回 `{ liked, likeCount }`。
- **关注**：`POST /api/users/:id/follow` / `DELETE /api/users/:id/follow`。
- **帖子详情**：返回 `author`（`id/username/nickname/avatarUrl/followed`）、`categoryId/categoryName`、`tags`、`isLiked` 及各计数。
- **评论树**：`GET /api/posts/:id/comments` 返回树形结构，子评论字段为 `children`，每条评论含 `author` 对象；发表评论 `parentId` 为 `null` 表示顶级。
- **通知**：`GET /api/notifications` 字段包括 `type`（COMMENT/REPLY/FOLLOW/LIKE/SYSTEM）、`targetType`（POST/USER）、`senderId/senderName/senderAvatar`、`isRead`；单条已读 `PUT /api/notifications/:id/read`。
- **搜索**：`GET /api/search?keyword=&page=&size=`。
- **学习进度（需登录）**：`PUT /api/posts/:id/study-status?status=0|1|2`、`GET /api/posts/study-stats`、`GET /api/posts/dashboard`，均为当前登录用户维度。
