# Aurora Nav · 极光导航

<p align="center"><img src="preview/logo.png" width="120" alt="Aurora Nav"></p>

一个自己托管的导航页。前台要输密码才看得到内容，后台加网址会自动认类型、建分类；书签和浏览器历史也能导进来，一样自动归类。顺带做了内外网切换、密码保险箱、大图标和设备自适应。

数据放在自己的机器上（NAS 的 `data/data.json`，或自己的 Cloudflare KV），核心源码在私有仓库，这里只放部署用的镜像、安装包和文档。

首次登录：前台 `123456`，后台 `admin` / `admin123`。装完第一件事是去后台「安全与账号」把这两个密码改掉。

[Releases 下载](https://github.com/xiaolurenya/aurora-nav/releases) ｜ [Docker Hub](https://hub.docker.com/r/xiaoluya/aurora-nav) ｜ [项目仓库](https://github.com/xiaolurenya/aurora-nav)

---

## 界面

| 设备 | 前台 | 后台 |
| --- | --- | --- |
| 电脑 | ![电脑前台](<preview/shot-home-desktop.png>) | ![电脑后台](<preview/shot-admin-desktop.png>) |
| 平板 | ![平板前台](<preview/shot-home-tablet.png>) | ![平板后台](<preview/shot-admin-tablet.png>) |
| 手机 | ![手机前台](<preview/shot-home-phone.png>) | ![手机后台](<preview/shot-admin-phone.png>) |

电脑、平板、手机、电视会按屏幕宽度自己调列数和卡片密度。手机端关掉了毛玻璃合成、离屏分区延迟渲染，滑动会顺一些。

---

## 跑起来

不想看文档的话，两条命令：

    docker pull xiaoluya/aurora-nav:latest
    docker run -d --name aurora-nav -p 4000:8787 -v ./data:/app/data \
      -e NAV_ADMIN_PASSWORD=你的管理员密码 \
      -e NAV_VIEW_PASSWORD=你的前台访问密码 \
      -e TZ=Asia/Shanghai \
      --restart unless-stopped xiaoluya/aurora-nav:latest

或者下载 [docker-compose.yml](<docker-compose.yml>) 后 `docker compose -p aurora-nav up -d`。

然后打开 `http://NAS的IP:4000`，前台输访问密码，后台在 `/admin`。

镜像是 linux/amd64，给 x86 的 NAS 用。目录名带中文（比如「导航」）时记得加 `-p aurora-nav`，不然 Compose 会报 project name must not be empty。数据都在 `./data/data.json`，重建容器不会丢。

---

## 有哪些东西

前台登录后：密码门禁（页面 302 + API 401）、5 套主题、顶栏切主题、站内搜索（默认百度，`/` 键聚焦）、分类胶囊、内外网自动切换、点击统计、退出按钮、密码保险箱。保险箱默认每次点开都要管理员密码，收起就清；需要的话可以在后台设一个临时解锁时长。

后台：

| 页面 | 能做什么 |
| --- | --- |
| 仪表盘 | 站点、分类、内外网、双栈数量，点击排行、分类分布 |
| 网站管理 | 增删改、批量删除与重识别、筛选、粘贴网址即时预览识别结果、内外网双地址、置顶、隐藏、双击名称/网址直接改、自定义图标 |
| 分类管理 | 改名换色换图标，置顶/上移/下移/拖拽排序，删分类时站点移到「其他收藏」 |
| 识别规则 | 自己加「域名片段 / 关键词 → 分类」，几个预设，一键重识别 |
| 批量导入 | 书签 HTML、历史 JSON、纯文本列表，先预览再逐条改，去重入库 |
| 密码保险箱 | 名称/账号/密码/网址/分组/备注，显示隐藏、复制、搜索 |
| 外观设置 | 站点信息、主题、强调色、布局、背景、圆角/列数/模糊、各显示元素开关、自定义 CSS、默认搜索引擎 |
| 内外网设置 | 自动识别开关、默认模式、内网特征串、探测 URL、按网络过滤 |
| 安全与账号 | 改两个密码（改完旧会话全失效）、会话有效期、保险箱临时解锁时长 |
| 备份与数据 | 导出/还原 JSON、批量补 Logo、批量重识别、重置 |

分类这块：内置 15 类基础的（AI、开发、设计、影音、阅读、效率、网络工具、购物、学习、金融、游戏、社交、云、NAS、其他），另外认得影视资源、字幕追番、PT、网盘、订阅域名这些。域名精确匹配优先，关键词按词边界比对，避免 `ip` 撞上 description、`nas` 撞上 business、`pt` 撞上 apt 这类误判；标题里的品牌词优先级更高，免得域名带 pt 就把 Navidrome 归成 PT 站。书签文件夹名也会当提示。认错了去「识别规则」加一条就行，不用改代码。

内外网判定：127/10/192.168/172.16-31、`*.local`、`*.lan`、`*.home.arpa`，以及域名里带 nas、router、synology、portainer、jellyfin 之类的算内网，公网域名算外网。两个地址都填了就按当前网络挑。也可以配一个只有内网能通的探测 URL 来判得更准。

图标：先找站点自己的 apple-touch-icon / rel=icon / og:image，再试 favicon.ico，然后 Google S2、DuckDuckGo、icon.horse、favicon.im；都拿不到就按域名哈希生成彩色渐变首字母。图标只保留一种格式：固定 60px 圆角框，整张图常态就 cover 放大到顶满四边、由圆角框裁成正好的满格。上传的、自动抓的、旧图、以后新增站点都一样，鼠标在不在上面都铺满；hover 只有一点轻微动效。不再自动改 PNG 像素，图标保持原样，自动抓取优先 256px 大图以免模糊。后台上传的图片和自动抓取的图标都原样保留，前台统一用 60px 圆角框 cover 铺满，SVG 保持矢量；旧图不用重传。

---

## NAS / Compose 部署

把 compose 文件放到 NAS 目录（飞牛一般在 `/vol1/1000/docker/` 下，具体用 `df -h` 看），改掉环境变量里的默认密码，`docker compose -p aurora-nav up -d`。

飞牛图形界面：Docker → Compose → 新增项目，项目名 `aurora-nav`，粘贴下面配置，构建并启动。

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

宿主机 4000 映射到容器 8787，要换端口改左边那个数，右边别动。4000 被占了同理。外网访问用飞牛自带的反向代理或 Lucky / NPM 转发到 `http://127.0.0.1:4000`，再在网站管理里给 NAS 服务填个外网地址，前台就会自动切。

群晖、绿联、极空间、威联通：Container Manager → 项目 → 新增 → 从 docker-compose.yml 创建，项目名 `aurora-nav`，卷 `./data → /app/data`，端口 `4000:8787`。分步图见 [docs/02-NAS部署.md](<docs/02-NAS部署.md>)。

容器内以非 root 运行，启动脚本会自己修挂载目录属主，不用手工 chown。

---

## Cloudflare Workers 部署

个人用建议直接上 Docker 镜像。Workers 这版需要私有源码，只有项目维护者能部署，这里留个说明。

1. `npx wrangler kv namespace create NAV_KV`
2. 把返回的 id 填进 `wrangler.toml` 的 `[[kv_namespaces]]`
3. `npx wrangler secret put NAV_SECRET`
4. 改 `[vars]` 里的默认密码，`npx wrangler deploy`
5. 部署完会给一个 `https://aurora-nav.<子域>.workers.dev`

静态页面内联进 Worker，不用配 Static Assets；会话密钥走 secret，别写进 toml；KV id 不进公开仓库。

有个坑值得记一下：Workers 的 WebCrypto 把 PBKDF2 迭代数卡在 100000，本地 Node 不卡，所以容易出现「本地能跑、线上炸」。这里固定用 100000，旧版 120000 的哈希会在首次请求自动重建。免费额度是 Workers 每天 10 万请求、KV 每天 10 万读 / 1000 写，个人用够了。

---

## 默认账号与安全

| 用途 | 账号 | 密码 |
| --- | --- | --- |
| 前台访问 | — | 123456 |
| 后台管理 | admin | admin123 |

部署后先去后台「安全与账号」把这两个改了。

- 密码用 PBKDF2-SHA256 / 100000 次迭代 / 随机盐
- 会话是 HMAC-SHA256 签名的 HttpOnly + SameSite=Lax Cookie
- 前台页面和 API 都鉴权，未登录拿不到站点和保险箱数据
- 改密码后旧会话立即失效（会话 epoch），刷新会回登录页
- 还加了 CSP / X-Frame-Options / no-store / 登录限速，DevTools 打开时遮住敏感视图

保险箱只是个方便记东西的轻量功能，内容明文存在你自己的 JSON / KV 里，不是专业密码管理器，别放特别敏感的凭据。

---

## 导入书签和历史

书签：浏览器里导出 `.html`，后台「批量导入 → 浏览器书签」上传或粘贴，点解析预览，每条会显示识别出的分类和内外网，可以取消勾选、改名改网址改分类，确认后去重入库。

历史记录网页读不到，所以做了个扩展，ZIP 和 CRX 两种，后台「批量导入 → 历史记录」页里也能直接下载：

1. 下载 [ZIP](<aurora-nav-history-extension.zip>) 或 [CRX](<aurora-nav-history-extension.crx>)
2. ZIP 的话解压成文件夹，`chrome://extensions` 开开发者模式，点左上角「加载已解压的扩展程序」选它。别点「打包扩展程序」，那个是生成 crx 用的，会要私钥然后报错。CRX 的话直接拖进扩展页，Chrome 拦第三方 CRX 就换 ZIP 方式。
3. 点工具栏图标，填导航页地址和管理员密码（不是前台密码），选天数条数，导入。

扩展只申请 history / storage / tabs / clipboardWrite，数据只发回你自己的导航页。不想装扩展就手动粘贴 Chrome Takeout JSON，或每行一个网址：

    少数派 https://sspai.com
    https://www.producthunt.com Product Hunt
    http://192.168.1.30:8080 家庭相册

导入时会去重、按访问次数排序、建分类、配 Logo。

---

## 配置项

| 变量 | 默认 | 说明 |
| --- | --- | --- |
| PORT | 8787 | 容器内监听端口（compose 映射到宿主机 4000） |
| DATA_DIR | ./data | JSON 数据目录 |
| NAV_SECRET | 自动生成 | HMAC 会话签名密钥，多实例或迁移时固定一个 |
| NAV_ADMIN_USER | admin | 初始管理员账号名 |
| NAV_ADMIN_PASSWORD | admin123 | 初始管理员密码 |
| NAV_VIEW_PASSWORD | 123456 | 初始前台访问密码 |
| TZ | Asia/Shanghai | 时区 |

---

## 这个仓库里有什么

| 文件 | 说明 |
| --- | --- |
| [Releases](https://github.com/xiaolurenya/aurora-nav/releases) | 飞牛 FPK、upgrade.sh、扩展 ZIP / CRX |
| [docker-compose.yml](<docker-compose.yml>) | 直接拉 Hub 镜像 |
| [aurora-nav.fpk](<aurora-nav.fpk>) | 飞牛应用中心安装包 |
| [upgrade.sh](<upgrade.sh>) | Compose / 构建用户的一键升级脚本 |
| [aurora-nav-history-extension.zip](<aurora-nav-history-extension.zip>) | 扩展，解压后加载 |
| [aurora-nav-history-extension.crx](<aurora-nav-history-extension.crx>) | 扩展，可拖入安装 |
| [docs/](<docs/>) | 快速开始 / NAS / Cloudflare / 后台功能 / 导入与扩展 / 常见问题 |
| [preview/](<preview/>) | 界面截图 |
| [.env.example](<.env.example>) | 环境变量示例 |
| [LICENSE](<LICENSE>) | MIT |

核心源码在私有仓库 `xiaolurenya/aurora-nav-private`，这里没有 `src/` `public/` `scripts/`。镜像可以直接部署。

---

## 常见问题

**外网怎么访问 NAS 上的服务？** 网站管理里给站点同时填内网地址（如 `http://192.168.1.10:5000`）和外网地址（如 `https://nas.example.com`），前台自己切。

**忘了管理员密码？** 删掉 `data/data.json`（或清空 KV 的 `aurora:data:v1`）会用环境变量里的默认密码重新初始化，但自定义数据全没了，先导出备份。

**改了前台密码旧页面怎么退出了？** 故意的，会话 epoch 递增，旧 Cookie 全失效，刷新回登录页。

**登录有点慢？** 早期版本每个请求都写 KV，现在改成只在数据变化时写，登录到卡片可见大概 250–300 ms。

**开调试模式能看到没授权的数据吗？** 看不到。站点、分类、保险箱都是服务端鉴权后才下发，前端源码里没有数据；未登录页面 302、API 401。

**保险箱能不能免密一会儿？** 后台「安全与账号 → 保险箱临时解锁时长（分钟）」。默认 0 是每次点开都输管理员密码、收起即清；填 10 就是 10 分钟内不用再输，到期恢复。就算已经登录后台，前台保险箱照样要密码。

**图标取不到？** 代理有好几个源，全失败会显示彩色渐变首字母。也可以在「网站管理 → 编辑」里填自定义图标 URL、上传本地图片或写个 emoji。

**分类认错了？** 后台「识别规则」加一条「域名片段 / 关键词 → 分类」，保存后点「重识别其他收藏」或「重识别全部」。

**用 NAS 自己的 IP 访问容器端口超时？** 有些 NAS 宿主网络挂了 XDP/eBPF，本机访问自身 IP 会被拦，127.0.0.1 和局域网其他设备都正常。这个跟项目没关系。

**CF 免费额度够吗？** 够，Workers 每天 10 万请求、KV 每天 10 万读 / 1000 写。

---

## 飞牛 FPK

到 [Releases](https://github.com/xiaolurenya/aurora-nav/releases/latest) 下载 `aurora-nav.fpk`，飞牛 OS → 应用中心 → 手动安装 / 导入 FPK，选文件。装完桌面出现「Aurora Nav 极光导航」，点开就能用，也可以 `http://飞牛IP:4000` 直接访问。

安装向导里有「访问端口」，默认 4000，跟别的应用冲突就改一个没被占的（比如 4100）；容器内固定 8787，桌面图标按你填的端口打开。数据在应用数据目录 `${TRIM_PKGVAR}/data`，卸载或重装不丢。FPK 固定拉 `xiaoluya/aurora-nav:1.4.4`（amd64）。

默认密码还是前台 `123456` / 后台 `admin` `admin123`，装完记得改。

### 已经装了旧版怎么升

手动装的 FPK 不会自己收到更新推送，`manifest.version` 只是个版本号，要升得装新包或换镜像 tag。

后台现在带版本检查（v1.3.1 起）：侧栏显示当前版本，发现 Releases 有新版会弹窗。点「一键更新」后有 90 秒倒计时，每 3 秒探一次服务，恢复了自动刷新；网络慢会继续等，超时只提示、不假装成功。随时也能点侧栏「更新」手动查。容器没开自动重建的话，弹窗会给出可复制的命令和 [upgrade.sh](<upgrade.sh>) 下载。

飞牛用户也可以直接导入新 FPK：应用中心有「升级」入口就走升级，没有就先卸载（卸载向导里选「保留数据」）再装。站点、分类、密码、保险箱都留着。

Compose / 自己构建的用户，在 compose 目录放一个 `upgrade.sh` 然后执行：

    ./upgrade.sh

脚本会备份 `data/`、把旧 tag 改成 `latest`、pull、up -d、查健康。它不会执行 `down -v`，也不会删 `data/`。等价的两条命令是 `docker compose pull && docker compose up -d`，`data/` 卷别动就行。

旧版上传过的自定义图标还是 128px，升级后到后台重新传一次才会变成 512px 高清；自动抓取的图标会自动变大变清晰。

---

## 最近改了什么

- 图标统一 60px 圆角方块铺满，去掉所有自动抠图逻辑，整页一致
- 后台加了版本检查和一键更新，90 秒倒计时后自动刷新
- 飞牛 FPK 修好了桌面图标点「打开」没反应的问题，换了 Logo，安装时能改端口
- 分类可以置顶/拖拽排序；网站名称网址双击就能改；自定义图标支持本地上传
- 分类规则可以自己加，另外固化了一批 PT 站域名
- 保险箱默认每次都要密码，可设临时解锁时长；前台加了退出按钮
- 登录少读一次 KV；手机端滚动顺了一些
- 浏览器历史扩展提供 ZIP 和 CRX 两种

---

## License

MIT。随便改，数据是你自己的。

## 本地构建用户升级

用 `build: .` 而不是 `image:` 安装的，`docker compose pull` 不会更新源码。先把最新源码更新到项目目录（私有仓库或你自己的副本，别删 data/），然后在 compose 目录执行 `./upgrade.sh`，或手动 `git pull && docker compose build --pull && docker compose up -d`。脚本会自动识别 build 模式、备份 data/、不删卷。

## 后台一键更新

从 v1.4.8 起，飞牛 FPK 和 Docker Compose 都默认挂载 `/var/run/docker.sock`，镜像里带 docker CLI。后台检测到新版本后点「一键更新」，会由独立进程拉新镜像、用相同数据卷重建容器，90 秒倒计时后自动刷新，数据不丢。已安装的用户运行一次 `./upgrade.sh` 会幂等补挂 socket。若宿主机 docker 组 gid 不是 994，用 `stat -c %g /var/run/docker.sock` 查出来，在 compose 里改 `DOCKER_GID`。

## 飞牛 APP 与首次登录

桌面入口走飞牛统一网关（iframe 同源 HTTPS `/app/aurora-nav`），APP 里点图标也能打开，不再拼 `http://IP:端口` 被拦成「无法访问此页面」；直连 IP:端口 仍可用。容器运行 UID/GID 为飞牛默认 1000，其他机器可改 `DOCKER_GID`。

首次打开登录页会有一张引导卡：前台密码 `123456`、后台 `admin / admin123`，可复制、可关闭；改过密码后自动不再显示。装完请第一时间到后台「安全与账号」修改。

## 飞牛 APP 登录页（v1.5.0）

登录页现在不依赖 ES module：解锁按钮、后台/前台切换、密码显隐、引导卡关闭/复制都有一段普通内联脚本兜底，即使 iframe 里 module 被拦也能用。首次引导卡是 HTML 默认可见，改过密码后自动隐藏。
