package("libfork")
    set_kind("library", {headeronly = true})
    set_homepage("https://conorwilliams.github.io/libfork/")
    set_description("A bleeding-edge, lock-free, wait-free, continuation-stealing tasking library built on C++20's coroutines")
    set_license("MPL-2.0")

    add_urls("https://github.com/ConorWilliams/libfork/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ConorWilliams/libfork.git")

    add_versions("v3.8.0", "53f23f0d27bb0753c0b03132f3c17bf8099617f037a2389a04e85fdd6f2736e8")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            import("core.tool.toolchain")

            local msvc = toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
            if msvc then
                local vs = msvc:config("vs")
                assert(vs and tonumber(vs) >= 2022, "package(libfork): need vs >= 2022")
            end
        end)
    end    

    on_install(function (package)
        import("package.tools.cmake").install(package, {
            "-DCMAKE_INSTALL_INCLUDEDIR=" .. package:installdir("include")
        })
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libfork.hpp>
            void test() {
                lf::sync_wait(lf::lazy_pool{}, [](auto) -> lf::task<int>{ co_return 0; });
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
