package("libinterpolate")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/CD3/libInterpolate")
    set_description("A C++ library for interpolation.")
    set_license("MIT")

    add_urls("https://github.com/CD3/libInterpolate/archive/2887aaf000e62cec1cceb9b238d402852c24fa26.tar.gz",
             "https://github.com/CD3/libInterpolate.git")

    add_versions("2024.04.29", "1f39904d09da933dd11a58c6ea061c5f2459bbd44dd6ffa2429734629b15b489")

    add_deps("cmake")
    add_deps("boost", "eigen")

    on_install("windows", "linux", "macosx", "mingw", "cross", function (package)
        local configs = {"-DBUILD_TESTS=OFF"}
        local version = package:version()
        if version then
            table.insert(configs, "-DlibInterpolate_VERSION=" .. version)
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                _1D::CubicSplineInterpolator<double> interp;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "libInterpolate/Interpolate.hpp"}))
    end)
