# 秋招投递管理项目交接文档

最后整理日期：2026-08-17  
当前主要代码版本：`v3.1.0`  
当前主分支：`main`  
最近重要提交：`a589110 add iOS WKWebView app wrapper`

## 1. 项目是什么

这是一个个人秋招投递状态管理工具，最初是静态网页应用，后来扩展为 Android APK 和 iOS 自装版外壳。

核心用途：

- 管理公司投递记录
- 跟踪状态流转：待初筛、待测评、待笔试、待面试、offer、已拒绝
- 记录城市、星级、更新时间、投递日期、下次检查时间、重要提醒
- 通过今日待检查、12 小时提醒、更新时间过长等机制提醒自己推进
- 支持本地账号隔离、账号密码、管理员账户
- 支持 JSON 导入导出、腾讯云 CloudBase 短链接、云备份、账号云同步

现在的信息架构已经重构为手机 App 风格：

```text
今日 / 投递 / + / 分析 / 我的
```

## 2. 主要线上地址

代码仓库：

- Gitee：https://gitee.com/git_bai/autumn-recruitment-app
- GitHub 当前 remote：https://github.com/Bai1623/campus-application-tracker.git
- GitHub push 时提示仓库已迁移到：`git@github.com:Bai1623/qiuzhao-app.git`

网页版/PWA 公开地址配置在代码里：

```text
https://bai1623444091-coder.github.io/campus-application-tracker/
```

腾讯云 CloudBase 短链接/云同步 API：

```text
https://bai-d0g23uiiz96a4f50d-1428838698.ap-shanghai.app.tcloudbase.com/share
```

CloudBase 环境 ID：

```text
bai-d0g23uiiz96a4f50d
```

CloudBase 数据集合名：

```text
bai
```

## 3. 本地目录结构

当前主仓库路径：

```text
/Users/a221209/Documents/New project/job-application-tracker
```

主仓库内重要文件：

```text
index.html                 静态网页入口
styles.css                 全部前端样式
app.js                     核心业务逻辑
manifest.webmanifest       PWA 配置
sw.js                      PWA 离线缓存
app-icon.svg               网页/PWA 图标
app-icon-1024.png          1024 图标源图
cloudbase/share/index.js   腾讯云 CloudBase 云函数
releases/                  已打包 APK 输出目录
ios-app/                   iOS WKWebView 自装版工程
README.md                  旧版说明，内容有滞后
DEVELOPMENT_HISTORY.md     历史迭代文档，内容有滞后
PROJECT_HANDOFF.md         当前交接文档
```

Android 工程当前不在主仓库内，而是在同级目录：

```text
/Users/a221209/Documents/New project/android-apk
```

迁移到另一台电脑时，如果要继续打 APK，必须把这个目录也迁移过去，或者后续把它正式移入 Git 仓库。

## 4. 当前版本状态

Web/App 内显示版本来自 `app.js`：

```text
APP_VERSION = 3.1.0
APP_UPDATED_AT = 2026.08.08
```

iOS 工程版本：

```text
MARKETING_VERSION = 3.1.0
CURRENT_PROJECT_VERSION = 1
Bundle Identifier = com.ricardobai.autumnrecruitment
iOS Deployment Target = 15.0
```

Android 工程版本目前滞后：

```text
applicationId = com.campushunt.tracker
versionCode = 52
versionName = 3.0.5
minSdk = 23
targetSdk = 35
compileSdk = 35
```

注意：最近 APK 文件实际已经打进了 `3.1.0` 的网页资源，但 Android `build.gradle` 里的 `versionName/versionCode` 还没有同步更新。下一次正式打 APK 前建议先统一为新版本。

## 5. 怎么运行网页版

进入主仓库：

```bash
cd "/Users/a221209/Documents/New project/job-application-tracker"
```

直接浏览器打开 `index.html` 可以用，但更推荐本地服务器：

```bash
python3 -m http.server 5173
```

访问：

```text
http://localhost:5173
```

手机同 Wi-Fi 访问：

```bash
python3 -m http.server 5173 --bind 0.0.0.0
ipconfig getifaddr en0
```

假设 IP 是 `192.168.1.8`，手机打开：

```text
http://192.168.1.8:5173
```

## 6. 怎么打 Android APK

Android 工程路径：

```text
/Users/a221209/Documents/New project/android-apk
```

每次 Web 版改完后，需要先同步资源：

