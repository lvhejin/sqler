version="3.0.2"
service_name="sql-to-api"

echo "开发构建容器...版本号：${version}"
#docker build -t ${service_name}:${version} .
docker buildx build --platform linux/amd64 -t ${service_name}:${version} --load .

echo "查镜像是否存在："
docker images ${service_name}:${version}

echo "导出镜像文件..."
docker save ${service_name}:${version} -o ${service_name}-${version}.tar

echo "下载镜像包..."
sz ${service_name}-${version}.tar
