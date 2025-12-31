package("alpaka")
    set_kind("library", {headeronly = true})
    set_homepage("https://alpaka.readthedocs.io")
    set_description("Abstraction Library for Parallel Kernel Acceleration 🦙")
    set_license("MPL-2.0")

    add_urls("https://github.com/alpaka-group/alpaka/archive/refs/tags/$(version).tar.gz",
             "https://github.com/alpaka-group/alpaka.git")

    add_versions("2.1.1", "2d30a43594c55067297947b0ec83300e4f2899497464c5cc6f142c823f3ea1b2")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                alpaka::printTagNames<alpaka::EnabledAccTags>();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "alpaka/alpaka.hpp"}))
    end)
