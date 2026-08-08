# 秋招投递 iOS 自装版

这个目录是 iOS 原生壳版本，使用 Swift + `WKWebView` 加载当前静态网页资源。

## 安装到自己的 iPhone

1. 在 Mac 上安装完整 Xcode。
2. 用 Xcode 打开 `AutumnRecruitmentApp.xcodeproj`。
3. 点击项目 `AutumnRecruitmentApp`，进入 `Signing & Capabilities`。
4. `Team` 选择你的 Apple ID 对应团队。
5. 如果 Bundle Identifier 冲突，把 `com.ricardobai.autumnrecruitment` 改成自己的唯一 ID。
6. 用数据线连接 iPhone，信任电脑。
7. 顶部设备选择你的 iPhone。
8. 点击运行按钮安装。

## 当前支持

- 本地网页应用运行
- `localStorage` 本地账号和记录保存
- 云同步/云备份网络请求
- JSON 复制、分享、保存到文件
- 日历事件创建
- 外部链接跳转 Safari

## 更新网页资源

每次 Web 版改完后，把这些文件同步到：

```text
AutumnRecruitmentApp/Resources/
```

需要同步的文件：

```text
index.html
styles.css
app.js
manifest.webmanifest
app-icon.svg
```

然后重新用 Xcode 运行即可。
