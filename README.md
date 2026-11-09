# ✦ Aurora Nav · 极光导航

> 一个漂亮的、带完整后台的个人导航页。**前台必须输入密码才能看到内容**，后台添加网址会**自动识别类型并自动建立分类**，支持**浏览器书签 / 历史记录导入并自动归类**，内置**账号密码保险箱**，还能**自动识别内外网并切换链接**。

本项目提供两种部署方式，核心源码为私有，公开仓库只提供文档、部署配置与可直接拉取的 Docker 镜像。

| 部署方式 | 运行位置 | 数据存储 | 适合 |
| --- | --- | --- | --- |
| **Docker Compose / Docker Hub 镜像** | 飞牛 FnOS / 群晖 / 绿联 / 极空间 / 威联通 / 任意 NAS | 本地 data/data.json | 家庭内网、数据完全自己掌控 |
| **Cloudflare Workers + KV** | 全球边缘节点 | Cloudflare KV | 随时随地外网访问、免费额度 |

---

## 📦 一键部署（推荐，无需源码）

    docker pull xiaoluya/aurora-nav:latest
    docker run -d --name aurora-nav -p 4000:8787 -v ./data:/app/data \
      -e NAV_ADMIN_PASSWORD=你的管理员密码 \
      -e NAV_VIEW_PASSWORD=你的前台访问密码 \
      -e TZ=Asia/Shanghai \
      --restart unless-stopped xiaoluya/aurora-nav:latest

或下载 [docker-compose.yml](<docker-compose.yml>) 后：

    docker compose -p aurora-nav up -d

打开 http://NAS的IP:4000：前台输访问密码，后台 /admin 输管理员密码。

> 镜像为 **linux/amd64** 构建（适配 x86 NAS）。docker-compose.yml 已默认使用 Docker Hub 镜像，**不需要源码即可启动**。

**首次默认密码**：前台 123456 / 后台 admin admin123 —— **部署后第一件事：后台「安全与账号」修改两个密码。**

---

## ✨ 功能一览

### 前台（登录后可见）
- **密码门禁**：服务端 302 拦截 + API 401 双重保护，未登录连站点数据都拿不到
- **玻璃拟态 UI**：极光流动背景、5 套主题（含赛博朋克）、强调色、圆角/模糊度/列数均可后台调
- **主题快速切换**：顶栏一键切「明亮 / 夜间 / 赛博朋克」，访客偏好存本地
- **设备自适应**：自动识别电脑 / 平板 / 手机 / 电视，按比例调整列数、卡片密度与间距
- **内外网自动切换**：自动探测当前处于家庭内网还是外网，顶栏可一键切「自动 / 内网 / 外网」
- **智能搜索**：/ 快捷键聚焦，站内实时过滤；默认**百度**，可切 Google / Bing / DuckDuckGo；输入网址直接打开
- **分类导航**：横向胶囊 + 左右滑动键，分区卡片、置顶、图标、内外网角标、点击统计
- **一键退出**：顶栏「退出」按钮清除前后台会话并返回登录页（后台可控制显示开关）
- **密码保险箱**：每次点开都要输**管理员密码**，收起即清除；可在后台设置临时解锁时长，到期自动恢复
- **加载与动画**：首屏骨架屏、图标懒加载 + 服务端缓存、卡片交错入场、尊重系统「减少动画」偏好

### 后台控制台
| 模块 | 能力 |
| --- | --- |
| 仪表盘 | 站点/分类/内外网/双栈/自动识别数、累计点击、分类分布条、热门排行、快速上手 |
| 网站管理 | 添加/编辑/删除、批量删除与重新识别、分页筛选、粘贴网址即时预览智能识别结果、内外网双地址、置顶、隐藏、自定义图标或 emoji、**双击名称/网址行内修改** |
| 分类管理 | 自动创建的分类可改名/换色/换图标，删除时站点自动迁移到「其他收藏」 |
| 识别规则 | 自定义「域名片段 / 关键词 → 分类」，4 个常见规则预设，一键重识别「其他收藏」或全部站点 |
| 批量导入 | 书签 HTML / 历史 JSON / 文本列表，先预览每条的自动识别分类与内外网，逐条改名称/网址/分类、跳过已存在项，确认后自动去重入库 |
| 密码保险箱 | 名称/账号/密码/网址/分组/备注、显示隐藏、一键复制、搜索 |
| 外观设置 | 站点信息、5 套主题、强调色、布局、背景、圆角/列数/模糊、前台每个显示元素独立开关、自定义 CSS、默认搜索引擎、设备自适应开关 |
| 内外网设置 | 自动识别开关、默认模式、内网特征串、内网探测 URL、按网络过滤、双栈站点一览 |
| 安全与账号 | 修改前台访问密码 / 管理员密码（改完全部旧会话立即失效）、会话有效期、保险箱临时解锁时长 |
| 备份与数据 | 导出 JSON、还原、**一键获取全部网站 Logo**、批量重新识别、重置 |

