# ===============================================
#  Configuration
# ===============================================
include .env
export

IMAGE_NAME ?= registry.cn-hangzhou.aliyuncs.com/fubd_own/static-server
TAG ?= latest
# 关键：定义我们想要支持的平台
PLATFORMS = linux/amd64,linux/arm64

# ===============================================
#  Development Commands (for local coding)
# ===============================================
.PHONY: dev-up dev-down dev-logs dev-shell

# 这些命令保持不变，因为它们用于本地快速迭代
dev-up:
	docker compose -f docker compose.dev.yml up --build -d

dev-down:
	docker compose -f docker compose.dev.yml down

dev-logs:
	docker compose -f docker compose.dev.yml logs -f

dev-shell:
	docker compose -f docker compose.dev.yml exec app sh

# ===============================================
#  Image Build & Release Commands (for CI/CD)
# ===============================================
.PHONY: build release

# "build" 现在构建一个适合你当前机器架构的本地镜像，用于测试
build:
	docker buildx build --load --tag $(IMAGE_NAME):$(TAG) .

# "release" 命令现在会构建两个平台的镜像并直接推送到仓库
# 注意：buildx 的多平台构建必须直接 --push，不能先 build 再 push
release:
	docker buildx build --platform $(PLATFORMS) --tag $(IMAGE_NAME):$(TAG) --push .

# ===============================================
#  Production Commands (for deployment on server)
# ===============================================
.PHONY: prod-up prod-down prod-logs

# 生产命令保持不变，因为 Docker 会自动选择正确的架构
prod-up:
	docker pull $(IMAGE_NAME):$(TAG)
	docker compose -f docker compose.prod.yml up -d

prod-down:
	docker compose -f docker compose.prod.yml down

prod-logs:
	docker compose -f docker compose.prod.yml logs -f