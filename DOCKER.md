# 小轩西游 Docker 部署指南

## 📋 项目分析

### 项目概述

本项目是经典 MMORPG《幻想西游》的民间复刻版本，基于 PHP + MySQL 的传统网页游戏架构。

### 技术栈

| 组件 | 版本 | 说明 |
|------|------|------|
| PHP | 5.6.42 | 使用已废弃的 `mysql_*` 扩展，必须使用 5.6 版本 |
| MySQL | 5.7 | 两个数据库：`xxjyuser`（用户数据）、`xyy`（游戏数据） |
| Apache | 2.4 | PHP 以 Apache 模块方式运行 |

### 项目结构

```
xiyou-FORKED/
├── index.php              # 入口文件（重定向到游戏页面）
├── config/                # 配置文件
│   ├── config.php         # 站点 Host 配置
│   └── Common.php         # 配置加载工具类
├── fqxy/                  # 游戏核心目录
│   ├── index.php          # 分区选择页面
│   ├── sql/mysql.php      # 游戏数据库连接
│   ├── url/url.php        # URL 路由配置
│   ├── acher/             # 游戏数据（排行榜、Boss 等）
│   ├── ache/              # 玩家存档（INI 文件）
│   ├── admin/             # GM 管理后台
│   ├── template/          # 游戏页面模板（100+ 页面）
│   ├── box/               # 宝箱系统
│   ├── npc/ npcc/         # NPC 交互
│   ├── cz/                # 充值系统
│   ├── wj/                # 玩家相关
│   └── wp/                # 物品系统
├── xxjy/                  # 用户社区
│   ├── index.php          # 社区首页
│   ├── login.php          # 登录
│   ├── regist.php         # 注册
│   └── xxjyindex.php      # 游戏主界面
├── admin/                 # 后台管理
├── class/                 # PHP 工具类（INI 文件操作）
├── sql/mysql.php          # 用户数据库连接
├── css/                   # 样式表
├── images/                # 静态图片资源
└── ache/                  # 根目录游戏数据
```

### 数据存储方式

- **MySQL 数据库**：用户账号、游戏基础数据
- **INI 文件**：玩家详细存档、游戏状态（`ache/` 目录）
- **文件锁**：并发控制（`acher/lock/`）

---

## 🐳 Docker 部署方案

### 架构设计

```
┌─────────────────────────────────────────┐
│            Docker Compose               │
│                                         │
│  ┌──────────────┐  ┌──────────────────┐ │
│  │   xiyou-web  │  │    xiyou-db      │ │
│  │  PHP 5.6     │  │   MySQL 5.7      │ │
│  │  + Apache    │──│                  │ │
│  │  :80 → 8080  │  │  :3306 → 3307   │ │
│  └──────────────┘  └──────────────────┘ │
│         │                  │            │
│    [game-data]        [mysql-data]      │
│     Volume             Volume           │
└─────────────────────────────────────────┘
```

### 文件清单

| 文件 | 用途 |
|------|------|
| `Dockerfile` | PHP 5.6 + Apache 镜像构建 |
| `docker-compose.yml` | 服务编排（Web + MySQL） |
| `docker-entrypoint.sh` | 容器启动时自动注入配置 |
| `.dockerignore` | 构建排除文件 |
| `.env.example` | 环境变量模板 |
| `docker/init-db/` | 数据库初始化 SQL |

---

## 🚀 快速开始

### 前置条件

- Docker >= 20.10
- Docker Compose >= 2.0
- 至少 512MB 可用内存

### 步骤一：准备环境配置

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑配置（可选，默认值即可本地运行）
# vim .env
```

关键配置项：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `WEB_PORT` | 8080 | Web 访问端口 |
| `SITE_HOST` | localhost | 站点域名/IP |
| `MYSQL_PASSWORD` | root | 数据库密码 |
| `DB_PORT` | 3307 | 数据库对外端口 |

### 步骤二：准备数据库

> ⚠️ **重要**：本项目需要预置游戏数据。README 中提到"数据库目录覆盖 mysql 的 data 目录"，你需要准备数据库文件。

**方式 A：使用现有数据库文件**

如果你已有数据库 data 目录：

```bash
# 停止容器（如果已启动）
docker compose down

