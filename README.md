# 线下docker开发环境

## 1 目录结构
```
/
├── data                        数据目录
│   ├── composer                composer数据缓存目录
├── services                    服务构建文件和配置文件目录
│   ├── php                     PHP7.4.19 配置目录(可自己任意更改需要的版本号 .env中)
│   └── node15                  NODE15.7.0配置目录（也可切换版本 .env中）
├── logs                        日志目录
│   ├── php                     PHP日志（如错误日志，慢日志等）
├── docker-compose.sample.yml   Docker 服务配置示例文件
├── env.smaple                  环境配置示例文件
└── www                         具体代码代码目录（前端、后端均可）
```
## 2 使用

### 1、依赖安装

- git [git下载地址](https://git-scm.com/downloads)
  
- docker [各系统docker安装安装方法](https://yeasy.gitbook.io/docker_practice/install/)

- docker-compose (window\mac安装完docker desktop后自带docker-compose)

**特别注意**

widows安装完docker需要做一下操作

① 开启Hyper-v虚拟化服务
```
控制面板->程序->启用或关闭windows功能
在Hyper-v 选项前打上勾然后重启电脑
```
② docker desktop关闭WSL 2虚拟化服务
```
右键docker desktop图标 打开setting->General
把use the WSL 2 based engine 前边的勾去掉 重启docker desktop
```
③ windows需要映射目录，否则创建容器时会报找不到映射目录
```
最好的方式是把em-develop这个目录直接映射给docker
操作方法
右键docker desktop->settings->resourse->file sharing
如em-develop的目录在 c:\User\admin\em-develop
则把这个目录加到file sharing中去 然后应用就OK了
```

 **注意：windows一定要在做以上三个步骤之后再去构建镜像和启动容器，否则会报错**

### 2、拷贝并重新命名配置文件（windows直接在文件夹里边操作，也可用powerShell在对应目录输入一下命令执行）
```
# 进入对应目录
cd em-develop 
# 拷贝env配置
cp env.sample .env
# 拷贝docker-compose 编排配置文件
cp docker-compose.sample.yml docker-compose.yml
# docker-compose up -d # 构建所有镜像并创建容器且在后台运行 （也可 ./run.sh执行）
```
### 3、进入容器

```
docker exec -it php bash
```

### 4、管理代码

```bash
# 生成SSH KEY
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub # 将公钥信息添加到Gitlab中: https://gitlab.evente.cn/profile/keys
```

- 后端

```
# 进入容器
docker exec -it php bash
# 切换到工作目录 
# 可git clone具体项目到此目录 然后composer install安装 安装完成可直接在真机打开此目录开发
cd www
git clone xxx项目.git
cd xxx项目
composer install
```

- 前端
```
# 进入容器
docker exec -it node15 bash
# 切换到工作目录 
# 可git clone具体项目到此目录 然后yarn install安装 安装完成可直接在真机打开此目录开发
cd www
git clone xxx项目.git
cd xxx项目
yarn install
yarn start
```

### 5、端口映射
在实际开发中后端和前端需要用到不同的端口

```
# docker-compose.yml配置文件中ports处
ports:
    - "9800:9800"
    - "9805:9805"
```
规则 - "宿主机端口:容器端口"

上列配置代表容器的9800和9805端口映射到宿主机9800和9805端口 http://localhost:9800 即可访问服务

### 6、管理命令

如需管理服务，请在命令后面加上服务器名称，例如：

```bash
$ docker-compose up                         # 创建并且启动所有容器
$ docker-compose up -d                      # 创建并且后台运行方式启动所有容器
$ docker-compose up php node15              # 创建并且启动node15、php的多个容器
$ docker-compose up -d php node15           # 创建并且已后台运行的方式启动node15、php容器


$ docker-compose start php                  # 启动php容器服务
$ docker-compose stop php                   # 停止php容器服务
$ docker-compose restart php                # 重启PHP容器服务
$ docker-compose build php                  # 构建或者重新构建php服务

$ docker-compose rm php                     # 删除并且停止php容器
$ docker-compose down                       # 停止并删除容器，网络，图像和挂载卷（这是删除所有容器并删除相关网络）
```
需要注意的是：
- docker-compose build xxx 适用于本地镜像构建 如 引用本地dockerfile来进行构建的情况
- docker-compose up xxx 使用于需要从远端镜像构建 如 image:mysql8.0.22 这种直接从docker镜像源构建的情况
- 当然docker-compose up 也包换了本地镜像构建 意思是用 up 可适用于构建本地镜像以及远端拉取镜像构建的情况

### 7、PHP扩展

增加需要的扩展：
可用的扩展列表在.env中有说明
```bash
PHP_EXTENSIONS=pdo_mysql,opcache,redis       # PHP 要安装的扩展列表，英文逗号隔开
```
如果当前列表中没有你想要的扩展，可执行安装第三方扩展

- 按照当前的扩展模式扩展
- 在dockerfile中安装第三方依赖的扩展

强烈建议不要在docker容器中去安装扩展和服务，应该再dockerfile中去安装，这样所安装的服务和扩展都在镜像中，重启启动容器时，所安装的服务都不会被重置。

### 8、扩展其它镜像服务

按照当前的目录结构增加对应目录和配置即可

① .env增加对应的常量配置

② service增加对应的目录结构

③ data目录增加对应的数据存储目录（如果需要，如mysql、redis等需要存储数据的服务）

④ log目录增加对应的log目录（如果需要 如nginx、php等需要存储log的服务）

⑤ 增加docker-compose编排配置文件对应的服务类容（参照php、node15服务配置）
```
# 需要dockerfile构建的镜像配置

build:
    context: ./services/php # 这是指定构建目录（里边必须包含dockerfile文件）
    args: # 这是设置常量传递 只有在这里配置过的常量才能传递到dockerfile中
        PHP_VERSION: php:${PHP_VERSION}-fpm-alpine
        CONTAINER_PACKAGE_URL: ${CONTAINER_PACKAGE_URL}
        PHP_EXTENSIONS: ${PHP_EXTENSIONS}
        TZ: "$TZ"

# 不需要dockerfile构建的镜像配置（直接从dockerHub中拉取）build那一项整体去掉，换成下边这样的配置

image: mysql:${MYSQL5_VERSION}
```
[docker-compose.yml配置官方文档](https://docs.docker.com/compose/compose-file/compose-file-v3/)








