#!/usr/bin/ruby
#1.本地仓库+源码集成
#bc_useRemote = 0，表示使用本地仓库，
#clone仓库到本地目录(group/组件),使用 :path 生成 Development Pods
#适合组件开发阶段，边修改，边提交。

#2.本地仓库+lib集成
#bc_useRemote = 0，表示使用本地仓库，
#clone仓库到本地目录(group/组件)，使用 :podspec 指定 lib.podsepc,引用编译好的 framework
#适合组件开发阶段，引入编译好的 framework

#3.远程仓库+branch源码集成
#bc_useRemote = 1，表示使用远程仓库
#bc_useBranch = 1，表示使用分支
#适合引入他人频繁更新的组件

#4.远程仓库+tag源码集成
#bc_useRemote = 1，表示使用远程仓库
#bc_useBranch = 0，表示使用 Tag
#适合引入他人稳定的组件

#5.远程仓库+lib集成
# bc_useRemote = 1，表示使用远程仓库
#下载tag、commit代码到本地目录(group+Lib/组件）,使用 :podspec 指定 lib.podsepc,引用编译好的library
#适合比较稳定不经常改动组件，减少编译时间

def bc_pod (pName, pGitInfo)
    bc_useBranch = pGitInfo[:bc_useBranch];#是否使用分支
    bc_git = pGitInfo[:git];#git url
    bc_tag = pGitInfo[:tag];#git tag
    bc_commit = pGitInfo[:commit];#git commit
    bc_branch = pGitInfo[:bc_branch];#git 分支名称
    bc_useRemote = pGitInfo[:bc_useRemote];#使用使用远程仓库
    bc_subSpecs = pGitInfo[:bc_subSpecs];#sub spec
    #同一个仓库下的子模块
    bc_subModule = pGitInfo[:bc_subModule];#sub module
    if(bc_subModule.blank?)
        bc_subModule = pName
    end
    #是否使用编译后的lib
    bc_useLib = pGitInfo[:bc_useLib];#是否使用lib
    if(bc_useLib.blank?)
        bc_useLib = 0 #默认不适用lib,使用源码方式
    end
    #是否使用通用framework模式
    bc_universal = pGitInfo[:bc_universal];#是否使用lib
    if(bc_universal.blank?)
        bc_universal = 0 #默认不适用通用模式
    end
    #匹配仓库group
    bc_dirRegex=/\:.*\//;
    bc_MatchData=bc_dirRegex.match(bc_git);
    bc_comDir=bc_MatchData[0];
    if(!bc_comDir.blank?)
        bc_comDir[0]="";
        bc_comDir[-1]="";
    else
        #使用默认目录
        bc_comDir="ios-component";
    end
    #这里本来是对应仓库的路径，group太多，所以再加一个父目录component
    bc_comPath = "component/"+bc_comDir
    
    #先判断是否使用本地代码
    if(bc_useRemote.blank? || bc_useRemote<=0 || bc_git.blank?)
        #使用本地仓库
        if(bc_useLib<=0)
            #源码编译
            pod bc_subModule, :subspecs => bc_subSpecs, :path => "../#{bc_comPath}/#{pName}/", :inhibit_warnings => pGitInfo[:inhibit_warnings]
        else
            #使用编译后的lib
            pod bc_subModule, :podspec => "../#{bc_comPath}/#{pName}/Library/Library.podspec", :inhibit_warnings => pGitInfo[:inhibit_warnings]
        end
        return
    end
    
    #使用远程仓库代码，非branch方式，tag、commit方式
    if(bc_useBranch<=0 && bc_useLib<=0)
        #不使用lib，源码编译
        if(!bc_tag.blank?)
            #tag模式
            pod bc_subModule, :subspecs => bc_subSpecs, :git => bc_git, :tag => bc_tag, :inhibit_warnings => pGitInfo[:inhibit_warnings]
        else
            #commit模式
            if(!bc_subSpecs.blank?)
                pod bc_subModule, :subspecs => bc_subSpecs, :git => bc_git, :commit => bc_commit, :inhibit_warnings => pGitInfo[:inhibit_warnings]
            else
                pod bc_subModule, :git => bc_git, :commit => bc_commit, :inhibit_warnings => pGitInfo[:inhibit_warnings]
            end
        end
        return
    elsif(bc_useBranch<=0 && bc_useLib>0)
        #使用编译后的lib
        bc_comPath = bc_comPath+"-Lib"
        if(!bc_tag.blank?)
            #tag模式
            system "sh ZHComTag.sh #{bc_git} #{bc_tag} \"\" #{bc_comPath}"
            pod bc_subModule, :podspec => "../#{bc_comPath}/#{pName}/Library/Library.podspec", :inhibit_warnings => pGitInfo[:inhibit_warnings]
        else
            #commit模式
            system "sh ZHComTag.sh #{bc_git} \"\" #{bc_commit} #{bc_comPath}"
            pod bc_subModule, :podspec => "../#{bc_comPath}/#{pName}/Library/Library.podspec", :inhibit_warnings => pGitInfo[:inhibit_warnings]
        end
        return
    end
    
    #使用远程仓库代码，branch方式，develop pod模式
    system "sh ZHComBranch.sh #{bc_git} #{bc_branch} #{bc_subModule} #{bc_comPath}"
    if(bc_useLib<=0)
        if (bc_universal<=0)
        #不使用lib，源码编译
        pod bc_subModule, :subspecs => bc_subSpecs, :path => "../#{bc_comPath}/#{pName}/", :inhibit_warnings => pGitInfo[:inhibit_warnings]
        else
        #不使用lib，使用通用framework
        podspecName = "#{pName}-universal.podspec"
        pod bc_subModule, :path => "../#{bc_comPath}/#{pName}/#{podspecName}", :inhibit_warnings => pGitInfo[:inhibit_warnings]  
        end
    else
        #使用编译后的lib
        pod bc_subModule, :podspec => "../#{bc_comPath}/#{pName}/Library/Library.podspec", :inhibit_warnings => pGitInfo[:inhibit_warnings]
    end
    
end
