#!/bin/bash
################################
#根据 tag 或者 commit 下载组件

#解析参数
bc_giturl=$1
bc_tag=$2
bc_commit=$3
bc_comDir=$4

#echo $bc_giturl
#echo $bc_tag
#echo $bc_commit
#echo $bc_comDir

#1.参数验证
if [ ! $bc_giturl ];then
    echo "config pod tag,git url empty"
    exit 1
fi

#2.配置 基础Pod目录
cd ../
#创建 pod的基础目录
if [ ! -d "$bc_comDir" ]
then
    mkdir -p "$bc_comDir"
fi

if [ $? -ne 0 ]; then
    echo "config pod tag,dir error"
    exit 1
fi

cd $bc_comDir
if [ $? -ne 0 ]; then
    echo "config pod tag,dir error"
    exit 1
fi

#重新clone
gitName=${bc_giturl##*/}
podName=${gitName%.git}
#删除以前下载 tag、commit 代码
rm -rf ${podName}

if [ $bc_tag ];then
    echo "\033[34m \r\n* 开始配置 $podName,$bc_tag \033[0m"
    git clone --branch $bc_tag $bc_giturl
else
    echo "\033[34m \r\n* 开始配置 $podName,$bc_commit \033[0m"
    git checkout $bc_commit
fi

if [ $? -ne 0 ]; then
    echo "配置组件失败"
    exit 1
fi

cd "${curDir}"

