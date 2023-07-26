package("zltoolkit")
    set_homepage("https://github.com/ZLMediaKit/ZLToolKit")
    set_description("A lightweight network framework based on C++11 that utilizes thread pool technology to achieve high concurrent network I/O.")
    set_license("MIT")

    set_urls("https://github.com/ZLMediaKit/ZLToolKit.git")

    add_versions("2023.7.8", "e4744a0a523817356f2ec995ee5a732264c31629")

    add_configs("mysql", {description = "Enable mysql support.", default = false, type = "boolean"})
    add_configs("openssl", {description = "Enable openssl support.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function(package)
        local configdeps = {"mysql", "openssl"}
        for _, dep in ipairs(configdeps) do
            if package:config(dep) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("linux", "windows", "macosx", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_MYSQL=" .. (package:config("mysql") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_OPENSSL=" .. (package:config("openssl") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
        io.replace("CMakeLists.txt", "$ENV{HOME}/${PROJECT_NAME}/lib", "lib", {plain = true})
        io.replace("CMakeLists.txt", "$ENV{HOME}/${PROJECT_NAME}/include", "include", {plain = true})
        io.replace("CMakeLists.txt", "if(NOT IOS AND NOT ANDROID AND NOT WIN32)", "if(TRUE)", {plain = true})
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        print(os.files("build/**.lib"))
        print(os.files("build/**.dll"))
        print(os.files("build/**.h"))
        if package:config("shared") then
            os.rm(path.join(package:installdir("lib"), "*.a"))
        else
            os.rm(path.join(package:installdir("lib"), "*.so"))
            os.rm(path.join(package:installdir("lib"), "*.dylib"))
            os.rm(path.join(package:installdir("bin"), "*.dll"))
        end
    end)

    on_test(function (package)
       assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace toolkit;
                mINI ini;
                ini[".dot"] = "dot-value";
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"Util/mini.h"}}))
    end)