# 将数据库 data 目录复制到 Docker volume
# 先找到 volume 路径
docker volume inspect xiyou-forked_mysql-data

# 将你的数据库文件复制到 volume 的 _data 目录中
```

**方式 B：手动导入 SQL**

如果有 `.sql` 导出文件：

```bash
# 先启动服务
docker compose up -d

# 等待 MySQL 就绪后导入
docker exec -i xiyou-db mysql -uroot -proot xxjyuser < xxjyuser.sql
docker exec -i xiyou-db mysql -uroot -proot xyy < xyy.sql
```

### 步骤三：启动服务

```bash
# 构建并启动所有服务
docker compose up -d --build

# 查看启动日志
docker compose logs -f

# 查看服务状态
docker compose ps
```

### 步骤四：访问游戏

| 页面 | 地址 |
|------|------|
| 游戏入口 | http://localhost:8080 |
| 社区登录 | http://localhost:8080/xxjy/index.php |
| 游戏分区 | http://localhost:8080/fqxy/index.php |
| GM 后台 | http://localhost:8080/admin/index.php |

---

## 🔧 常用运维命令

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看实时日志
docker compose logs -f web     # Web 服务日志
docker compose logs -f db      # 数据库日志

# 进入 Web 容器
docker exec -it xiyou-web bash

# 进入 MySQL
docker exec -it xiyou-db mysql -uroot -proot

# 重新构建镜像（代码更新后）
docker compose up -d --build

# 完全清除（含数据卷，慎用！）
docker compose down -v
```

---

## 📁 数据持久化

| Volume | 挂载路径 | 说明 |
|--------|----------|------|
| `mysql-data` | `/var/lib/mysql` | MySQL 数据文件 |
| `game-data` | `/var/www/html/ache` | 根目录玩家存档 |
| `game-data-fqxy` | `/var/www/html/fqxy/ache` | 游戏目录玩家存档 |

> 💡 游戏数据主要存储在 INI 文件中（`ache/` 目录），MySQL 存储用户账号等基础数据。两个 Volume 都需要持久化。

---

## ⚙️ 配置说明

### 自动配置

容器启动时，`docker-entrypoint.sh` 会自动根据环境变量注入以下配置：

- `config/config.php` → 站点 Host
- `sql/mysql.php` → 用户数据库连接
- `fqxy/sql/mysql.php` → 游戏数据库连接
- `fqxy/url/url.php` → URL 路由

### 手动配置

如需手动修改配置，可以取消 `docker-compose.yml` 中的注释：

```yaml
volumes:
  # 取消注释以挂载本地配置文件
  - ./config/config.php:/var/www/html/config/config.php
```

---

## 🌐 公网部署

### 方式一：直接暴露端口

修改 `.env`：

```bash
SITE_HOST=your-domain.com
WEB_PORT=80
```

### 方式二：Nginx 反向代理

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

---

## ❗ 注意事项

1. **PHP 版本**：项目使用了已废弃的 `mysql_*` 函数，必须使用 PHP 5.6，无法升级到 PHP 7+
2. **安全性**：`mysql_*` 函数无防 SQL 注入能力，建议仅在内网或测试环境使用
3. **短标签**：项目使用 PHP 短标签 `<?`，Dockerfile 已开启 `short_open_tag = On`
4. **数据库密码**：生产环境务必修改默认密码 `root`
5. **数据备份**：定期备份 `mysql-data` volume 和 `ache/` 目录

---

## 🐛 故障排查

### 数据库连接失败

```bash
# 检查 MySQL 是否就绪
docker compose logs db | grep "ready for connections"

# 测试数据库连接
docker exec -it xiyou-web php -r "mysql_connect('db', 'root', 'root') or die('fail');"
```

### 页面空白

```bash
# 查看 PHP 错误日志
docker exec -it xiyou-web cat /var/log/apache2/error.log

# 检查文件权限
docker exec -it xiyou-web ls -la /var/www/html/
```

### 游戏数据丢失

检查 `ache/` 目录的 Volume 是否正确挂载：

```bash
docker compose exec web ls -la /var/www/html/ache/
```