```bash
cd "/Users/a221209/Documents/New project"
cp job-application-tracker/index.html android-apk/app/src/main/assets/index.html
cp job-application-tracker/styles.css android-apk/app/src/main/assets/styles.css
cp job-application-tracker/app.js android-apk/app/src/main/assets/app.js
```

然后打包：

```bash
cd "/Users/a221209/Documents/New project/android-apk"
gradle assembleDebug
```

复制到主仓库可提交目录：

```bash
cp app/build/outputs/apk/debug/app-debug.apk \
  "../job-application-tracker/releases/秋招投递-v2-latest-debug.apk"
```

当前 APK 路径：

```text
/Users/a221209/Documents/New project/job-application-tracker/releases/秋招投递-v2-latest-debug.apk
```

另有旧 APK：

```text
/Users/a221209/Documents/New project/job-application-tracker/releases/秋招投递-debug.apk
```

### Android 签名注意事项

当前是 debug APK，使用 Gradle/Android 默认 debug 签名。要覆盖安装，必须保持：

```text
applicationId = com.campushunt.tracker
签名证书一致
```

如果换电脑后 debug keystore 不同，手机上可能无法覆盖安装旧版，需要先卸载旧 App，或者把旧电脑的 debug keystore 也迁移过去。

常见 debug keystore 路径：

```text
~/.android/debug.keystore
```

如果未来要正式分发，应该改用固定 release keystore，并把 keystore、alias、密码保存到安全位置，不要提交到 Git。

## 7. 怎么运行 iOS 自装版

iOS 工程路径：

```text
/Users/a221209/Documents/New project/job-application-tracker/ios-app/AutumnRecruitmentApp.xcodeproj
```

打开方式：

```bash
open "ios-app/AutumnRecruitmentApp.xcodeproj"
```

安装到自己 iPhone：

1. 安装完整 Xcode。
2. 用 Xcode 打开上面的 `.xcodeproj`。
3. 进入 `Signing & Capabilities`。
4. `Team` 选择自己的 Apple ID 团队。
5. 如果 Bundle Identifier 冲突，把 `com.ricardobai.autumnrecruitment` 改成自己的唯一 ID。
6. 连接 iPhone，信任电脑。
7. 选择真机，点击运行。

当前 Mac 是 macOS `15.7.7`，App Store 最新 Xcode 要求更高系统，不能直接装。建议下载 Apple Developer 里的 `Xcode 16.4.xip`。

下载页：

```text
https://developer.apple.com/download/all/?q=Xcode%2016.4
```

