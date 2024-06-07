# 使用基础镜像
FROM ubuntu:latest

# 暴露端口
EXPOSE 8025 6378

ENV CONFIG="config.mysql.hcl"
ENV DRIVER="mysql"
ENV DSN="root:pwd@tcp(192.168.137.1)/sql_to_api?multiStatements=true&collation=utf8mb4_unicode_ci"

# 将可执行文件复制到镜像中
COPY SQLtoAPI /usr/bin/SQLtoAPI
copy config.mysql.hcl /usr/bin/config.mysql.hcl

# 设置可执行文件的权限
RUN chmod +x /usr/bin/SQLtoAPI

# 指定镜像启动时执行的命令
#CMD ["/usr/bin/SQLtoAPI", "-config=config.mysql.hcl", "-driver=mysql", "-dsn=root:pwd@tcp(192.168.137.1)/sql_to_api?multiStatements=true&collation=utf8mb4_unicode_ci" ]
#CMD ["/usr/bin/SQLtoAPI"]
# 指定镜像启动时执行的命令，并在shell中替换环境变量
CMD ["/bin/sh", "-c", "/usr/bin/SQLtoAPI -config=$CONFIG -driver=${DRIVER} -dsn=${DSN}"]