### 自动分类引擎
内置 15 类基础分类（AI 智能 / 开发工具 / 设计创意 / 影音娱乐 / 阅读资讯 / 效率办公 / 网络工具 / 购物生活 / 学习教育 / 金融理财 / 游戏世界 / 社交媒体 / 云与服务 / NAS 与家庭网络 / 其他收藏），另覆盖**影视资源、字幕与追番、PT 与下载、网盘与资源、订阅与域名**等真实站点类型。

- 域名精确优先 + 词边界关键词匹配，修复了「ip 命中 description、nas 命中 business、pt 命中 apt」等误判
- 标题品牌词优先（避免域名里含 pt 就把 Navidrome 误判为 PT 站）
- 书签文件夹名作为强提示，支持中英文别名（影视 / 字幕 / PT / 工具 / AI / 开发 / 网盘…）
- 新增站点、导入书签、导入历史都会**自动建立对应分类**
- 识别不准时可在后台「识别规则」页自己加规则，无需改代码

### 内外网判定规则
- 内网：127.* / 10.* / 192.168.* / 172.16-31.* / *.local / *.lan / *.home.arpa / localhost，以及含 nas、router、synology、portainer、jellyfin 等提示词的服务
- 外网：公网域名
- **双栈**：同时具备内网 IP 与外网域名，前台按当前环境自动选链接
- 可配置「仅内网可达的探测 URL」精准判断

---

## 🚀 一、NAS / Docker Compose 部署

### 快速开始
1. 下载 [docker-compose.yml](<docker-compose.yml>) 到 NAS 目录（飞牛通常是 /vol1/1000/docker/aurora-nav）
2. 编辑环境变量改掉默认密码
3. 启动：

        docker compose -p aurora-nav up -d

4. 打开 http://NAS的IP:4000

> 目录名含中文（如「导航」）必须加 -p aurora-nav，否则 Compose 会报 project name must not be empty。

- 宿主机 4000 映射到容器 8787，改端口只改 compose 里左边那个数
- 数据持久化在 ./data/data.json，**升级/重建容器不会丢数据**
- 容器内以非 root 运行，启动脚本自动修正挂载目录属主，无需手工 chown
- 升级：docker compose -p aurora-nav pull && docker compose -p aurora-nav up -d

### 飞牛 NAS（FnOS）完整 Compose

图形界面：Docker → Compose → 新增项目，项目名 aurora-nav，粘贴下面配置，点「构建并启动」。

```yaml
services:
  aurora-nav:
    image: xiaoluya/aurora-nav:latest
    container_name: aurora-nav
    restart: unless-stopped
    ports:
      - "4000:8787"
    volumes:
      - ./data:/app/data
    environment:
      TZ: Asia/Shanghai
      PORT: 8787
      DATA_DIR: /app/data
      NAV_ADMIN_USER: admin
      NAV_ADMIN_PASSWORD: "改成你的管理员密码"
      NAV_VIEW_PASSWORD: "改成你的前台访问密码"
      NAV_SECRET: ""
    healthcheck:
      test: ["CMD", "node", "-e", "fetch('http://127.0.0.1:8787/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
```

> **飞牛注意事项**
> - 数据卷通常在 /vol1/1000/docker/（存储池编号可能不同），用 df -h 确认
> - 4000 端口冲突就改左边那个数，容器内固定 8787 不要动
> - 外网访问：飞牛自带反向代理或 Lucky / NPM 转发到 http://127.0.0.1:4000，再在网站管理里给 NAS 服务填「外网地址」即可自动切换

