package("flux")
    set_kind("library", {headeronly = true})
    set_homepage("https://tristanbrindle.com/flux/")
    set_description("A C++20 library for sequence-orientated programming")
    set_license("BSL-1.0")

    add_urls("https://github.com/tcbrindle/flux/archive/refs/tags/$(version).tar.gz",
             "https://github.com/tcbrindle/flux.git")

    add_versions("v0.4.0", "95e7d9d71c9ee9e89bb24b46ccba77ddfb0a1580630c2faab0b415dacc7c8d56")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DFLUX_BUILD_EXAMPLES=OFF", "-DFLUX_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <flux.hpp>
            void test() {
                constexpr auto result = flux::from(std::array{1, 2, 3, 4, 5})
                         .filter(flux::pred::even)
                         .map([](int i) { return i * 2; })
                         .sum();
                static_assert(result == 12);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
