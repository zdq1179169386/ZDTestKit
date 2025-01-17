#!/bin/bash
################################
#根据 branch 下载、更新组件

#解析参数
bc_giturl=$1
bc_branch=$2
bc_comDir=$4

if [ ! $bc_comDir ];then
    #没有这个参数，自己截取目录
    bc_comDir=`echo ${bc_branch} | grep -o '\:.*\/'`
    bc_comDir=`echo ${bc_comDir:1:(${#bc_comDir}-2)}`
    #所有基础组件都在这个目录
    if [ ! $bc_comDir ];then
        #默认放在基础组件目录
        bc_comDir="ios-component"
    fi
fi

#1.参数验证
if [ ! $bc_giturl ];then
    echo   "error:git url参数 为空"
    exit 1
fi

#2.配置 基础Pod目录
cd ../
#创建 pod的基础目录
if [ ! -d "$bc_comDir" ]
then
    mkdir -p "$bc_comDir"
fi
cd $bc_comDir
if [ $? -ne 0 ]; then
    echo "config pod dir error"
    exit 1
fi


#3.配置 具体的Pod
gitName=${bc_giturl##*/}
podName=${gitName%.git}
localGit=${PWD}/${podName}/.git
echo "\033[34m \r\n* 开始配置 $podName \033[0m"

#    echo  $gitUrl
#    echo  $gitName
#    echo  $podName
#    echo  $localGit

if [ ! -d "$localGit" ]; then
    echo "start git clone..."
    git clone $bc_giturl

    if [ $bc_branch ];then
    cd "${PWD}/${podName}/"
        git fetch
        git checkout $bc_branch
    fi

    if [ $? -ne 0 ]; then
    echo "ZHUpdate install error"
    exit 1
    fi

else
    echo "start git pull..."
    curDir=${PWD}
    cd "${PWD}/${podName}/"
    #        git reset --hard && git clean -dfx

    if [ $bc_branch ];then
        git fetch
        git checkout $bc_branch
        git pull
    else
        git pull
    fi


    if [ $? -ne 0 ]; then
        echo "ZHUpdate install error"
        exit 1
    fi
    cd "${curDir}"
fi



#kBCPodslist=(
#$bc_giturl
#)


##2.更新当前工作目录
#echo "2.开始更新工作目录..."
#startDir=${PWD}
#git pull
#
#
#if [ $? -ne 0 ]; then #"eq"
#    echo "2.git pull error"
#    exit 1
#fi

##3.进入到上级目录，创建
#echo "3.开始初始化基础组建..."
#cd ..
#for i in ${kBCPodslist[@]}
#do
#done




##4.执行Pod
#echo "4.pod install..."
#cd $startDir
#pod install --no-repo-update
#
#if [ $? -ne 0 ]; then #"eq"
#echo "4.pod install error"
#exit 1
#fi
#
#
##
#if [ $? -eq 0 ]; then
#    echo "LAST.git pull success"
#else
#    echo "LAST.git pull error"
#    exit 1
#fi

