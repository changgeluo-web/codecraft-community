<script setup>
import { ref } from 'vue'
import MarkdownRenderer from './MarkdownRenderer.vue'

const props = defineProps({
  modelValue: { type: String, default: '' },
  placeholder: { type: String, default: '用 Markdown 撰写你的技术文章…' },
  minHeight: { type: Number, default: 420 }
})

const emit = defineEmits(['update:modelValue'])

const textareaRef = ref(null)
const previewVisible = ref(true)

function update(value) {
  emit('update:modelValue', value)
}

/** 在选区前后插入内容 */
function wrap(before, after = '', placeholderText = '') {
  const ta = textareaRef.value
  if (!ta) return
  const start = ta.selectionStart
  const end = ta.selectionEnd
  const selected = props.modelValue.slice(start, end) || placeholderText
  const next = props.modelValue.slice(0, start) + before + selected + after + props.modelValue.slice(end)
  update(next)
  requestAnimationFrame(() => {
    ta.focus()
    const cursor = start + before.length
    ta.setSelectionRange(cursor, cursor + selected.length)
  })
}

/** 在当前行首插入前缀 */
function linePrefix(prefix) {
  const ta = textareaRef.value
  if (!ta) return
  const start = ta.selectionStart
  const lines = props.modelValue.split('\n')
  const lineIndex = props.modelValue.slice(0, start).split('\n').length - 1
  lines[lineIndex] = prefix + lines[lineIndex]
  update(lines.join('\n'))
}

const actions = {
  bold: () => wrap('**', '**', '加粗文字'),
  italic: () => wrap('*', '*', '斜体文字'),
  strike: () => wrap('~~', '~~', '删除线'),
  h1: () => linePrefix('# '),
  h2: () => linePrefix('## '),
  h3: () => linePrefix('### '),
  quote: () => linePrefix('> '),
  ul: () => linePrefix('- '),
  ol: () => linePrefix('1. '),
  code: () => wrap('`', '`', 'code'),
  codeBlock: () => wrap('\n```\n', '\n```\n', '在此输入代码…'),
  link: () => wrap('[', '](https://example.com)', '链接文字'),
  image: () => wrap('![', '](https://example.com/image.png)', '图片描述'),
  hr: () => {
    update(props.modelValue ? props.modelValue + '\n\n---\n\n' : '---\n\n')
  }
}
</script>

<template>
  <div class="md-editor">
    <div class="md-editor__toolbar">
      <el-button-group class="md-editor__group">
        <el-tooltip content="加粗" placement="top"><el-button size="small" @click="actions.bold"><b>B</b></el-button></el-tooltip>
        <el-tooltip content="斜体" placement="top"><el-button size="small" @click="actions.italic"><i>I</i></el-button></el-tooltip>
        <el-tooltip content="删除线" placement="top"><el-button size="small" @click="actions.strike"><s>S</s></el-button></el-tooltip>
        <el-tooltip content="标题1" placement="top"><el-button size="small" @click="actions.h1">H1</el-button></el-tooltip>
        <el-tooltip content="标题2" placement="top"><el-button size="small" @click="actions.h2">H2</el-button></el-tooltip>
        <el-tooltip content="标题3" placement="top"><el-button size="small" @click="actions.h3">H3</el-button></el-tooltip>
        <el-tooltip content="引用" placement="top"><el-button size="small" @click="actions.quote">❝</el-button></el-tooltip>
        <el-tooltip content="无序列表" placement="top"><el-button size="small" @click="actions.ul">•≡</el-button></el-tooltip>
        <el-tooltip content="有序列表" placement="top"><el-button size="small" @click="actions.ol">1≡</el-button></el-tooltip>
        <el-tooltip content="行内代码" placement="top"><el-button size="small" @click="actions.code">&lt;/&gt;</el-button></el-tooltip>
        <el-tooltip content="代码块" placement="top"><el-button size="small" @click="actions.codeBlock">{"{}"}</el-button></el-tooltip>
        <el-tooltip content="链接" placement="top"><el-button size="small" @click="actions.link"><el-icon><Link /></el-icon></el-button></el-tooltip>
        <el-tooltip content="图片" placement="top"><el-button size="small" @click="actions.image"><el-icon><Picture /></el-icon></el-button></el-tooltip>
        <el-tooltip content="分割线" placement="top"><el-button size="small" @click="actions.hr">—</el-button></el-tooltip>
      </el-button-group>
      <div class="md-editor__toggle">
        <el-switch v-model="previewVisible" active-text="预览" inline-prompt />
      </div>
    </div>

    <div class="md-editor__body" :style="{ minHeight: minHeight + 'px' }">
      <textarea
        ref="textareaRef"
        class="md-editor__textarea"
        :value="modelValue"
        :placeholder="placeholder"
        spellcheck="false"
        @input="update($event.target.value)"
      ></textarea>
      <div v-show="previewVisible" class="md-editor__preview">
        <MarkdownRenderer v-if="modelValue" :content="modelValue" />
        <span v-else class="md-editor__preview-empty">预览区域</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.md-editor {
  border: 1px solid var(--cc-border);
  border-radius: var(--cc-radius);
  background: #fff;
  overflow: hidden;
}

.md-editor__toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 8px;
  padding: 8px 12px;
  border-bottom: 1px solid var(--cc-border);
  background: #fafbfc;
}

.md-editor__group {
  flex-wrap: wrap;
}

.md-editor__body {
  display: grid;
  grid-template-columns: 1fr 1fr;
}

.md-editor__textarea {
  width: 100%;
  min-height: inherit;
  border: none;
  outline: none;
  resize: vertical;
  padding: 16px;
  font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
  font-size: 14px;
  line-height: 1.7;
  color: #3d3225;
  background: #fff;
}

.md-editor__preview {
  border-left: 1px solid var(--cc-border);
  padding: 16px;
  overflow-y: auto;
  min-height: inherit;
  max-height: 70vh;
}

.md-editor__preview-empty {
  color: var(--cc-text-sub);
}

@media (max-width: 768px) {
  .md-editor__body {
    grid-template-columns: 1fr;
  }

  .md-editor__preview {
    border-left: none;
    border-top: 1px solid var(--cc-border);
  }
}
</style>