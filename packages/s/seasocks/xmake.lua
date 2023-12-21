package("seasocks")
    set_homepage("https://github.com/mattgodbolt/seasocks")
    set_description("Simple, small, C++ embeddable webserver with WebSockets support")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/mattgodbolt/seasocks/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mattgodbolt/seasocks.git")

    add_versions("v1.4.6", "fc69636ce1205d338d4c02784333b04cd774fa368843fcf9f4fe6f8530a2cd67")

    add_configs("deflate", {description = "Include support for deflate (requires zlib).", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("python", {kind = "binary"})

    on_load(function (package)
        if package:config("deflate") then
            package:add("deps", "zlib")
        end
    end)

    on_install("windows", "linux", "bsd", function (package)
        local configs = {"-DUNITTESTS=OFF", "-DSEASOCKS_EXAMPLE_APP=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSEASOCKS_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDEFLATE_SUPPORT=" .. (package:config("deflate") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <seasocks/StringUtil.h>
            void test() {
                std::string dir = seasocks::getWorkingDir();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
