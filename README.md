# 绿盾V算（lvdun-vcalc）

湖南绿盾卫士检测技术有限公司出品的**工况 / 标况 / 参比体积换算小工具**。
输入工况体积、温度、大气压，自动算出**标况体积**与**参比体积**，结果按「四舍六入五成双」保留 1 位小数。

> 绿盾 V 算 —— 采样现场随手一算，标况参比不用愁。

---

## 功能

- 输入：工况体积（L）、温度（℃）、大气压（kPa）
- 输出：
  - **标况体积 V₀**：0℃ / 101.325 kPa
  - **参比体积 Vᵣ**：298.15 K（25℃）/ 101.325 kPa
- 修约：四舍六入五成双（round-half-to-even），保留 1 位小数
- 计算公式（点击 App 内「查看计算规则」可展开）：

```
V₀ = V × (P / 101.325) × [273.15 / (273.15 + t)]
Vᵣ = V × (P / 101.325) × [298.15 / (273.15 + t)]
```

其中 V = 工况体积(L)，P = 大气压(kPa)，t = 温度(℃)。

---

## 使用方式

### 1）Web 版（最省事）
直接用浏览器打开 [`绿盾V算.html`](绿盾V算.html)，离线可用，手机/电脑都行。
可「添加到主屏幕」当作本地 App 使用。

### 2）Android 安装包
下载仓库根目录的 [`绿盾V算.apk`](绿盾V算.apk)，传到手机后用「文件管理」打开安装（允许安装未知来源应用）。
- 包名：`com.volconv`
- `minSdkVersion=21`，`targetSdkVersion=33`
- 已签名（v1/v2/v3），离线运行，不联网、不上传数据

> 安装提示：请通过 USB / 蓝牙 / QQ 文件助手传输，安装时用系统「文件管理」打开，
> 勿在微信聊天窗口内直接点装（部分机型会误报「不兼容」）。

---

## 从源码重新打包（可选）

仓库只保留源码与发布产物，**不**包含 Android SDK / JDK（体积大，可自行下载）。

前置：

- JDK 17
- Android SDK `platform-34` + `build-tools;34.0.0`
- 用于签名的 keystore（自行生成，路径 `apk-build/keystore.jks`）

目录说明：

```
绿盾V算.html              # Web 版应用
绿盾V算.apk               # 已签名的 Android 安装包（发布产物）
apk-build/
  app/AndroidManifest.xml # 清单（含 uses-sdk、应用图标）
  app/assets/index.html   # 实际装入 WebView 的页面
  app/res/mipmap-*/...    # 启动图标（绿盾 V）
  app/src/.../MainActivity.java  # WebView 壳
  make_icon.py            # 用 PIL 生成多密度图标
  add_to_apk.py           # 合并 dex + assets 进 apk
  rebuild_apk.py          # 一键重建脚本（javac→d8→aapt2→zipalign→apksigner）
```

运行：`python rebuild_apk.py`

---

## 说明

- 本项目为离线工具，计算结果在本地完成，不上传任何数据。
- 公式依据公共卫生检测常用体积换算口径（标况 0℃ / 参比 25℃）。
