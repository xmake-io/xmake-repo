package("coost")
    set_homepage("https://github.com/idealvin/coost")
    set_description("A tiny boost library in C++11.")
    set_license("MIT")

    add_urls("https://github.com/idealvin/coost/archive/refs/tags/$(version).tar.gz",
             "https://github.com/idealvin/coost.git")

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
    end

    on_load(function (package)
        for _, dep in ipairs({"libcurl", "openssl"}) do
            if package:config(dep) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("macosx", "linux", "windows|x64", "windows|x86", function (package)
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
        assert(package:check_cxxsnippets({test = [[
            #include "co/def.h"
            #include "co/atomic.h"
            void test() {
                int32 i32 = 0;
                atomic_inc(&i32);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
