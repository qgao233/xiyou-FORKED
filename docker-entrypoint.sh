#!/bin/bash
set -e

echo "=========================================="
echo "  XiYou瑗挎父 Docker Starting..."
echo "=========================================="

# Configure database connection - sql/mysql.php
SQL_MYSQL_PHP="/var/www/html/sql/mysql.php"
if [ -f "$SQL_MYSQL_PHP" ]; then
    echo "[Config] Writing sql/mysql.php..."
    cat > "$SQL_MYSQL_PHP" << 'ENDOFFILE'
<?php

$mysqla1 = 'MYSQL_HOST_PLACEHOLDER';
$mysqla2 = 'MYSQL_USER_PLACEHOLDER';
$mysqla3 = 'MYSQL_PASSWORD_PLACEHOLDER';

$conn=mysql_connect($mysqla1,$mysqla2,$mysqla3)or die ("DB Connection Failed");
mysql_select_db('MYSQL_DB_XXJY_PLACEHOLDER', $conn);
?>
ENDOFFILE
    sed -i "s/MYSQL_HOST_PLACEHOLDER/${MYSQL_HOST:-127.0.0.1}/g" "$SQL_MYSQL_PHP"
    sed -i "s/MYSQL_USER_PLACEHOLDER/${MYSQL_USER:-root}/g" "$SQL_MYSQL_PHP"
    sed -i "s/MYSQL_PASSWORD_PLACEHOLDER/${MYSQL_PASSWORD:-root}/g" "$SQL_MYSQL_PHP"
    sed -i "s/MYSQL_DB_XXJY_PLACEHOLDER/${MYSQL_DB_XXJY:-xxjyuser}/g" "$SQL_MYSQL_PHP"
    echo "[Config] sql/mysql.php done"
fi

# Configure database connection - fqxy/sql/mysql.php
FQXY_MYSQL_PHP="/var/www/html/fqxy/sql/mysql.php"
if [ -f "$FQXY_MYSQL_PHP" ]; then
    echo "[Config] Writing fqxy/sql/mysql.php..."
    cat > "$FQXY_MYSQL_PHP" << 'ENDOFFILE'
<?php

$mysqla1 = 'MYSQL_HOST_PLACEHOLDER';
$mysqla2 = 'MYSQL_USER_PLACEHOLDER';
$mysqla3 = 'MYSQL_PASSWORD_PLACEHOLDER';

$mysqlroot=$mysqlroot+1;
if ($mysqlroot==1) {
$conn=@mysql_connect($mysqla1,$mysqla2,$mysqla3)or die ("DB Connection Failed");
mysql_select_db('MYSQL_DB_XYY_PLACEHOLDER', $conn);
}
?>
ENDOFFILE
    sed -i "s/MYSQL_HOST_PLACEHOLDER/${MYSQL_HOST:-127.0.0.1}/g" "$FQXY_MYSQL_PHP"
    sed -i "s/MYSQL_USER_PLACEHOLDER/${MYSQL_USER:-root}/g" "$FQXY_MYSQL_PHP"
    sed -i "s/MYSQL_PASSWORD_PLACEHOLDER/${MYSQL_PASSWORD:-root}/g" "$FQXY_MYSQL_PHP"
    sed -i "s/MYSQL_DB_XYY_PLACEHOLDER/${MYSQL_DB_XYY:-xyy}/g" "$FQXY_MYSQL_PHP"
    echo "[Config] fqxy/sql/mysql.php done"
fi

# Configure site host - config/config.php
CONFIG_PHP="/var/www/html/config/config.php"
if [ -f "$CONFIG_PHP" ]; then
    echo "[Config] Writing config/config.php..."
    cat > "$CONFIG_PHP" << 'ENDOFFILE'
<?php

$config['host'] = 'SITE_HOST_PLACEHOLDER';
ENDOFFILE
    sed -i "s/SITE_HOST_PLACEHOLDER/${SITE_HOST:-localhost}/g" "$CONFIG_PHP"
    echo "[Config] config/config.php done"
fi

# Configure URL routing - fqxy/url/url.php
URL_PHP="/var/www/html/fqxy/url/url.php"
if [ -f "$URL_PHP" ]; then
    echo "[Config] Writing fqxy/url/url.php..."
    cat > "$URL_PHP" << 'ENDOFFILE'
<?php

include_once (__DIR__.'/../../config/Common.php');

$urlid=1;

if ($urlid==1) {
$xxjyurl=config_item('host');
$url=config_item('host');
} elseif($urlid==2){  
$xxjyurl="SITE_HOST_PLACEHOLDER";
$url="SITE_HOST_PLACEHOLDER";
}else{
$xxjyurl=config_item('host');
$url=config_item('host');
}

// Internal address for cURL communication between containers
$internal_host = 'web:80';
?>
ENDOFFILE
    sed -i "s/SITE_HOST_PLACEHOLDER/${SITE_HOST:-localhost}/g" "$URL_PHP"
    echo "[Config] fqxy/url/url.php done"
fi

# Set data directory permissions
echo "[Permission] Setting data directory permissions..."
chown -R www-data:www-data /var/www/html/ache 2>/dev/null || true
chown -R www-data:www-data /var/www/html/fqxy/ache 2>/dev/null || true

echo ""
echo "=========================================="
echo "  Configuration Summary"
echo "=========================================="
echo "  Site Host: ${SITE_HOST:-localhost}"
echo "  Database:  ${MYSQL_HOST:-db}:${MYSQL_PORT:-3306}"
echo "  DB Names:  ${MYSQL_DB_XXJY:-xxjyuser} / ${MYSQL_DB_XYY:-xyy}"
echo "=========================================="
echo ""

# Execute main command
exec "$@"
