<script setup>
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const form = ref({ username: '', password: '' })
const loading = ref(false)

async function submit() {
  if (!form.value.username.trim() || !form.value.password) {
    ElMessage.warning('请输入用户名和密码')
    return
  }
  loading.value = true
  try {
    await userStore.login({ username: form.value.username.trim(), password: form.value.password })
    ElMessage.success('登录成功')
    router.replace(route.query.redirect || '/')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="auth">
    <!-- 左侧品牌区 -->
    <section class="auth__brand">
      <div class="auth__brand-inner">
        <div class="auth__logo">
          <span class="auth__logo-icon">⌘</span>
          <span>知识记录系统</span>
        </div>
        <h2 class="auth__slogan">把学过的技术，<br>沉淀成自己的知识库</h2>
        <ul class="auth__points">
          <li><el-icon><Check /></el-icon> 按项目整理知识点，自定义学习顺序</li>
          <li><el-icon><Check /></el-icon> Markdown 撰写，代码高亮原生支持</li>
          <li><el-icon><Check /></el-icon> 上一条 / 下一条连贯翻阅，标记掌握进度</li>
        </ul>
        <p class="auth__tech">Spring Boot 3 · Vue 3 · MySQL · Redis · JWT</p>
      </div>
    </section>

    <!-- 右侧表单区 -->
    <section class="auth__form-wrap">
      <div class="auth__form-card">
        <h3 class="auth__form-title">欢迎回来</h3>
        <p class="auth__form-sub">登录你的账号，继续未完成的学习</p>

        <el-form @submit.prevent="submit">
          <el-form-item>
            <el-input v-model="form.username" size="large" placeholder="用户名 / 邮箱" clearable autocomplete="username">
              <template #prefix><el-icon><User /></el-icon></template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.password" size="large" type="password" placeholder="密码" show-password autocomplete="current-password" @keyup.enter="submit">
              <template #prefix><el-icon><Lock /></el-icon></template>
            </el-input>
          </el-form-item>
          <el-button class="auth__submit" type="primary" size="large" :loading="loading" @click="submit">登 录</el-button>
        </el-form>

        <div class="auth__footer-text">
          还没有账号？<router-link to="/register" class="auth__link">注册一个</router-link>
        </div>
        <div class="auth__home"><router-link to="/" class="auth__link">先随便逛逛 →</router-link></div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.auth {
  min-height: 100vh;
  display: grid;
  grid-template-columns: 1fr 480px;
  background: var(--cc-bg);
}

.auth__brand {
  background: linear-gradient(150deg, #92400e, #b45309 55%, #c2703d);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 48px;
  position: relative;
  overflow: hidden;
}
.auth__brand::after {
  content: '';
  position: absolute;
  width: 420px;
  height: 420px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.07);
  top: -120px;
  right: -120px;
}

.auth__brand-inner { max-width: 420px; position: relative; z-index: 1; }

.auth__logo {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 40px;
}
.auth__logo-icon {
  width: 42px;
  height: 42px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
}

.auth__slogan { font-size: 30px; line-height: 1.4; margin: 0 0 28px; font-weight: 700; }

.auth__points { list-style: none; padding: 0; margin: 0 0 36px; display: flex; flex-direction: column; gap: 14px; }
.auth__points li { display: flex; align-items: center; gap: 10px; font-size: 14px; opacity: 0.92; }

.auth__tech { font-size: 12px; opacity: 0.65; letter-spacing: 0.04em; }

.auth__form-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px 32px;
  background:
    radial-gradient(600px 300px at 100% 0%, rgba(194, 112, 61, 0.06), transparent 60%),
    #fffdf9;
}

.auth__form-card { width: 100%; max-width: 340px; }

.auth__form-title { margin: 0 0 6px; font-size: 24px; color: var(--cc-text-main); }
.auth__form-sub { margin: 0 0 28px; font-size: 13px; color: var(--cc-text-muted); }

.auth__submit {
  width: 100%;
  margin-top: 6px;
  letter-spacing: 4px;
  font-weight: 700;
  height: 44px;
  border-radius: 12px;
}

.auth__footer-text { margin-top: 22px; text-align: center; font-size: 13px; color: var(--cc-text-sub); }
.auth__home { margin-top: 10px; text-align: center; font-size: 12px; }
.auth__link { color: var(--cc-primary); font-weight: 600; text-decoration: none; }
.auth__link:hover { text-decoration: underline; }

@media (max-width: 900px) {
  .auth { grid-template-columns: 1fr; }
  .auth__brand { display: none; }
}
</style>
