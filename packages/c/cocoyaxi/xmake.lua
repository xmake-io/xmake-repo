package("cocoyaxi")

    set_homepage("https://github.com/idealvin/cocoyaxi")
    set_description("A go-style coroutine library in C++11 and more")

    add_urls("https://github.com/idealvin/cocoyaxi.git")
    add_versions("v2.0.3", "3fd22601de4d7a06548ca4d24ac36b4f82cde8c5")
    add_versions("v2.0.2", "25915760f5cbcde1c5af625dd4d19a632ae43f12")
    add_versions("v2.0.1", "82b9f75dcd114c69d2b9c2c5a13ce2c3b95ba99f")

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
