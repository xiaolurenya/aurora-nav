# 03 · Cloudflare Workers 部署

> 个人部署推荐直接用 Docker Hub 镜像（见 [01-快速开始](<01-快速开始.md>)）。Workers 部署需要私有源码，仅项目维护者可用；本文保留架构说明与常见坑。

## 架构

- 单个 Worker 同时提供页面与 API，静态资源内联进 Worker，不需要配置 Workers Static Assets
- 数据存 Cloudflare KV（一个 key：aurora:data:v1）
- 会话密钥用 wrangler secret put NAV_SECRET，不写进配置文件
- KV id 不进公开仓库

## 维护者步骤

    npx wrangler kv namespace create NAV_KV
    # 把返回的 id 填进 wrangler.toml 的 [[kv_namespaces]]
    npx wrangler secret put NAV_SECRET
    npx wrangler deploy

部署完成给出 https://aurora-nav.<子域>.workers.dev

## 已知坑

**Pbkdf2 failed: iteration counts above 100000 are not supported**

Cloudflare Workers 的 WebCrypto 限制 PBKDF2 迭代数 ≤ 100000，本地 Node 不限制，所以「本地能跑、线上炸」。本项目已固定 100000，旧版 120000 哈希会在首次请求自动重建。

## 免费额度

Workers 每天 10 万请求、KV 每天 10 万读 / 1000 写，个人使用足够。
