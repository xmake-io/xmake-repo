package("ace")
    set_homepage("https://www.dre.vanderbilt.edu/~schmidt/ACE.html")
    set_description("ACE (ADAPTIVE Communication Environment) is a C++ framework for implementing distributed and networked applications.")
    set_license("DOC")

    add_urls("https://github.com/DOCGroup/ACE_TAO/releases/download/$(version).tar.gz", {version = function (version) 
        return "ACE%2BTAO-" .. version:gsub("%.", "_")  .. "/ACE-" .. version
    end})

    add_versions("8.0.3", "d8fcd1f5fab609ab11ed86abdbd61e6d00d5305830fa6e57c17ce395af5e86dc")

    if not is_plat("windows") then
        add_configs("ssl", {description = "Build with OpenSSL support.", default = true, type = "boolean"})
    end

    on_load(function (package)
        package:add("defines", "ACE_HAS_CPP17")
        if package:is_plat("windows") then
            package:add("syslinks", "iphlpapi", "user32", "advapi32")
            package:add("defines", "WIN32")
        else
            if not package:is_plat("android") then
                package:add("deps", "autotools")
            end
            if package:is_plat("linux", "bsd") then
                package:add("syslinks", "pthread")
            end
        end
        if not package:is_plat("windows") and package:config("ssl") then
            package:add("deps", "openssl")
        end
        if not package:config("shared") then
            package:add("defines", "ACE_AS_STATIC_LIBS")
        end
    end)

    on_install("linux", "macosx", "bsd", "iphoneos", "android", function(package)
        import("package.tools.make")
        local envs = make.buildenvs(package)
        if package:is_plat("linux") then
            io.writefile("ace/config.h", [[#include "ace/config-linux.h"]])
            io.writefile("include/makeinclude/platform_macros.GNU", [[include $(ACE_ROOT)/include/makeinclude/platform_linux_common.GNU]])
        elseif package:is_plat("macosx") then
            io.writefile("ace/config.h", [[#include "ace/config-macosx.h"]])
            io.writefile("include/makeinclude/platform_macros.GNU", [[include $(ACE_ROOT)/include/makeinclude/platform_macosx.GNU]])
        elseif package:is_plat("bsd") then
            io.writefile("ace/config.h", [[#include "ace/config-freebsd.h"]])
            io.writefile("include/makeinclude/platform_macros.GNU", [[include $(ACE_ROOT)/include/makeinclude/platform_freebsd.GNU]])
        elseif package:is_plat("iphoneos") then
            io.writefile("ace/config.h", [[#include "ace/config-macosx-iOS.h"]])
            io.writefile("include/makeinclude/platform_macros.GNU", [[include $(ACE_ROOT)/include/makeinclude/platform_macosx_iOS.GNU]])
            envs.IPHONE_TARGET = "HARDWARE"
            io.replace("include/makeinclude/platform_macosx_iOS.GNU", "CCFLAGS += -DACE_HAS_IOS", "CCFLAGS += -DACE_HAS_IOS -std=c++17", {plain = true})
        else
            import("core.tool.toolchain")
            io.writefile("ace/config.h", [[#include "ace/config-android.h"]])
            io.writefile("include/makeinclude/platform_macros.GNU", [[include $(ACE_ROOT)/include/makeinclude/platform_android.GNU]])
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            local ndk_dir = ndk:config("ndk")
            envs.android_abi = package:arch()
            envs.android_ndk = path.unix(ndk_dir)
            envs.android_api = ndk_sdkver
            envs.ARFLAGS = [[rc]]
            io.replace("include/makeinclude/platform_android.GNU", "OCCFLAGS ?= -O3", "OCCFLAGS ?= -O3\nCCFLAGS += -std=c++17", {plain = true})
        end
        os.cp("ace/**.h", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.inl", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.cpp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.tpp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.ipp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.hpp", package:installdir("include/ace"), {rootdir = "ace"})
        envs.ACE_ROOT = os.curdir()
        local configs = {
            "debug=" .. (package:is_debug() and "1" or "0"),
            "shared_libs=" .. (package:config("shared") and "1" or "0"),
            "static_libs=" .. (package:config("shared") and "0" or "1"),
            "ssl=" .. (package:config("ssl") and "1" or "0"),
            "threads=1"
        }
        if package:config("ssl") then
            envs.SSL_ROOT = package:dep("openssl"):installdir()
            envs.SSL_INCDIR = package:dep("openssl"):installdir("include")
            envs.SSL_LIBDIR = package:dep("openssl"):installdir("lib")
        end
        os.cd("ace")
        make.build(package, configs, {envs = envs})
        os.trycp("**.dylib", package:installdir("lib"))
        os.trycp("**.so", package:installdir("lib"))
        os.trycp("**.a", package:installdir("lib"))
    end)

    on_install("windows", function(package)
        import("package.tools.msbuild")
        io.writefile("ace/config.h", [[#include "ace/config-win32.h"]])
        os.cp("ace/**.h", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.inl", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.cpp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.tpp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.ipp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.hpp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cd("ace")
        for _, vcxproj in ipairs({"ACE_vs2022.vcxproj",
                "Compression/ACE_Compression_vs2022.vcxproj",
                "Compression/rle/ACE_RLECompression_vs2022.vcxproj",
                "ETCL/ACE_ETCL_vs2022.vcxproj",
                "ETCL/ACE_ETCL_Parser_vs2022.vcxproj",
                "QoS/QoS_vs2022.vcxproj",
                "Monitor_Control/Monitor_Control_vs2022.vcxproj"}) do
            if package:has_runtime("MT", "MTd") then
                -- Allow MT, MTd
                io.replace(vcxproj, "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>", {plain = true})
                io.replace(vcxproj, "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>", {plain = true})
            end
            if not package:config("shared") then
                io.replace(vcxproj, "DynamicLibrary", "StaticLibrary", {plain = true})
                io.replace(vcxproj, "ACE_BUILD_DLL", "ACE_AS_STATIC_LIBS", {plain = true})
                io.replace(vcxproj, "ACE_[%w_]+_BUILD_DLL", "ACE_AS_STATIC_LIBS", {plain = false})
                io.replace(vcxproj, "[%w_]+_[%w_]+_BUILD_DLL", "ACE_AS_STATIC_LIBS", {plain = false})
            end
            -- Allow use another Win SDK
            io.replace(vcxproj, "<WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>", "", {plain = true})
            -- Disable LTCG
            io.replace(vcxproj, "<WholeProgramOptimization>true</WholeProgramOptimization>", "", {plain = true})
        end
        local configs = { "ACE_vs2022.sln" }
        local arch = package:is_arch("x64") and "x64" or "Win32"
        if package:is_arch("arm64") then
            arch = "ARM64"
        end
        local mode = package:is_debug() and "Debug" or "Release"
        table.insert(configs, "/p:Configuration=" .. mode)
        table.insert(configs, "/p:Platform=" .. arch)
        -- Wrap vstool so it would build for another vstools
        local msvc = import("core.tool.toolchain").load("msvc")
        local vs = msvc:config("vs")
        local vstool
        if     vs == "2015" then vstool = "v140"
        elseif vs == "2017" then vstool = "v141"
        elseif vs == "2019" then vstool = "v142"
        elseif vs == "2022" then vstool = "v143"
        end
        table.insert(configs, "/p:PlatformToolset=" .. vstool)
        msbuild.build(package, configs)
        os.cd("..")
        os.cp("**.lib", package:installdir("lib"))
        if package:config("shared") then
            os.cp("**.dll", package:installdir("bin"))
        end
    end)

    on_test(function (package)
        if package:is_plat("windows") then
            assert(package:check_cxxsnippets({test = [[
                    #define WIN32_LEAN_AND_MEAN
                    #include <windows.h>
                    #include <ace/ACE.h>
                    void test() {
                        auto c_name = ACE::compiler_name();
                    }
                ]]
            }, {configs = {languages = "c++17"}}))
        else
            assert(package:check_cxxsnippets({test = [[
                    #include <ace/ACE.h>
                    void test() {
                        auto c_name = ACE::compiler_name();
                    }
                ]]
            }, {configs = {languages = "c++17"}}))
        end
    end)
