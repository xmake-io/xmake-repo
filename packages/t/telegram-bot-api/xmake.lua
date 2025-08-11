package("telegram-bot-api")
    set_kind("binary")
    set_description("The server provides an HTTP API for creating Telegram Bots.")
    set_license("BSL-1.0")

    add_urls("https://github.com/tdlib/telegram-bot-api.git", {submodules = false})
    add_versions("9.1", "2e1fb0330c93a014f723f5b5d8befe9dc9fc1b7d")

    local tdlib_versions = {
        ["9.1"] = "1.8.51"
    }

    on_load(function (package)
        package:add("deps", "td " .. tdlib_versions[package:version_str()])
    end)
    
    on_install(function (package)
        io.replace("telegram-bot-api/ClientManager.cpp", [[#include "memprof/memprof.h"]], "", {plain = true})
        io.replace("telegram-bot-api/ClientManager.cpp", "if (is_memprof_on()) {", "#if 0", {plain = true})
        io.replace("telegram-bot-api/ClientManager.cpp", "success_rate());\n  }", "success_rate());\n  #endif", {plain = true})
        
        io.writefile("xmake.lua", ([[
            add_rules("mode.debug", "mode.release")
            add_requires("td %s", {configs = {shared = false}})
            target("telegram-bot-api")
                set_kind("binary")
                set_languages("c++17")
                add_files("telegram-bot-api/*.cpp")
                add_includedirs(".")
                add_packages("td")
                if is_plat("windows") then
                    add_defines("_SCL_SECURE_NO_WARNINGS", "_CRT_SECURE_NO_WARNINGS")
                    add_cxflags("/utf-8", "/GR-", "/W4", "/wd4100", "/wd4127", "/wd4324", "/wd4505", "/wd4814", "/wd4702", "/bigobj", {tools = {"cl", "clang_cl"}})
                    add_syslinks("shell32")
                end
                if is_plat("windows", "mingw", "msys") then
                    add_defines("NTDDI_VERSION=0x06020000", "WINVER=0x0602", "_WIN32_WINNT=0x0602", "PSAPI_VERSION=1", "NOMINMAX", "UNICODE", "_UNICODE", "WIN32_LEAN_AND_MEAN")
                end
                if is_plat("cygwin") then
                    add_defines("_DEFAULT_SOURCE=1", "FD_SETSIZE=4096")
                end
                if is_plat("macosx", "iphoneos") then
                    add_shflags("-Wl,-dead_strip")
                elseif is_plat("wasm") then
                    add_shflags("-Wl,--gc-sections")
                elseif is_plat("android") then
                    add_shflags("-Wl,--gc-sections", "-Wl,--exclude-libs,ALL", "-Wl,--icf=safe")
                else
                end
                if is_arch("x64", "x86_64") then
                    add_shflags("-Wl,-z,max-page-size=16384")
                end
                add_cxflags("-ffunction-sections", "-fdata-sections", "-fno-omit-frame-pointer", "-fno-exceptions", "-fno-rtti", {tools = {"clang", "gcc"}})
                add_shflags("-Wl,--gc-sections", "-Wl,--exclude-libs,ALL")
                add_defines("_FILE_OFFSET_BITS=64", "_GNU_SOURCE")
        ]]):format(tdlib_versions[package:version_str()]))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("telegram-bot-api --version")
    end)
