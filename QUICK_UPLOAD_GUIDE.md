# 🚀 快速上传到 GitHub - 3 步完成

## 方法 1: 使用网页界面（推荐）

### 步骤 1: 创建 GitHub 仓库

1. 访问: https://github.com/new
2. 填写信息:
   - **Repository name**: `baresip-xcframework`
   - **Description**: `Lightweight VoIP XCFramework for iOS/macOS with 100% Linphone API compatibility`
   - **Visibility**: Public（推荐）或 Private
   - **❌ 不要勾选** "Initialize this repository with a README"
3. 点击 **"Create repository"**

### 步骤 2: 复制您的 GitHub 用户名

在创建仓库后，GitHub 会显示您的仓库 URL，例如：
```
https://github.com/YOUR_USERNAME/baresip-xcframework.git
```

记下您的 `YOUR_USERNAME`

### 步骤 3: 运行上传命令

在终端中运行（替换 YOUR_USERNAME 为您的 GitHub 用户名）:

```bash
cd /Users/mac/work/baresip

# 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/baresip-xcframework.git

# 推送代码
git branch -M main
git push -u origin main
```

**完成！** 🎉

---

## 方法 2: 使用上传脚本（交互式）

运行我们创建的脚本：

```bash
cd /Users/mac/work/baresip
./upload_to_github.sh
```

脚本会引导您完成所有步骤。

---

## 方法 3: 使用 SSH（如果已配置）

```bash
cd /Users/mac/work/baresip

# 添加远程仓库（SSH）
git remote add origin git@github.com:YOUR_USERNAME/baresip-xcframework.git

# 推送代码
git branch -M main
git push -u origin main
```

---

## 验证上传

上传成功后，访问您的仓库：
```
https://github.com/YOUR_USERNAME/baresip-xcframework
```

您应该能看到所有 50 个文件！

---

## 推荐的仓库设置

### 1. 添加 Topics

在仓库页面点击 "Add topics"，添加：
- `voip`
- `sip`
- `ios`
- `macos`
- `xcframework`
- `swift`
- `baresip`
- `linphone`
- `callkit`
- `pushkit`

### 2. 创建 Release

1. 点击 "Releases" → "Create a new release"
2. Tag: `v1.0.0`
3. Title: `Baresip XCFramework v1.0.0`
4. Description: 从 `CHANGELOG.md` 复制内容
5. 附加文件: 压缩 `output/Baresip.xcframework` 并上传

### 3. 更新 README

确保 README.md 中的链接和徽章正确显示。

---

## 常见问题

### Q: 推送时要求输入用户名和密码？

**A**: GitHub 已不再支持密码认证。您需要：

1. 创建 Personal Access Token:
   - 访问: https://github.com/settings/tokens
   - 点击 "Generate new token (classic)"
   - 勾选 `repo` 权限
   - 复制生成的 token

2. 使用 token 作为密码:
   - Username: 您的 GitHub 用户名
   - Password: 粘贴刚才复制的 token

### Q: 如何删除错误的 remote？

```bash
git remote remove origin
```

然后重新添加正确的 remote。

### Q: 推送失败怎么办？

检查：
1. 仓库 URL 是否正确
2. 是否有网络连接
3. 是否有推送权限

---

## 下一步

上传成功后：

1. ✅ 验证所有文件都已上传
2. ✅ 添加 Topics
3. ✅ 创建 Release（附加 XCFramework）
4. ✅ 在真实项目中测试
5. ✅ 分享给社区

---

**需要帮助？** 查看 `GITHUB_UPLOAD_GUIDE.md` 获取更详细的说明。
