package("plotlypp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/jimmyorourke/plotlypp")
    set_description("Plotly for C++. A C++ interface to the Plotly.js figure spec, for creating interactive data visualizations.")
    set_license("MIT")

    add_urls("https://github.com/jimmyorourke/plotlypp.git")

    add_versions("2026.01.26", "8d9b250cbe1e2415d011af90e00f495def49712d")

    add_deps("cmake")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_install(function (package)
        import("package.tools.cmake").install(package, {
            "-DPLOTLYPP_BUILD_EXAMPLES=OFF",
        })
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto figure = plotlypp::Figure();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "plotlypp/figure.hpp"}))
    end)