### 群晖 / 绿联 / 极空间 / 威联通
Container Manager → 项目 → 新增 → 从 docker-compose.yml 创建，项目名 aurora-nav，卷映射 ./data → /app/data，端口 4000:8787。完整分步见 [docs/02-NAS部署.md](<docs/02-NAS部署.md>)。

---

## ☁️ 二、Cloudflare Workers 部署

> 个人部署推荐直接用上面的 Docker 镜像；Workers 部署需要私有源码，仅项目维护者可用。此处保留说明供了解架构与免费额度。

1. 创建 KV 命名空间：npx wrangler kv namespace create NAV_KV
2. 把返回的 id 填进 wrangler.toml 的 [[kv_namespaces]]
3. 设置会话密钥：npx wrangler secret put NAV_SECRET
4. 改 [vars] 里的默认密码后 npx wrangler deploy
5. 部署完成给出 https://aurora-nav.<你的子域>.workers.dev

**关键点**
- 静态页面内联进 Worker，不需要配置 Workers Static Assets
- 会话密钥用 wrangler secret put，不要写进 wrangler.toml
- KV id 不进公开仓库

**已知坑：Pbkdf2 failed**
Cloudflare Workers 的 WebCrypto 限制 PBKDF2 迭代数 ≤ 100000，本地 Node 不限制，所以「本地能跑、线上炸」。本项目已固定 100000，旧版 120000 哈希会在首次请求自动重建。

**免费额度**：Workers 每天 10 万请求、KV 每天 10 万读 / 1000 写，个人使用足够。

---

## 🔐 默认账号与安全

| 用途 | 账号 | 密码 |
| --- | --- | --- |
| 前台访问 | — | 123456 |
| 后台管理 | admin | admin123 |

**部署后第一件事：后台「安全与账号」修改两个密码。**

- 密码：PBKDF2-SHA256 / 100,000 次迭代 / 随机盐
- 会话：HMAC-SHA256 签名的 HttpOnly + SameSite=Lax Cookie
- 前台 API 与页面双重鉴权，保险箱数据不会下发到未登录前台
- 改密码后所有旧会话立即失效（会话 epoch），前台刷新会跳登录页
- 额外防护：CSP / X-Frame-Options / no-store / 登录限速 / DevTools 打开时遮蔽敏感视图
- 前台顶栏「退出」按钮可一键清除前后台会话

> 保险箱为方便记忆的轻量功能，内容以明文存在你自己的 KV / JSON 里，定位不是专业密码管理器，请勿存放极高敏感凭据。

---

## 📥 导入书签 / 历史记录

### 浏览器书签（Chrome / Edge / Firefox / Safari）
1. 书签管理器 → 导出书签，得到 .html
2. 后台「批量导入 → 浏览器书签」上传或粘贴
3. 点「解析并预览识别结果」，每条显示自动识别的分类、内外网、置信度
4. 可取消勾选、逐条改**名称 / 网址 / 分类**、用书签文件夹名建分类
5. 点「确认导入并自动分类」，自动去重并按需新建分类

### 一键获取本地浏览器历史（A 方案：扩展）
浏览器不允许网页直接读历史，所以提供插件（也可直接在后台「批量导入 → 历史记录」页点「下载插件 ZIP」获取）：

1. 下载 [aurora-nav-history-extension.zip](<aurora-nav-history-extension.zip>) 或后台页的 ZIP，解压成一个文件夹
2. chrome://extensions → 开发者模式 → 加载已解压的扩展程序 → 选解压后的目录
3. 点工具栏 ✦ 图标，填**导航页地址**和**管理员密码**（已登录过 /admin 可留空）
4. 选天数 / 条数，点「一键读取并导入」

> ⚠️ 导入接口需要管理员会话，必须填**管理员密码**（不是前台访问密码）。扩展只申请 history / storage / tabs / clipboardWrite，数据只发到你自己的导航页，无遥测。

### 其他方案
- **B 手动粘贴**：从浏览器导出历史 JSON，或用任意方式生成网址列表，粘贴到后台导入框
- **C 手动兜底**：后台「批量导入 → 历史记录」粘贴 Chrome Takeout JSON 或每行一个网址

纯文本格式示例：

    少数派 https://sspai.com
    https://www.producthunt.com Product Hunt
    http://192.168.1.30:8080 家庭相册

导入时自动去重、按访问次数排序、自动识别建分类、自动分配 Logo。

---

## 🖼️ 自动获取网站 Logo

