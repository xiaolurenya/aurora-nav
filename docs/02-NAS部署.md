# 02 · NAS 部署（飞牛 / 群晖 / 绿联 / 极空间 / 威联通）

## 完整 docker-compose.yml

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

## 飞牛 FnOS

1. 文件管理新建 /vol1/1000/docker/aurora-nav，把 [docker-compose.yml](../docker-compose.yml) 放进去
2. Docker → Compose → 新增项目，项目名填 aurora-nav，粘贴上面配置
3. 点「启动」，等状态 healthy，访问 http://飞牛IP:4000

SSH 方式：

    cd /vol1/1000/docker/aurora-nav
    docker compose -p aurora-nav up -d

> 公开仓库不含源码，不能本地 build；直接用 Docker Hub 镜像即可。

## 群晖 / 绿联 / 极空间 / 威联通

Container Manager → 项目 → 新增 → 从 docker-compose.yml 创建，项目名 aurora-nav，卷映射 ./data → /app/data，端口 4000:8787。

## 注意事项

- 容器内以非 root 运行，自动修正 ./data 属主，无需手工 chown
- 4000 冲突就改 Compose 左边那个数，容器内固定 8787 不要动
- 数据持久化在 ./data/data.json，升级重建容器不丢
- 外网访问：反向代理转发到 127.0.0.1:4000，再在网站管理给 NAS 服务填「外网地址」即可自动切换
- 升级：docker compose -p aurora-nav pull && docker compose -p aurora-nav up -d
