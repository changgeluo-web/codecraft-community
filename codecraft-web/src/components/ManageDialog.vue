<script setup>
import { ref, watch, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCategories, createCategory, updateCategory, deleteCategory } from '@/api/category'
import { getTags, createTag, deleteTag } from '@/api/tag'

const visible = defineModel({ type: Boolean })
const emit = defineEmits(['saved'])

const activeTab = ref('categories')

// ---------- 项目 ----------
const categories = ref([])
const catDialog = ref(false)
const catForm = ref({ id: null, name: '', description: '', sortOrder: null })

async function loadCategories() {
  categories.value = (await getCategories()) || []
}

function openCatEdit(cat = null) {
  catForm.value = cat
    ? { id: cat.id, name: cat.name, description: cat.description || '', sortOrder: cat.sortOrder ?? null }
    : { id: null, name: '', description: '', sortOrder: null }
  catDialog.value = true
}

async function saveCategory() {
  if (!catForm.value.name.trim()) { ElMessage.warning('项目名不能为空'); return }
  const payload = { name: catForm.value.name.trim(), description: catForm.value.description.trim(), sortOrder: catForm.value.sortOrder }
  if (catForm.value.id) await updateCategory(catForm.value.id, payload)
  else await createCategory(payload)
  ElMessage.success('已保存')
  catDialog.value = false
  await loadCategories()
  emit('saved')
}

async function removeCategory(cat) {
  await ElMessageBox.confirm('确定删除项目「' + cat.name + '」吗？', '删除项目', { type: 'warning' })
  await deleteCategory(cat.id)
  ElMessage.success('已删除')
  await loadCategories()
  emit('saved')
}

// ---------- 标签 ----------
const tags = ref([])
const tagForm = ref({ name: '', categoryId: null })

async function loadTags() {
  tags.value = (await getTags()) || []
}

async function addTag() {
  if (!tagForm.value.name.trim()) { ElMessage.warning('标签名不能为空'); return }
  await createTag({ name: tagForm.value.name.trim(), categoryId: tagForm.value.categoryId })
  tagForm.value = { name: '', categoryId: null }
  ElMessage.success('标签已创建')
  await loadTags()
  emit('saved')
}

async function removeTag(tag) {
  await ElMessageBox.confirm('确定删除标签「' + tag.name + '」吗？关联知识点会自动解除该标签。', '删除标签', { type: 'warning' })
  await deleteTag(tag.id)
  ElMessage.success('已删除')
  await loadTags()
  emit('saved')
}

watch(visible, (v) => {
  if (v) { loadCategories(); loadTags() }
})

const catOptions = computed(() => categories.value)
</script>

<template>
  <el-dialog v-model="visible" title="项目与标签管理" width="640px" top="8vh">
    <el-tabs v-model="activeTab">
      <el-tab-pane label="项目（学习模块）" name="categories">
        <div class="mg__bar">
          <el-button type="primary" size="small" @click="openCatEdit()">+ 新建项目</el-button>
          <span class="mg__tip">项目决定侧边栏分组顺序，序号小的在前</span>
        </div>
        <el-table :data="categories" size="small" max-height="320">
          <el-table-column prop="sortOrder" label="序号" width="70" />
          <el-table-column prop="name" label="项目名" min-width="140" />
          <el-table-column prop="description" label="说明" min-width="160" show-overflow-tooltip />
          <el-table-column prop="postCount" label="知识点" width="80" />
          <el-table-column label="操作" width="110">
            <template #default="{ row }">
              <el-button text size="small" @click="openCatEdit(row)">编辑</el-button>
              <el-button text size="small" type="danger" @click="removeCategory(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="标签" name="tags">
        <div class="mg__bar">
          <el-input v-model="tagForm.name" size="small" placeholder="标签名" style="width: 150px" @keyup.enter="addTag" />
          <el-select v-model="tagForm.categoryId" size="small" placeholder="归属项目（默认全局）" clearable style="width: 190px">
            <el-option v-for="c in catOptions" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
          <el-button size="small" type="primary" @click="addTag">添加</el-button>
        </div>
        <el-table :data="tags" size="small" max-height="320">
          <el-table-column prop="name" label="标签" min-width="140" />
          <el-table-column label="归属" min-width="120">
            <template #default="{ row }">
              <span v-if="!row.categoryId">全局</span>
              <span v-else>{{ (categories.find(c => c.id === row.categoryId) || {}).name || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="postCount" label="引用" width="70" />
          <el-table-column label="操作" width="80">
            <template #default="{ row }">
              <el-button text size="small" type="danger" @click="removeTag(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="catDialog" :title="catForm.id ? '编辑项目' : '新建项目'" width="420px" append-to-body>
      <el-form label-position="top">
        <el-form-item label="项目名" required>
          <el-input v-model="catForm.name" maxlength="50" placeholder="如：JavaSE / 三层架构实战" />
        </el-form-item>
        <el-form-item label="说明">
          <el-input v-model="catForm.description" type="textarea" :rows="2" maxlength="200" />
        </el-form-item>
        <el-form-item label="排序序号（小的在前，留空自动排最后）">
          <el-input-number v-model="catForm.sortOrder" :min="0" :max="9999" controls-position="right" placeholder="留空" style="width: 160px" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="catDialog = false">取消</el-button>
        <el-button type="primary" @click="saveCategory">保存</el-button>
      </template>
    </el-dialog>
  </el-dialog>
</template>

<style scoped>
.mg__bar {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}
.mg__tip { font-size: 12px; color: var(--cc-text-muted); }
</style>
