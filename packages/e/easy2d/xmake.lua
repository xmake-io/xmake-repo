package("easy2d")
    set_homepage("https://github.com/ChestnutYueyue/Easy2D")
    set_description("A lightweight 2D game engine for Windows")
    set_license("MIT")

    -- 支持tag压缩包和git仓库拉取
    set_urls("https://github.com/ChestnutYueyue/Easy2D/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ChestnutYueyue/Easy2D.git")
             
    add_versions("v2.1.27", "C6360616B035992CEECD9C64048398AEE0EA691E233C5600F2726C34071B32B9")

    -- 配置项：是否编译为动态库（原生默认静态）
    add_configs("shared", {
        description = "Build shared library.",
        default = false,
        type = "boolean"
    })

    -- 系统链接库（拆分通用+MinGW专属）
    local win_base_libs = {"user32", "gdi32", "shell32", "winmm", "imm32", "version", "ole32", "comdlg32", "dinput8", "d2d1", "dwrite", "dxguid"}
    local mingw_extra_libs = {"windowscodecs", "mfplat", "mfreadwrite", "shlwapi", "xaudio2_8"}
    add_syslinks(win_base_libs)
    on_load("mingw", function(package)
        package:add("syslinks", mingw_extra_libs)
    end)

    -- 加载阶段：动态库模式下添加宏定义
    on_load("windows", "mingw", function(package)
        if package:config("shared") then
            package:add("defines", "EASY2D_SHARED")
        end
    end)

    -- 安装逻辑（核心修正：匹配真实目录结构）
    on_install("windows", "mingw", function(package)
        local configs = {}
        -- 构建模式：debug/release（影响库名后缀）
        configs.mode = package:is_debug() and "debug" or "release"
        -- 库类型：静态/动态
        if package:config("shared") then
            configs.kind = "shared"
        else
            configs.kind = "static"
        end
        -- 传递C++17语言标准（原生要求）
        configs.cxflags = "/std:c++17"
        
        -- 调用xmake工具链安装（复用原生xmake.lua的编译逻辑）
        import("package.tools.xmake").install(package, configs)

        -- 核心修正：按真实目录结构复制头文件
        -- 原目录：easy2d/Easy2D/include/easy2d/  → 安装后：installdir/include/easy2d/
        -- 原目录：easy2d/Easy2D/include/spdlog/  → 安装后：installdir/include/spdlog/
        os.cp("easy2d/Easy2D/include/easy2d", package:installdir("include"))
        os.cp("easy2d/Easy2D/include/spdlog", package:installdir("include"))
    end)

    -- 测试逻辑（适配修正后的头文件路径）
    on_test(function(package)
        -- 验证核心头文件存在（路径：include/easy2d/easy2d.h）
        assert(package:has_cxxincludes("easy2d/easy2d.h", {configs = {languages = "c++17"}}))
        -- 验证spdlog头文件（可选，确保依赖头文件也安装成功）
        assert(package:has_cxxincludes("spdlog/spdlog.h", {configs = {languages = "c++17"}}))
        
        -- 验证代码片段编译（路径匹配真实的头文件层级）
        assert(package:check_cxxsnippets({test = [[
            #include <easy2d/easy2d.h>
            void test() {
                easy2d::Window::create(L"Test Window", 800, 600);
            }
        ]]}, {
            configs = {languages = "c++17"},
            includes = "easy2d/easy2d.h"
        }))

        -- 验证链接（区分debug/release库名后缀）
        local lib_suffix = package:is_debug() and "d" or ""
        local libname = is_plat("mingw") and ("easy2d" .. lib_suffix) or ("libeasy2d" .. lib_suffix)
        assert(package:has_links(libname, {linksdirs = package:installdir("lib")}))
    end)