# 从 .env 文件加载环境变量，如果 .env 文件存在的话
-include .env
export

# 定义镜像名称和标签。如果 .env 中未定义，则使用以下默认值。
IMAGE_NAME ?= registry.cn-hangzhou.aliyuncs.com/fubd_own/static-server
TAG ?= latest

# 定义需要构建的目标平台
PLATFORMS = linux/amd64,linux/arm64


# ==============================================================================
# Development Commands (for local coding & testing)
# ==============================================================================
.PHONY: dev-up dev-down dev-logs dev-shell

# 使用 dev 配置启动开发环境 (带热重载)
dev-up:
	docker compose -f docker-compose.dev.yml up --build -d

# 关闭并清理开发环境容器
dev-down:
	docker compose -f docker-compose.dev.yml down

# 实时查看开发环境的日志
dev-logs:
	docker compose -f docker-compose.dev.yml logs -f

# 进入正在运行的开发容器的 shell
dev-shell:
	docker compose -f docker-compose.dev.yml exec app sh


# ==============================================================================
# Image Build & Release Commands (for CI/CD or manual release)
# ==============================================================================
.PHONY: build release

# [本地测试用] 构建一个适合你当前机器架构的生产镜像并加载到本地
build:
	docker buildx build --load --tag $(IMAGE_NAME):$(TAG) .

# [正式发布] 构建所有目标平台的镜像并直接推送到镜像仓库
# 注意: 多平台构建必须在一条命令内完成 build 和 push
release:
	docker buildx build --platform $(PLATFORMS) --tag $(IMAGE_NAME):$(TAG) --push .


# ==============================================================================
# Production Commands (for deployment on the server)
# ==============================================================================
.PHONY: prod-up prod-down prod-logs

# 在生产服务器上拉取最新镜像并启动/更新服务
prod-up:
	docker pull $(IMAGE_NAME):$(TAG)
	docker compose -f docker-compose.prod.yml up -d

# 关闭并清理生产环境容器
prod-down:
	docker compose -f docker-compose.prod.yml down

# 实时查看生产环境的日志
prod-logs:
	docker compose -f docker-compose.prod.yml logs -f