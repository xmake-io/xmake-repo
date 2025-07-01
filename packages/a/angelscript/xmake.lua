package("angelscript")
    set_homepage("http://angelcode.com/angelscript/")
    set_description("Extremely flexible cross-platform scripting library designed to allow applications to extend their functionality through external scripts")
    set_license("zlib")

    add_urls("https://github.com/codecat/angelscript-mirror.git")
    add_urls("http://angelcode.com/angelscript/sdk/files/angelscript_$(version).zip")

    add_versions("2.37.0", "0c52d1688016a0b2484e9ca549471c4e295df060770c57840144c64815f54f10")
    add_versions("2.36.0", "33f95f7597bc0d88b097d35e7b1320d15419ffc5779851d9d2a6cccec57811b3")
    add_versions("2.35.1", "5c1096b6d6cf50c7e77ae93c736d35b69b07b1e5047161c7816bca25b413a18b")
    add_versions("2.35.0", "010dd45e23e734d46f5891d70e268607a12cb9ab12503dda42f842d9db7e8857")
    add_versions("2.34.0", "6faa043717522ae0fb2677d907ca5b0e35a79d28e5f83294565e6c6229bfbdf7")

    add_patches(">=2.34.0", "patches/msvc-arm64.patch", "1433f474870102e6fd8d0c9978b6d122a098cdecded29be70176b9dab534564f")

    add_configs("exceptions", {description = "Enable exception handling in script context", default = true, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    if on_check then
        on_check("mingw", function (package)
            if is_host("macosx") and package:is_arch("i386") and package:version():eq("2.37.0") then
                assert(false, "package(angelscript 2.37.0): Unsupported version on mingw|i386")
            end
        end)
    end

    on_load("windows|x86", "windows|x64", "linux", "android", "msys", "mingw", function (package)
        package:add("deps", "cmake")
    end)

    on_install("windows|x86", "windows|x64", "linux", "android", "msys", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DAS_NO_EXCEPTIONS=" .. (package:config("exceptions") and "OFF" or "ON"))

        if package:gitref() then
            os.cd("sdk")
        end
        os.cd("angelscript/projects/cmake")
        if package:is_plat("android") then
            io.gsub("CMakeLists.txt", "set_property", "#set_property")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_install("windows|arm64", function (package)
        local configs = {}
        configs.exceptions = package:config("exceptions")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include "angelscript.h"
            static void test() {
                std::cout << asGetLibraryVersion() << "\n";
            }
        ]]}, {configs = {languages = "c++11"}, includes = "angelscript.h"}))
    end)
