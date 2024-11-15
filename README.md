这个 Dockerfile 构建了一个支持全模块的 Nginx 镜像，包含了 HTTPS、Lua 脚本支持、Sub Filter、HTTP/2 等常用功能，能够在 ARMv7 架构上运行。根据您的实际需求，您可能需要调整或添加更多模块和配置选项。

docker build -t nginx-full-modules-armv7 .

构建完成后，可以使用以下命令运行容器：

docker run -d -p 80:80 -p 443:443 --name nginx-container nginx-full-modules-armv7
