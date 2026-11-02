<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const form = ref({ username: '', email: '', nickname: '', password: '', confirmPassword: '' })
const loading = ref(false)

async function submit() {
  const f = form.value
  if (!f.username.trim() || !f.email.trim() || !f.password) {
    ElMessage.warning('请填写用户名、邮箱和密码')
    return
  }
  if (f.password.length < 6) {
    ElMessage.warning('密码至少 6 位')
    return
  }
  if (f.password !== f.confirmPassword) {
    ElMessage.warning('两次输入的密码不一致')
    return
  }
  loading.value = true
  try {
    await userStore.register({
      username: f.username.trim(),
      email: f.email.trim(),
      nickname: f.nickname.trim() || f.username.trim(),
      password: f.password
    })
    ElMessage.success('注册成功，已自动登录')
    router.replace('/')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="auth">
    <section class="auth__brand">
      <div class="auth__brand-inner">
        <div class="auth__logo">
          <span class="auth__logo-icon">⌘</span>
          <span>知识记录系统</span>
        </div>
        <h2 class="auth__slogan">现在开始，<br>搭建你的第二大脑</h2>
        <ul class="auth__points">
          <li><el-icon><Check /></el-icon> 免费创建任意数量的学习项目</li>
          <li><el-icon><Check /></el-icon> 每一条知识都可排序、可检索、可回顾</li>
          <li><el-icon><Check /></el-icon> 数据在自己手里，简历上直接可演示</li>
        </ul>
        <p class="auth__tech">Spring Boot 3 · Vue 3 · MySQL · Redis · JWT</p>
      </div>
    </section>

    <section class="auth__form-wrap">
      <div class="auth__form-card">
        <h3 class="auth__form-title">创建账号</h3>
        <p class="auth__form-sub">只需几秒，即可开始记录第一条知识点</p>

        <el-form @submit.prevent="submit">
          <el-form-item>
            <el-input v-model="form.username" size="large" placeholder="用户名（登录用）" clearable>
              <template #prefix><el-icon><User /></el-icon></template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.email" size="large" placeholder="邮箱" clearable>
              <template #prefix><el-icon><Message /></el-icon></template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.nickname" size="large" placeholder="昵称（可选）" clearable />
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.password" size="large" type="password" placeholder="密码（至少 6 位）" show-password>
              <template #prefix><el-icon><Lock /></el-icon></template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-input v-model="form.confirmPassword" size="large" type="password" placeholder="确认密码" show-password @keyup.enter="submit">
              <template #prefix><el-icon><Lock /></el-icon></template>
            </el-input>
          </el-form-item>
          <el-button class="auth__submit" type="primary" size="large" :loading="loading" @click="submit">注 册</el-button>
        </el-form>

        <div class="auth__footer-text">
          已有账号？<router-link to="/login" class="auth__link">直接登录</router-link>
        </div>
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
  bottom: -140px;
  left: -100px;
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
.auth__form-sub { margin: 0 0 22px; font-size: 13px; color: var(--cc-text-muted); }

.auth__submit {
  width: 100%;
  margin-top: 6px;
  letter-spacing: 4px;
  font-weight: 700;
  height: 44px;
  border-radius: 12px;
}

.auth__footer-text { margin-top: 22px; text-align: center; font-size: 13px; color: var(--cc-text-sub); }
.auth__link { color: var(--cc-primary); font-weight: 600; text-decoration: none; }
.auth__link:hover { text-decoration: underline; }

@media (max-width: 900px) {
  .auth { grid-template-columns: 1fr; }
  .auth__brand { display: none; }
}
</style>
