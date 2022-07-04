package("dynareadout")

    set_homepage("https://github.com/PucklaMotzer09/dynareadout")
    set_description("Ansi C library for parsing binary output files of LS Dyna (d3plot, binout)")

    add_urls("https://github.com/PucklaMotzer09/dynareadout/archive/refs/tags/$(version).tar.gz",
             "https://github.com/PucklaMotzer09/dynareadout.git")
    add_versions("0.1", "833c8516c77ab57c56e942692e1fea2c96c50b7adfebd7f6f633ed43aaf46a56")

    add_configs("cpp", {description = "Build the C++ bindings", default = true, type = "boolean"})

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {}
        configs.build_test = "n"
        configs.build_cpp = package:config("cpp") and "y" or "n"
        configs.kind = package:config("shared") and "shared" or "static"
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("binout_open", {includes = "binout.h", configs = {languages = "ansi"}}))
        if package:config("cpp") then
            assert(package:has_cxxtypes("dro::Binout", {includes = "binout.hpp", configs = {languages = "cxx17"}}))
        end
    end)
