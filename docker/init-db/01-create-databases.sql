-- ============================================================
-- 小轩西游 数据库初始化脚本
-- 创建游戏所需的两个数据库
-- ============================================================

-- 创建用户数据库（xxjyuser）
-- 如果 docker-compose.yml 中已配置 MYSQL_DATABASE，则此库已自动创建
CREATE DATABASE IF NOT EXISTS `xxjyuser` 
    DEFAULT CHARACTER SET utf8mb4 
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- 创建游戏数据库（xyy）
CREATE DATABASE IF NOT EXISTS `xyy` 
    DEFAULT CHARACTER SET utf8mb4 
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- 授权 root 用户访问两个数据库
GRANT ALL PRIVILEGES ON `xxjyuser`.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON `xyy`.* TO 'root'@'%';
FLUSH PRIVILEGES;
