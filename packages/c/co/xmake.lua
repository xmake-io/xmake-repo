package("co")

    set_homepage("https://github.com/idealvin/co")
    set_description("Yet another libco and more.")

    add_urls("https://github.com/idealvin/co/archive/refs/tags/$(version).tar.gz",
             "https://github.com/idealvin/co.git")

    add_versions("v2.0.0", "1bf687ebc08f9951869a111c56b90898b2c320e988dc86355ce17368f279e44d")

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
