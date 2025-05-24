package("kokyu")
    set_homepage("https://www.dre.vanderbilt.edu/~schmidt/ACE.html")
    set_description("Kokyu - portable middleware scheduling framework designed to provide flexible scheduling/dispatching services within the context of higher-level middleware.")
    set_license("DOC")

    add_urls("https://github.com/DOCGroup/ACE_TAO/releases/download/$(version).tar.gz", {version = function (version) 
        return "ACE%2BTAO-" .. version:gsub("%.", "_")  .. "/ACE-" .. version
    end})

    add_versions("8.0.3", "d8fcd1f5fab609ab11ed86abdbd61e6d00d5305830fa6e57c17ce395af5e86dc")

    add_deps("ace", {configs = {shared = true}})

    on_load(function (package)
        package:add("defines", "ACE_HAS_CPP17")
        if package:is_plat("windows") then
            package:add("syslinks", "iphlpapi")
        end
        if package:config("shared") then
            package:add("defines", "KOKYU_HAS_DLL", "KOKYU_BUILD_DLL")
        else
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
            io.replace("include/makeinclude/platform_android.GNU", "PLATFORM_SSL_LDFLAGS += --exclude-libs libcrypto.a,libssl.a", "PLATFORM_SSL_LDFLAGS += -Xlinker -hidden-lcrypto -Xlinker -hidden-lssl", {plain = true})
        end
        os.rm("Kokyu/tests")
        os.cp("Kokyu/**.h", package:installdir("include/Kokyu"), {rootdir = "Kokyu"})
        os.cp("Kokyu/**.cpp", package:installdir("include/Kokyu"), {rootdir = "Kokyu"})
        os.cp("Kokyu/**.inl", package:installdir("include/Kokyu"), {rootdir = "Kokyu"})
        envs.LIBCHECK = "1"
        envs.ACE_ROOT = path.unix(os.curdir())
        envs.INSTALL_PREFIX = package:installdir()
        local ace_libdir
        local lib_paths = {}
        local packagedep = package:dep("ace")
        if packagedep then
            local fetchinfo = packagedep:fetch()
            if fetchinfo then
            for _, linkdir in ipairs(fetchinfo.linkdirs) do
                table.insert(lib_paths, linkdir)
            end
            end
        end
        ace_libdir = table.concat(lib_paths, " -L")
        ace_libdir = "-L" .. ace_libdir
        local configs = {
            "debug=" .. (package:is_debug() and "1" or "0"),
            "shared_libs=" .. (package:config("shared") and "1" or "0"),
            "static_libs=" .. (package:config("shared") and "0" or "1")
        }
        os.cd("Kokyu")
        io.replace("GNUmakefile.Kokyu", [[-L../lib]], ace_libdir, {plain = true})
        io.replace("GNUmakefile", "Kokyu %$%(%@%).-FIFO %$%(%@%)", "Kokyu $(@)", {plain = false})
        make.build(package, {"Kokyu"}, {envs = envs})
        make.make(package, {"install"}, {envs = envs})
    end)

    on_install("windows", function(package)
        import("package.tools.msbuild")
        local include_paths = {}
        local lib_paths = {}
        -- Fetch *ace* dependency
        local packagedep = package:dep("ace")
        if packagedep then
            local fetchinfo = packagedep:fetch()
            if fetchinfo then
            for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                table.insert(include_paths, includedir)
            end
            for _, linkdir in ipairs(fetchinfo.linkdirs) do
                table.insert(lib_paths, linkdir)
            end
            end
        end
        os.rm("Kokyu/tests")
        os.cp("Kokyu/**.h", package:installdir("include/Kokyu"), {rootdir = "Kokyu"})
        os.cp("Kokyu/**.cpp", package:installdir("include/Kokyu"), {rootdir = "Kokyu"})
        os.cp("Kokyu/**.inl", package:installdir("include/Kokyu"), {rootdir = "Kokyu"})
        os.cd("Kokyu")
        for _, vcxproj in ipairs({"Kokyu_vs2022.vcxproj"}) do
            io.replace(vcxproj,
            "<AdditionalIncludeDirectories>.-</AdditionalIncludeDirectories>",
            "<AdditionalIncludeDirectories>" .. table.concat(include_paths, ";") .. "</AdditionalIncludeDirectories>", {plain = false})
            io.replace(vcxproj,
            "<AdditionalLibraryDirectories>.-</AdditionalLibraryDirectories>",
            "<AdditionalLibraryDirectories>" .. table.concat(lib_paths, ";") .. "</AdditionalLibraryDirectories>", {plain = false})
            if package:has_runtime("MT", "MTd") then
            -- Allow MT, MTd
            io.replace(vcxproj, "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>", {plain = true})
            io.replace(vcxproj, "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>", {plain = true})
            end
            if not package:config("shared") then
            io.replace(vcxproj, "DynamicLibrary", "StaticLibrary", {plain = true})
            io.replace(vcxproj, "KOKYU_BUILD_DLL", "ACE_AS_STATIC_LIBS", {plain = true})
            end
            if package:config("shared") then
            io.replace(vcxproj, "KOKYU_BUILD_DLL", "ACE_BUILD_DLL;KOKYU_BUILD_DLL", {plain = true})
            end
            -- Allow use another Win SDK
            io.replace(vcxproj, "<WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>", "", {plain = true})
            -- Disable LTCG
            io.replace(vcxproj, "<WholeProgramOptimization>true</WholeProgramOptimization>", "", {plain = true})
        end
        local configs = { "Kokyu_vs2022.sln", "/t:Kokyu" }
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
        assert(package:check_cxxsnippets({test = [[
            #include <Kokyu/Kokyu.h>
            namespace Kokyu {
            class MyDispatcher : public Dispatcher_Impl 
            {
                public:
                    MyDispatcher() = default;

                private:
                    // Implement pure virtual functions
                    int init_i(const Dispatcher_Attributes& attr) override 
                    {
                        return 0;
                    }

                    int activate_i() override 
                    {
                        return 0;
                    }

                    int dispatch_i(const Dispatch_Command* cmd, 
                            const QoSDescriptor& qos) override 
                    {
                        return 0;
                    }

                    int shutdown_i() override 
                    {
                        return 0;
                    }
                };
            } // namespace Kokyu

            void test() {
                Kokyu::MyDispatcher dispatcher;
                Kokyu::Dispatcher_Attributes attr;
                auto result = dispatcher.init(attr);
            }
            ]]
            }, {configs = {languages = "c++17"}}))
    end)
