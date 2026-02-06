package("cli11")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/CLIUtils/CLI11")
    set_description("CLI11 is a command line parser for C++11 and beyond that provides a rich feature set with a simple and intuitive interface.")
    set_license("BSD")

    add_urls("https://github.com/CLIUtils/CLI11/archive/refs/tags/$(version).tar.gz",
             "https://github.com/CLIUtils/CLI11.git")

    add_versions("v2.6.1", "377691f3fac2b340f12a2f79f523c780564578ba3d6eaf5238e9f35895d5ba95")
    add_versions("v2.5.0", "17e02b4cddc2fa348e5dbdbb582c59a3486fa2b2433e70a0c3bacb871334fd55")
    add_versions("v2.4.2", "f2d893a65c3b1324c50d4e682c0cdc021dd0477ae2c048544f39eed6654b699a")
    add_versions("v2.4.1", "73b7ec52261ce8fe980a29df6b4ceb66243bb0b779451dbd3d014cfec9fdbb58")
    add_versions("v2.3.2", "aac0ab42108131ac5d3344a9db0fdf25c4db652296641955720a4fbe52334e22")
    add_versions("v2.2.0", "d60440dc4d43255f872d174e416705f56ba40589f6eb07727f76376fb8378fd6")

    add_configs("cmake", {description = "Use cmake build system", default = true, type = "boolean"})

    if not is_host("windows") then
        add_extsources("pkgconfig::CLI11")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("shell32")
    end

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            import("package.tools.cmake").install(package, {
                "-DBUILD_TESTING=OFF",
                "-DCLI11_BUILD_EXAMPLES=OFF",
                "-DCLI11_INSTALL=ON",
            })
        else
            os.cp("include", package:installdir())
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            CLI::App app{"Test", "test"};
        ]]}, {configs = {languages = "cxx11"}, includes = "CLI/CLI.hpp"}))
    end)
