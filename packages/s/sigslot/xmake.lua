package("sigslot")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/palacaze/sigslot")
    set_description("A simple C++14 signal-slots implementation")
    set_license("MIT")

    add_urls("https://github.com/palacaze/sigslot/archive/refs/tags/$(version).tar.gz",
             "https://github.com/palacaze/sigslot.git")

    add_versions("v1.2.3", "36c30a88f05c8f8e6b4800d8f9c7c006cf61164695bf5fd91a8b80ed4e1d96af")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DSIGSLOT_COMPILE_EXAMPLES=OFF",
            "-DSIGSLOT_COMPILE_TESTS=OFF",
            "-DSIGSLOT_ENABLE_INSTALL=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <sigslot/signal.hpp>
            void test() {
                sigslot::signal<> sig;
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