完整 Xcode 安装后执行：

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
xcodebuild -version
```

### iOS 资源同步

Web 版改完后，同步进 iOS 工程：

```bash
cd "/Users/a221209/Documents/New project/job-application-tracker"
ios-app/sync-web-assets.sh
```

这个脚本会同步：

```text
index.html
styles.css
app.js
manifest.webmanifest
app-icon.svg
```

## 8. 云端 CloudBase 函数

云函数源码：

```text
cloudbase/share/index.js
```

主要能力：

- POST 普通备份 JSON，返回短 ID
- GET `?id=xxx` 读取短链接数据
- `account-login` 账号云同步登录校验
- `account-create` 创建账号云端索引
- `account-sync-put` 上传账号最新备份记录
- 保留最近 30 条云同步备份
- 使用 `accountNameKey + passwordVerifier` 校验同名账号密码

前端调用地址写在 `app.js`：

```js
const SHARE_API_BASE_URL = "https://bai-d0g23uiiz96a4f50d-1428838698.ap-shanghai.app.tcloudbase.com/share";
```

迁移电脑不影响云函数。只有需要改云函数时，才去腾讯云 CloudBase 控制台更新 `cloudbase/share/index.js`。

## 9. 数据存储说明

前端主要使用浏览器/WebView 的 `localStorage`。

核心 key：

```text
campus-application-tracker:accounts:v1
campus-application-tracker:active-account:v1
campus-application-tracker:records:v1:{accountId}
campus-application-tracker:overdue-months:v1
campus-application-tracker:long-applied-months:v1
campus-application-tracker:master-password:v1
campus-application-tracker:cloud-backups:v1:{accountId}
campus-application-tracker:cloud-sync:v1:{accountId}
```

迁移用户数据的推荐方式：

1. 旧设备登录对应账号。
2. 点击立即备份或导出。
3. 新设备用同账号名和同密码登录。
4. 如果云端有数据，App 会询问是否恢复。
5. 或者手动导入 JSON/短链接/原始链接。

注意：当前云同步不是强实时同步，是 12 小时间隔自动备份 + 手动立即备份 + 登录时恢复。

## 10. 重要业务规则

状态：

```text
待初筛 / 待测评 / 待笔试 / 待面试 / 已拒绝 / offer
```

看板顺序：

```text
待测评 -> 待笔试 -> 待面试 -> 待初筛 -> offer -> 已拒绝 -> 可再次投递 -> 更新时间过长
```

新增记录时只展示：

```text
待初筛 / 待笔试
```

编辑记录时展示全部状态。

流转到这些状态时必须设置截止时间：

```text
待测评 / 待笔试 / 待面试
```

`更新时间过长` 分类规则：

- 默认投递日期超过 3 个月自动进入
- 月数可在 `我的 -> 系统设置` 修改
- 今日已检查流程里可以手动加入该分类
- 它是展示层分类，不直接覆盖原始状态

`逾期预警` 规则：

- 按 `updatedAt` 超过 N 个月判断
- N 可在 `我的 -> 系统设置` 修改
- 逾期记录高红显示并靠后排序

`今日待检查` 规则：

- `nextCheckAt <= 今天`
- 状态不是 `已拒绝`
- 点击已检查时，会询问状态是否变更
- 点遮罩/空白会取消，不执行已检查

## 11. 开发流程建议

普通前端改动：

```bash
cd "/Users/a221209/Documents/New project/job-application-tracker"
# 修改 index.html / styles.css / app.js
node --check app.js
```

如果要同步 Android：

```bash
cd "/Users/a221209/Documents/New project"
cp job-application-tracker/index.html android-apk/app/src/main/assets/index.html
cp job-application-tracker/styles.css android-apk/app/src/main/assets/styles.css
cp job-application-tracker/app.js android-apk/app/src/main/assets/app.js
cd android-apk
gradle assembleDebug
cp app/build/outputs/apk/debug/app-debug.apk \
  "../job-application-tracker/releases/秋招投递-v2-latest-debug.apk"
```

如果要同步 iOS：

```bash
cd "/Users/a221209/Documents/New project/job-application-tracker"
ios-app/sync-web-assets.sh
```

提交和推送：

```bash
cd "/Users/a221209/Documents/New project/job-application-tracker"
git status --short
git add .
git commit -m "你的提交说明"
git push origin main
git push gitee main
```

目前习惯是：每次做完一个可用版本，都打包 APK，并推送 GitHub 和 Gitee。

## 12. 迁移到新电脑清单

必须迁移/准备：

```text
1. 主仓库 job-application-tracker
2. 同级 Android 工程 android-apk，如果还要继续打 APK
3. 旧电脑 ~/.android/debug.keystore，如果希望新 APK 能覆盖旧 debug APK
4. Xcode 16.4 或兼容版本，如果要继续 iOS 自装版
5. Android Gradle/Java 环境
6. 腾讯云 CloudBase 控制台登录权限，如果要改云函数
```

推荐目录保持一致：

```text
/Users/a221209/Documents/New project/job-application-tracker
/Users/a221209/Documents/New project/android-apk
```

如果换目录，命令里的相对路径也要对应调整。

## 13. 已知注意点

- README 和 DEVELOPMENT_HISTORY 有部分版本信息滞后，交接以本文件和 `app.js` 为准。
- Android 工程没有纳入主仓库，迁移时容易漏掉。
- Android `build.gradle` 版本号仍是 `3.0.5 / 52`，下一次正式打包建议更新。
- iOS 工程已经生成，但当前电脑没有完整 Xcode，无法本机编译验证。
- GitHub remote push 会提示仓库迁移，可后续把 `origin` 改到新地址：

```bash
git remote set-url origin git@github.com:Bai1623/qiuzhao-app.git
```

## 14. 下一台电脑上手顺序

建议按这个顺序恢复开发：

1. 克隆/复制主仓库。
2. 复制同级 `android-apk` 目录。
3. 复制 `~/.android/debug.keystore`。
4. 运行网页版：`python3 -m http.server 5173`。
5. 执行 `node --check app.js`。
6. 打一次 Android debug APK，确认环境正常。
7. 安装 Xcode 16.4，打开 iOS 工程跑一次真机。
8. 再开始新功能迭代。
