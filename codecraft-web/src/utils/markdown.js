import MarkdownIt from 'markdown-it'
import hljs from 'highlight.js/lib/core'
import DOMPurify from 'dompurify'
import 'highlight.js/styles/github-dark.css'

// 按需注册常用语言，减小打包体积
import javascript from 'highlight.js/lib/languages/javascript'
import typescript from 'highlight.js/lib/languages/typescript'
import java from 'highlight.js/lib/languages/java'
import python from 'highlight.js/lib/languages/python'
import bash from 'highlight.js/lib/languages/bash'
import shell from 'highlight.js/lib/languages/shell'
import json from 'highlight.js/lib/languages/json'
import sql from 'highlight.js/lib/languages/sql'
import xml from 'highlight.js/lib/languages/xml'
import css from 'highlight.js/lib/languages/css'
import go from 'highlight.js/lib/languages/go'
import rust from 'highlight.js/lib/languages/rust'
import cpp from 'highlight.js/lib/languages/cpp'
import c from 'highlight.js/lib/languages/c'
import kotlin from 'highlight.js/lib/languages/kotlin'
import php from 'highlight.js/lib/languages/php'
import ruby from 'highlight.js/lib/languages/ruby'
import markdown from 'highlight.js/lib/languages/markdown'
import yaml from 'highlight.js/lib/languages/yaml'
import dockerfile from 'highlight.js/lib/languages/dockerfile'
import plaintext from 'highlight.js/lib/languages/plaintext'

const languages = {
  javascript,
  js: javascript,
  typescript,
  ts: typescript,
  java,
  python,
  py: python,
  bash,
  shell,
  sh: shell,
  json,
  sql,
  xml,
  html: xml,
  css,
  go,
  rust,
  cpp,
  c,
  kotlin,
  php,
  ruby,
  markdown,
  md: markdown,
  yaml,
  dockerfile,
  plaintext,
  text: plaintext
}

Object.entries(languages).forEach(([name, lang]) => hljs.registerLanguage(name, lang))

const md = new MarkdownIt({
  html: false, // 不允许原始 HTML，配合 DOMPurify 双重防护 XSS
  linkify: true,
  breaks: true,
  highlight(str, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return `<pre class="hljs"><code>${hljs.highlight(str, { language: lang, ignoreIllegals: true }).value}</code></pre>`
      } catch (e) {
        /* fallthrough */
      }
    }
    return `<pre class="hljs"><code>${md.utils.escapeHtml(str)}</code></pre>`
  }
})

/**
 * 将 Markdown 文本渲染为安全的 HTML 字符串
 */
export function renderMarkdown(content) {
  if (!content) return ''
  return DOMPurify.sanitize(md.render(content))
}

/**
 * 提取纯文本摘要（去掉 Markdown 语法标记）
 */
export function plainText(content, maxLength = 200) {
  if (!content) return ''
  const text = content
    .replace(/```[\s\S]*?```/g, ' ')
    .replace(/`([^`]*)`/g, '$1')
    .replace(/!\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/[#>*_~+=|]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
  return text.length > maxLength ? text.slice(0, maxLength) + '…' : text
}