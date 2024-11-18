# 使用 ARMv7 架构的 Debian 镜像作为基础镜像
FROM arm32v7/debian:bullseye-slim

# 安装编译 Nginx 所需的工具和库
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libpcre3-dev \
    libpcre++-dev \
    liblua5.1-0-dev \
    libgd-dev \
    libxslt1-dev \
    libjpeg-dev \
    libpng-dev \
    libxml2-dev \
    git \
    unzip \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 安装 OpenSSL（支持 HTTPS）
RUN apt-get update && apt-get install -y openssl

# 下载并编译 Nginx
RUN mkdir -p /usr/src/nginx && \
    cd /usr/src/nginx && \
    wget https://nginx.org/download/nginx-1.24.0.tar.gz && \
    tar -xzvf nginx-1.24.0.tar.gz && \
    cd nginx-1.24.0 && \
    # 下载 Lua 模块（ngx_http_lua_module）
    git clone https://github.com/openresty/lua-nginx-module.git && \
    # 下载 Sub Filter 模块（ngx_http_substitutions_filter_module）
    wget https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/refs/tags/v0.8.1.tar.gz && \
    tar -xzvf v0.8.1.tar.gz
    # 配置并编译 Nginx，启用各种常用模块
RUN ./configure --prefix=/etc/nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_sub_module \
    --add-module=lua-nginx-module \
    --add-module=ngx_http_substitutions_filter_module \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --with-http_dav_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_secure_link_module \
    --with-http_xslt_module \
    --with-http_image_filter_module \
    --with-http_geoip_module \
    --with-http_lua_module \
    --with-http_auth_request_module \
    --with-compat \
    && make && make install

# 删除编译文件以减小镜像大小
RUN rm -rf /usr/src/nginx

# 复制自定义的 Nginx 配置文件和 SSL 证书文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY ssl /etc/nginx/ssl

# 设置工作目录为 Nginx 默认的 HTML 目录
WORKDIR /usr/share/nginx/html

# 暴露端口 80 和 443
EXPOSE 80 443

# 设置容器启动命令
CMD ["nginx", "-g", "daemon off;"]
