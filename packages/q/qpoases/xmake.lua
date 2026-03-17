package("qpoases")
    set_homepage("https://github.com/coin-or/qpOASES")
    set_description("Open-source C++ implementation of the recently proposed online active set strategy")
    set_license("LGPL-2.1")

    add_urls("https://github.com/coin-or/qpOASES/archive/refs/tags/releases/$(version).tar.gz")
    add_urls("https://github.com/coin-or/qpOASES.git", {alias = "git", submodules = false})

    add_versions("3.2.2", "e36d795a17b067ea333793d96f17a14fb2bfbd92a4ab86c7f6f513cd9e3e640d")

    add_versions("git:3.2.2", "releases/3.2.2")

    add_deps("cmake")

    on_install(function (package)
        -- add windows shared library build support
        io.replace("CMakeLists.txt", "IF(BUILD_SHARED_LIBS AND WIN32)", "if(0)", {plain = true})

        local configs = {"-DQPOASES_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            USING_NAMESPACE_QPOASES
            void test() {
                QProblem example( 2,1 );
                Options options;
                example.setOptions( options );
            }
        ]]}, {configs = {languages = "c++14"}, includes = "qpOASES.hpp"}))
    end)
