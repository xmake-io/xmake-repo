package("emio")
    set_kind("library", {headeronly = true})
    set_homepage("https://viatorus.github.io/emio/")
    set_description("A safe and fast high-level and low-level character input/output library for bare-metal and RTOS based embedded systems with a very small binary footprint.")

    add_urls("https://github.com/viatorus/emio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/viatorus/emio.git")

    add_versions("0.4.0", "847198a37fbf9dcc00ac85fbc64b283e41a018f53c39363129a4bdb9939338a6")

    add_deps("cmake")

    add_includedirs("include/emio")

    on_install("linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", "wasm", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <emio/format.hpp>
            void test() {
                emio::format("{0}", 42);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
