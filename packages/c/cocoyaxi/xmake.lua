package("cocoyaxi")

    set_homepage("https://github.com/idealvin/cocoyaxi")
    set_description("A go-style coroutine library in C++11 and more")

    add_urls("https://github.com/idealvin/cocoyaxi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/idealvin/cocoyaxi.git")
    add_versions("v2.0.3", "c112fafed5e45a3cac27e4b1b5b9f7483df267d510dd03c5dd8272e6405ea61f")

    for _, name in ipairs({"libcurl", "openssl"}) do
        add_configs(name, {description = "Enable " .. name .. " library.", default = false, type = "boolean"})
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
