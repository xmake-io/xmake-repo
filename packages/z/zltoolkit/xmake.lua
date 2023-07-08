package("zltoolkit")
    set_homepage("https://github.com/ZLMediaKit/ZLToolKit")
    set_description("A lightweight network framework based on C++11 that utilizes thread pool technology to achieve high concurrent network I/O.")
    set_license("MIT")

    set_urls("https://github.com/ZLMediaKit/ZLToolKit.git")

    add_versions("2023.7.8", "e4744a0a523817356f2ec995ee5a732264c31629")
    
    add_configs("mysql", {description = "Enable mysql support.", default = false, type = "boolean"})
    add_configs("openssl", {description = "Enable openssl support.", default = false, type = "boolean"})

    on_load(function(package)
        local configdeps = {"mysql", "openssl"}
        for _, dep in ipairs(configdeps) do
            if package:config(dep) then
                package:add("deps", dep)
            end
        end
    end)
    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DENABLE_MYSQL=" .. (package:config("mysql") and "ON" or "OFF"),
            "-DENABLE_OPENSSL=" .. (package:config("openssl") and "ON" or "OFF"),
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF")
        }
        import("package.tools.cmake").install(package, configs)
        if package:is_plat("windows") then
            os.mv("C:/ZLToolKit/include", package:installdir())
            os.mv("C:/ZLToolKit/lib/*", package:installdir("lib"))
            os.rm("C:/ZLToolKit")
        end
    end)

    on_test(function (package)
       assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace toolkit;
                mINI ini;
                ini[".dot"] = "dot-value";
            }
        ]]}, {configs = {languages = "cxx11"}, includes = {"Util/mini.h"}}))
    end)