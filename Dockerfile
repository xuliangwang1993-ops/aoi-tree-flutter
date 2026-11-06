# 构建 Flutter web 产物只需要 Flutter SDK，无需 Android/iOS 工具链
# 用官方 flutter:latest，里面内置 Dart 和必要的 build tools
FROM ghcr.io/cirruslabs/flutter:latest as builder

WORKDIR /build

# 拷贝工程文件，只需要 pubspec 和源码，不需要 build/ 产物
COPY aoi_tree/pubspec.* ./aoi_tree/
COPY aoi_tree/lib ./aoi_tree/lib
COPY aoi_tree/web ./aoi_tree/web
COPY aoi_tree/assets ./aoi_tree/assets
COPY aoi_tree/analysis_options.yaml ./aoi_tree/

WORKDIR /build/aoi_tree

# 获取依赖并构建 web
RUN flutter pub get && \
    flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=false

# 第二阶段：用 nginx 托管
FROM nginx:alpine

# 从构建阶段拷贝静态文件
COPY --from=builder /build/aoi_tree/build/web /usr/share/nginx/html

# nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
