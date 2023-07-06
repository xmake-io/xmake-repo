package("coost")
    set_homepage("https://github.com/idealvin/coost")
    set_description("A tiny boost library in C++11.")

    add_urls("https://github.com/idealvin/coost/archive/refs/tags/$(version).tar.gz",
             "https://github.com/idealvin/coost.git")

    add_versions("v3.0.0", "f962201201cd77aaf45f33d72bd012231a31d4310d30e9bb580ffb1e94c8148d")

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

    on_install("macosx", "linux", "windows", function (package)
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
