package("easy2d")
    -- 基础信息（按需补充）
    set_homepage("https://github.com/ChestnutYueyue/Easy2D")  -- 你的远程库地址
    set_description("The easy2d package (custom remote repo)")
    set_license("MIT")  -- 按需修改为实际协议

    -- 核心：指定远程仓库地址 + 支持的分支/版本
    add_urls("https://github.com/ChestnutYueyue/Easy2D.git")  -- 你的 Gitee 仓库
    add_branches("dev", "main")  -- 声明支持的分支（如 dev、main）
    add_versions("dev", "dev")   -- 映射：版本标识 "dev" 对应仓库 dev 分支

    -- 可选：传递编译配置（如是否编译为动态库）
    add_configs("shared", {
        description = "Build shared library.",
        default = false,
        type = "boolean"
    })

    -- 安装逻辑：复用 XMake 内置工具编译（适配仓库自带的 xmake.lua）
    on_install(function (package)
        -- 整理编译配置
        local configs = {}
        -- 若配置了 shared，则编译为动态库
        if package:config("shared") then
            configs.kind = "shared"
        else
            configs.kind = "static"  -- 默认静态库
        end
        -- 传递分支：若指定了分支（如 dev），自动拉取对应分支源码
        if package:branch() then
            configs.branch = package:branch()
        end

        -- 核心：调用 XMake 内置工具安装（自动识别仓库的 xmake.lua）
        import("package.tools.xmake").install(package, configs)
    end)

    -- 测试逻辑：验证包是否安装成功（按需完善）
    on_test(function (package)
        -- -- 验证头文件存在（替换为 easy2d 实际的核心头文件）
        -- assert(package:has_cxxincludes("easy2d.h", {includes = package:installdir("include")}))
        -- -- 验证库文件可链接（替换为实际的库名）
        -- assert(package:has_links("easy2d", {linksdirs = package:installdir("lib")}))
    end)