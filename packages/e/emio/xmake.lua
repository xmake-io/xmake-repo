package("emio")
    set_kind("library", {headeronly = true})
    set_homepage("https://viatorus.github.io/emio/")
    set_description("A safe and fast high-level and low-level character input/output library for bare-metal and RTOS based embedded systems with a very small binary footprint.")

    add_urls("https://github.com/viatorus/emio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/viatorus/emio.git")

    add_versions("0.8.0", "86436eeb16cac7c7c74a7c1af9fe7bbbc1aa18d3d96e7bba9791c15ebe9ebdc7")
    add_versions("0.7.0", "1ef5304964eee109c13477f2d84822ee474612475049a377b59e33a5fe05d7eb")
    add_versions("0.4.0", "847198a37fbf9dcc00ac85fbc64b283e41a018f53c39363129a4bdb9939338a6")

    add_deps("cmake")

    add_includedirs("include/emio")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <bit>
                void test() {
                    for (unsigned x{0}; x != 8; ++x) {
                        auto y = std::bit_width(x);
                    }
                }
            ]]}, {configs = {languages = "c++20"}}), "package(emio) Require at least C++20.")
        end)
    end

    on_install("!windows", function (package)
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
