<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const router = useRouter()
const activeTab = ref('profile')

const profileForm = ref({ nickname: '', bio: '', avatarUrl: '', email: '' })
const passwordForm = ref({ oldPassword: '', newPassword: '', confirmPassword: '' })

const profileRef = ref(null)
const passwordRef = ref(null)

const profileRules = {
  nickname: [{ required: true, message: '昵称不能为空', trigger: 'blur' }]
}

const passwordRules = {
  oldPassword: [{ required: true, message: '请输入当前密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 64, message: '密码长度至少 6 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.value.newPassword) callback(new Error('两次输入的新密码不一致'))
        else callback()
      },
      trigger: 'blur'
    }
  ]
}

onMounted(async () => {
  if (!userStore.user && userStore.isLoggedIn) await userStore.fetchProfile()
  const u = userStore.user || {}
  profileForm.value = {
    nickname: u.nickname || u.username || '',
    bio: u.bio || '',
    avatarUrl: u.avatarUrl || '',
    email: u.email || ''
  }
})

async function saveProfile() {
  if (!profileRef.value) return
  try {
    await profileRef.value.validate()
  } catch (e) {
    return
  }
  await userStore.updateProfile({
    nickname: profileForm.value.nickname,
    bio: profileForm.value.bio,
    avatarUrl: profileForm.value.avatarUrl
  })
  ElMessage.success('资料已更新')
}

async function savePassword() {
  if (!passwordRef.value) return
  try {
    await passwordRef.value.validate()
  } catch (e) {
    return
  }
  await userStore.changePassword({
    oldPassword: passwordForm.value.oldPassword,
    newPassword: passwordForm.value.newPassword
  })
  ElMessage.success('密码修改成功')
  passwordForm.value = { oldPassword: '', newPassword: '', confirmPassword: '' }
}
</script>

<template>
  <div class="settings-page cc-page">
    <div class="settings-page__head">
      <button class="settings-page__back" @click="router.push('/')">
        <el-icon><ArrowLeft /></el-icon>&nbsp;返回首页
      </button>
      <h2 class="settings-page__title">个人设置</h2>
    </div>
    <div class="cc-card cc-card-pad">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="基本资料" name="profile">
          <el-form ref="profileRef" :model="profileForm" :rules="profileRules" label-width="90px" style="max-width: 560px">
            <el-form-item label="昵称" prop="nickname">
              <el-input v-model="profileForm.nickname" maxlength="32" show-word-limit />
            </el-form-item>
            <el-form-item label="邮箱">
              <el-input v-model="profileForm.email" disabled />
            </el-form-item>
            <el-form-item label="头像 URL">
              <el-input v-model="profileForm.avatarUrl" placeholder="https://…" />
            </el-form-item>
            <el-form-item label="个人简介">
              <el-input
                v-model="profileForm.bio"
                type="textarea"
                :rows="4"
                maxlength="200"
                show-word-limit
                placeholder="介绍一下自己吧"
              />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="saveProfile">保存修改</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="修改密码" name="password">
          <el-form ref="passwordRef" :model="passwordForm" :rules="passwordRules" label-width="90px" style="max-width: 420px">
            <el-form-item label="当前密码" prop="oldPassword">
              <el-input v-model="passwordForm.oldPassword" type="password" show-password />
            </el-form-item>
            <el-form-item label="新密码" prop="newPassword">
              <el-input v-model="passwordForm.newPassword" type="password" show-password />
            </el-form-item>
            <el-form-item label="确认新密码" prop="confirmPassword">
              <el-input v-model="passwordForm.confirmPassword" type="password" show-password />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="savePassword">确认修改</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>
<style scoped>
.settings-page {
  max-width: 900px;
  margin: 0 auto;
}
.settings-page__head {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 16px;
}
.settings-page__back {
  display: inline-flex;
  align-items: center;
  border: 1px solid var(--cc-border);
  background: var(--cc-bg-card);
  color: var(--cc-text-sub);
  font-size: 13px;
  cursor: pointer;
  padding: 7px 14px;
  border-radius: 999px;
  box-shadow: var(--cc-shadow-sm);
  transition: var(--cc-transition-fast);
}
.settings-page__back:hover {
  color: var(--cc-primary);
  border-color: var(--cc-border-strong);
  background: var(--cc-primary-soft);
  transform: translateX(-2px);
}
.settings-page__title {
  margin: 0;
  font-size: 18px;
  font-weight: 800;
  color: var(--cc-text-main);
}
</style>
