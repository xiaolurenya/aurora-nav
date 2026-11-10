#!/bin/bash
# Aurora Nav 一键升级（Compose / 本地构建通用）
# 用法：把本脚本放在 docker-compose.yml 同目录，执行 ./upgrade.sh
# 特点：自动备份 data/、自动识别 image 或 build、绝不删除数据卷、失败可回滚
set -e
cd "$(dirname "$0")"

CFG=""
for F in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  [ -f "$F" ] && { CFG="$F"; break; }
done
if [ -z "$CFG" ]; then echo "❌ 没找到 docker-compose.yml，请把脚本放在 compose 文件同目录"; exit 1; fi
echo "📄 使用 $CFG"

# 1) 备份数据（只复制，不删除）
if [ -d data ]; then
  BAK="data-backup-$(date +%Y%m%d-%H%M%S)"
  cp -a data "$BAK"
  echo "💾 已备份数据到 $BAK"
else
  echo "ℹ️ 首次安装，暂无 data/ 目录"
fi

# 2) 自动把固定旧版本 tag 改成 latest（用户不用手改 compose）
if grep -qE "image:\s*xiaoluya/aurora-nav:[0-9]" "$CFG"; then
  sed -i -E "s#(image:\s*xiaoluya/aurora-nav:)[0-9][0-9.]*#\1latest#" "$CFG"
  echo "🔄 已自动把镜像 tag 改为 :latest"
fi

# 3) 识别部署方式
PROJ=$(basename "$(pwd)")
if grep -qE '^\s*build\s*:' "$CFG"; then
  MODE="build"
  echo "🔧 检测到本地构建（build:）→ 重新构建镜像"
else
  MODE="image"
  echo "🐳 检测到 Hub 镜像（image:）→ 拉取最新镜像"
fi

# 4) 记录旧镜像，便于回滚
OLD=$(docker compose -p "$PROJ" -f "$CFG" images -q 2>/dev/null | head -1 || true)

# 5) 升级
if [ "$MODE" = "build" ]; then
  echo "ℹ️  本地构建模式：请确认本目录源码已是最新版（公开仓库只有文档，源码在私有仓库/你自己的项目副本）"
  echo "    若还没更新源码，先执行：git pull  或重新下载最新源码覆盖本目录（不要删 data/）"
  docker compose -p "$PROJ" -f "$CFG" build --pull
else
  docker compose -p "$PROJ" -f "$CFG" pull
fi
docker compose -p "$PROJ" -f "$CFG" up -d --force-recreate

# 6) 健康检查（从 compose 里读宿主机端口，默认 4000）
PORT=$(grep -oE '"[0-9]+:8787"' "$CFG" | head -1 | grep -oE '^[0-9]+' | tr -d '"' || true)
PORT=${PORT:-4000}
echo "⏳ 等待服务就绪（端口 $PORT）..."
OK=0
for i in $(seq 1 20); do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:$PORT/api/health" 2>/dev/null || true)
  [ "$CODE" = "200" ] && { OK=1; break; }
  sleep 2
done
if [ "$OK" = "1" ]; then
  echo "✅ 升级完成！前台刷新即可（数据完整保留）"
  echo "   当前镜像: $(docker compose -p "$PROJ" -f "$CFG" images -q 2>/dev/null | head -1)"
  echo "   备份目录: ${BAK:-无}"
else
  echo "⚠️ 健康检查未通过，请检查日志：docker compose -p "$PROJ" -f "$CFG" logs --tail=50"
  echo "   数据仍在 data/ 与备份中，未删除；旧镜像: ${OLD:-未知}"
  exit 1
fi