/api/icon 代理按以下顺序取图标，任一成功即缓存：站点自身的 apple-touch-icon / rel=icon / og:image → /favicon.ico → Google S2 → DuckDuckGo → icon.horse → favicon.im。全部失败时生成**彩色渐变首字母**占位（按域名哈希上色，不再是灰方块）。

前台每张卡片都有即时渐变占位垫底，图片加载完成淡入，失败自动回退，绝不空白。后台「备份与数据 → 一键获取全部网站 Logo」可批量补齐，保留自定义图标与 emoji。

---

## 🔧 配置项

| 变量 | 默认 | 说明 |
| --- | --- | --- |
| PORT | 8787 | 容器内监听端口（compose 已映射宿主机 4000） |
| DATA_DIR | ./data | JSON 数据目录 |
| NAV_SECRET | 自动生成 | HMAC 会话签名密钥，多实例/迁移时请固定 |
| NAV_ADMIN_USER | admin | 初始管理员账号名 |
| NAV_ADMIN_PASSWORD | admin123 | 初始管理员密码 |
| NAV_VIEW_PASSWORD | 123456 | 初始前台访问密码 |
| TZ | Asia/Shanghai | 时区 |

---

## 📁 公开仓库内容

| 文件 | 说明 |
| --- | --- |
| [docker-compose.yml](<docker-compose.yml>) | 直接拉 Docker Hub 镜像，无需源码 |
| [aurora-nav-history-extension.zip](<aurora-nav-history-extension.zip>) | Chrome/Edge 历史一键导入扩展，解压后加载 |
| [docs/](<docs/>) | 完整教程：快速开始 / NAS / Cloudflare / 后台功能 / 导入与扩展 / 常见问题 |
| [preview/](<preview/>) | 界面效果截图 |
| [.env.example](<.env.example>) | 环境变量示例 |
| [LICENSE](<LICENSE>) | MIT |

> **核心源码存放在私有仓库 xiaolurenya/aurora-nav-private，不对外公开。** 本公开仓库不含 src/ / public/ / scripts/ 源码，仅提供编译后的镜像与文档；镜像可直接部署使用。

---

## ❓ 常见问题

**Q：外网访问 NAS 服务怎么配？**
在网站管理里给站点同时填「内网地址」如 http://192.168.1.10:5000 和「外网地址」如 https://nas.example.com，前台就会自动切换。

**Q：忘记管理员密码？**
删除 data/data.json（或清空 KV 的 aurora:data:v1）会用环境变量默认密码重新初始化，**但会丢失所有自定义数据**，请先导出备份。

**Q：改了前台访问密码，旧页面为什么自动退出？**
刻意设计：会话 epoch 递增，所有旧 Cookie 立即失效，刷新会跳登录页并提示「会话已失效」。

**Q：登录慢？**
早期版本每个请求都写 KV，已改为「仅数据变化时写入」，登录到卡片可见约 250-300 ms。

**Q：开浏览器调试模式能看到未授权数据吗？**
不能。站点/分类/保险箱全部由服务端鉴权通过后下发，前端源码不含数据；未登录页面 302、API 401。

**Q：保险箱能设置多久免密？**
后台「安全与账号 → 保险箱临时解锁时长（分钟）」。默认 0 = 每次点开都输管理员密码、收起即清；填 10 = 10 分钟内免密，到期自动恢复。即使已登录后台，前台保险箱仍要输密码。

**Q：图标获取不到？**
图标代理有多源兜底，全部失败会显示按域名哈希着色的彩色渐变首字母。也可在「网站管理 → 编辑」里填自定义图标 URL 或 emoji。

**Q：分类识别不准？**
后台「识别规则」页加一条「域名片段 / 关键词 → 分类」，保存后点「重识别其他收藏」或「重识别全部」立即生效。

**Q：本机用 NAS IP 访问容器端口超时？**
某些 NAS 宿主网络层挂了 XDP/eBPF 程序，本机自访问自身 IP 会被拦，127.0.0.1 正常、局域网其他设备正常。与本项目无关。

**Q：CF 免费额度够吗？**
够：Workers 每天 10 万请求、KV 每天 10 万读 / 1000 写。

**Q：仓库地址？**
https://github.com/xiaolurenya/aurora-nav

---

## 📄 License

MIT · 随心改造，数据归你所有。
