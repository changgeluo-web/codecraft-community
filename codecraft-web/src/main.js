import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/es/locale/lang/zh-cn'

// 按需注册用到的 Element Plus 图标（替代全量注册，减小打包体积）
import {
  ArrowDown,
  ArrowLeft,
  ArrowRight,
  Check,
  CircleCheck,
  Delete,
  EditPen,
  Expand,
  Folder,
  Fold,
  Lock,
  Message,
  Search,
  Setting,
  TrendCharts,
  User,
  Reading
} from '@element-plus/icons-vue'

import 'element-plus/dist/index.css'

import App from './App.vue'
import router from './router'

import '@/styles/index.css'
import '@/styles/markdown.css'

const app = createApp(App)

const icons = {
  ArrowDown,
  ArrowLeft,
  ArrowRight,
  Check,
  CircleCheck,
  Delete,
  EditPen,
  Expand,
  Folder,
  Fold,
  Lock,
  Message,
  Search,
  Setting,
  TrendCharts,
  User,
  Reading
}
for (const [name, component] of Object.entries(icons)) {
  app.component(name, component)
}

app.use(createPinia())
app.use(router)
app.use(ElementPlus, { locale: zhCn })

app.mount('#app')