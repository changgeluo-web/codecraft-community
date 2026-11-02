<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { createPost, updatePost, getPost } from '@/api/post'
import { getCategories } from '@/api/category'
import { getTags } from '@/api/tag'
import MarkdownEditor from '@/components/MarkdownEditor.vue'

const route = useRoute()
const router = useRouter()

const editId = computed(() => route.params.id || null)

const form = ref({
  title: '',
  summary: '',
  content: '',
  categoryId: null,
  tagIds: [],
  coverImage: '',
  sortOrder: null
})

const categories = ref([])
const tags = ref([])
const submitting = ref(false)
const loading = ref(false)

// 可选标签 = 全局标签 + 当前项目专属标签
const availableTags = computed(() => {
  const categoryId = form.value.categoryId
  if (!categoryId) return tags.value
  return tags.value.filter((t) => !t.categoryId || t.categoryId === categoryId)
})

// 切换项目后，移除不再适用的已选标签
function onCategoryChange() {
  const validIds = new Set(availableTags.value.map((t) => t.id))
  form.value.tagIds = form.value.tagIds.filter((id) => validIds.has(id))
}

onMounted(async () => {
  const presetCat = Number(route.query.categoryId) || null
  try {
    const [catData, tagData] = await Promise.all([getCategories(), getTags()])
    categories.value = catData?.records || catData?.list || (Array.isArray(catData) ? catData : []) || []
    tags.value = tagData?.records || tagData?.list || (Array.isArray(tagData) ? tagData : []) || []
  } catch (e) {
    /* 分类/标签加载失败不阻塞 */
  }
  if (presetCat && !editId.value) form.value.categoryId = presetCat

  if (editId.value) {
    loading.value = true
    try {
      const post = await getPost(editId.value)
      form.value = {
        title: post.title || '',
        summary: post.summary || '',
        content: post.content || '',
        categoryId: post.categoryId ?? null,
        tagIds: (post.tags || []).map((t) => t.id || t),
        coverImage: post.coverImage || '',
        sortOrder: post.sortOrder ?? null
      }
    } catch (e) {
      ElMessage.error('知识点不存在或无权编辑')
      router.replace('/')
    } finally {
      loading.value = false
    }
  }
})

async function submit() {
  if (!form.value.title.trim()) {
    ElMessage.warning('请填写标题')
    return
  }
  if (!form.value.content.trim()) {
    ElMessage.warning('请填写正文内容')
    return
  }
  submitting.value = true
  try {
    const payload = {
      title: form.value.title.trim(),
      summary: form.value.summary.trim(),
      content: form.value.content,
      categoryId: form.value.categoryId,
      tagIds: form.value.tagIds,
      sortOrder: form.value.sortOrder ?? null,
      coverImage: form.value.coverImage.trim() || undefined
    }
    if (editId.value) {
      await updatePost(editId.value, payload)
      ElMessage.success('知识点更新成功')
      router.replace(`/post/${editId.value}`)
    } else {
      const data = await createPost(payload)
      ElMessage.success('知识点记录成功')
      router.replace(`/post/${data}`)
    }
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="editor-page cc-page">
    <div class="editor-page__header cc-page-head">
      <button class="cc-back" @click="router.push('/')">
        <el-icon><ArrowLeft /></el-icon>&nbsp;返回首页
      </button>
      <h2>{{ editId ? '编辑知识点' : '记录知识点' }}</h2>
    </div>

    <el-skeleton v-if="loading" :rows="10" animated />
    <template v-else>
      <div class="cc-card cc-card-pad editor-page__form">
        <el-form label-position="top">
          <el-form-item label="标题" required>
            <el-input v-model="form.title" placeholder="给这条知识点起个标题（必填）" maxlength="120" show-word-limit />
          </el-form-item>

          <el-form-item label="摘要">
            <el-input
              v-model="form.summary"
              type="textarea"
              :rows="2"
              maxlength="300"
              show-word-limit
              placeholder="一句话摘要，将展示在知识点列表中"
            />
          </el-form-item>

          <div class="editor-page__row">
            <el-form-item label="分类">
              <el-select v-model="form.categoryId" placeholder="选择学习模块" clearable style="width: 100%" @change="onCategoryChange">
                <el-option v-for="cat in categories" :key="cat.id" :label="cat.name" :value="cat.id" />
              </el-select>
            </el-form-item>
            <el-form-item label="标签">
              <el-select v-model="form.tagIds" multiple placeholder="选择技术标签（可多选）" style="width: 100%">
                <el-option v-for="tag in availableTags" :key="tag.id" :label="tag.name" :value="tag.id" />
              </el-select>
            </el-form-item>
          </div>

          <el-form-item label="排序序号">
            <el-input-number v-model="form.sortOrder" :min="0" :max="9999" controls-position="right" placeholder="留空自动" style="width: 160px" />
            <span class="editor-page__hint">同一项目内按序号排列，决定“上一条/下一条”顺序；留空排最后</span>
          </el-form-item>

          <el-form-item label="封面图 URL（可选）">
            <el-input v-model="form.coverImage" placeholder="https://…" />
          </el-form-item>
        </el-form>
      </div>

      <div class="editor-page__content cc-card">
        <MarkdownEditor v-model="form.content" :min-height="480" />
      </div>

      <div class="editor-page__actions">
        <el-button @click="router.back()">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submit">{{ editId ? '保存修改' : '保存知识点' }}</el-button>
      </div>
    </template>
  </div>
</template>

<style scoped>
.editor-page__header {
  margin-bottom: 16px;
  max-width: 1080px;
  margin-left: auto;
  margin-right: auto;
}

.editor-page__form {
  margin-bottom: 16px;
  max-width: 1080px;
  margin-left: auto;
  margin-right: auto;
}

.editor-page__row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.editor-page__content {
  overflow: hidden;
}

.editor-page__hint {
  margin-left: 12px;
  font-size: 12px;
  color: var(--cc-text-muted);
}

.editor-page__actions {
  position: sticky;
  bottom: 14px;
  z-index: 10;
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 12px;
  margin-top: 18px;
  padding: 12px 16px;
  background: rgba(255, 255, 255, 0.82);
  border: 1px solid var(--cc-border-light);
  border-radius: var(--cc-radius-lg);
  box-shadow: var(--cc-shadow-md);
  backdrop-filter: blur(12px);
}

@media (max-width: 768px) {
  .editor-page__row {
    grid-template-columns: 1fr;
  }
}
</style>