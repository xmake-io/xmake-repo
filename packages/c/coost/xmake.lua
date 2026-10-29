package("coost")
    set_homepage("https://github.com/idealvin/coost")
    set_description("A tiny boost library in C++.")
    set_license("MIT")

    add_urls("https://github.com/idealvin/coost/archive/refs/tags/$(version).tar.gz",
             "https://github.com/idealvin/coost.git")

    add_versions("v4.0.1", "4b8fad3283f5c5c12f6ca54da2da772c8e128cb471a56ac42729a6cbdddd0093")
    add_versions("v3.0.2", "922ba21fb9a922c84f6a4b3bd568ed3b3463ccb1ae906cd7c49d90c7f0359b24")
    add_versions("v3.0.1", "f2285d59dc8317dd2494d7628a56f10de9b814d90b86aedf93a3305f94c6ae1a")
    add_versions("v3.0.0", "f962201201cd77aaf45f33d72bd012231a31d4310d30e9bb580ffb1e94c8148d")

    add_patches("3.0.2", "https://github.com/idealvin/coost/commit/c9488af72e9086ef1d910e29f9efa4b4210a5190.patch", "837feb2b49dc5d162f27175627689680a61e54e761dcf972f0e27896249addc6")

    for _, name in ipairs({"libcurl", "openssl", "libbacktrace"}) do
        local default = false
        if name == "libbacktrace" and is_plat("linux") then
            default = true
        end
        add_configs(name, {description = "Enable " .. name .. " library.", default = default, type = "boolean"})
    end

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    elseif is_plat("bsd") then
        add_syslinks("pthread")
    elseif is_plat("windows") then
        add_syslinks("ws2_32")
    end

    on_load(function (package)
        if package:gitref() or package:version():ge("4.0.0") then
            -- ASM_MARMASM support for Windows ARM64 requires CMake 3.26.
            package:add("deps", "cmake >=3.26")
            if package:config("libbacktrace") then
                package:add("deps", "libbacktrace")
            end
        else
            for _, dep in ipairs({"libcurl", "openssl"}) do
                if package:config(dep) then
                    package:add("deps", dep)
                end
            end
        end
    end)

    if on_check then
        on_check(function (package)
            if package:gitref() or package:version():ge("4.0.0") then
                assert(not package:config("shared"), "package(coost >=4.0.0): shared libraries are no longer supported.")
                assert(not package:config("libcurl") and not package:config("openssl"), "package(coost >=4.0.0): libcurl and openssl support has been removed.")
            else
                assert(not package:is_plat("bsd") and not (package:is_plat("windows") and package:is_arch("arm64")), "package(coost <4.0.0): FreeBSD and Windows ARM64 require coost >=4.0.0.")
            end
        end)
    end

    on_install("macosx", "linux", "bsd", "windows|x64", "windows|x86", "windows|arm64", function (package)
        if package:gitref() or package:version():ge("4.0.0") then
            local configs = {"-DBUILD_SHARED_LIBS=OFF", "-DBUILD_ALL=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DWITH_BACKTRACE=" .. (package:config("libbacktrace") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs, {packagedeps = "libbacktrace"})
            return
        end
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        for _, name in ipairs({"libcurl", "openssl"}) do
            if package:config(name) then
                configs["with_" .. name] = true
            end
        end
        if package:is_plat("windows") then
            local vs_runtime = package:config("vs_runtime")
            if vs_runtime then
                io.replace("xmake.lua", "set_runtimes%(.-%)", "set_runtimes(\"" .. vs_runtime .. "\")")
            end
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if package:gitref() or package:version():ge("4.0.0") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    co::wait_group wg(1);
                    co::go([wg]() { wg.done(); });
                    wg.wait();
                }
            ]]}, {configs = {languages = "c++17"}, includes = "co/co.h"}))
            return
        end
        assert(package:check_cxxsnippets({test = [[
            #include "co/def.h"
            #include "co/atomic.h"
            void test() {
                int32 i32 = 0;
                atomic_inc(&i32);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
