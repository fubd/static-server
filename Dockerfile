# --- STAGE 1: Builder ---
# 这个阶段负责编译 TypeScript 和安装所有依赖
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# 复制 package.json 和 lock 文件
COPY package*.json ./

# 安装所有依赖，包括 devDependencies，因为我们需要 TypeScript 来构建
RUN npm install

# 复制所有源代码
COPY . .

# 执行构建命令，将 TypeScript 编译成 JavaScript
RUN npm run build

# --- STAGE 2: Production ---
# 这个阶段只包含运行应用所必需的东西
FROM node:20-alpine AS production

WORKDIR /usr/src/app

# 从 builder 阶段复制 package.json 和 lock 文件
COPY package*.json ./

# 只安装生产环境依赖，这会大大减小镜像体积
RUN npm install --only=production

# 从 builder 阶段复制编译好的 dist 目录
COPY --from=builder /usr/src/app/dist ./dist

# 暴露容器端口（由你的代码决定）
EXPOSE 3000

# 容器启动时执行的默认命令
CMD [ "node", "dist/index.js" ]
