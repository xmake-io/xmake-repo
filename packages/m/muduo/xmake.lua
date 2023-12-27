package("muduo")
    set_homepage("https://github.com/chenshuo/muduo")
    set_description("Event-driven network library for multi-threaded Linux server in C++11")

    add_urls("https://github.com/chenshuo/muduo.git")
    add_versions("2022.11.01", "f29ca0ebc2f3b0ab61c1be08482a5524334c3d6f")

    add_configs("optional_deps", {description = "add optional deps", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("boost")

    on_install("linux", function (package)
        package:add("links", "muduo_net", "muduo_base")
        io.replace("CMakeLists.txt", "-Wold-style-cast", "", {plain = true})
        local configs ={"-DMUDUO_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:is_arch("i386") then
            table.insert(configs, "-DCMAKE_BUILD_BITS=32")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "muduo/net/EventLoop.h"
            void test() {
               muduo::net::EventLoop loop;
            }
        ]]}))
    end)
