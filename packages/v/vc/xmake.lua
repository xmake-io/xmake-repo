package("vc")

    set_homepage("https://github.com/VcDevel/Vc")
    set_description("SIMD Vector Classes for C++")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/VcDevel/Vc/releases/download/$(version)/Vc-$(version).tar.gz")
    add_versions("1.4.2", "50d3f151e40b0718666935aa71d299d6370fafa67411f0a9e249fbce3e6e3952")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    on_install("windows", "macosx", "linux", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Vc::Memory<Vc::float_v, 1000> x_mem;
                x_mem.vector(0) = Vc::float_v::Random() * 2.f - 1.f;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "Vc/Vc"}))
    end)
