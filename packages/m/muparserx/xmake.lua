package("muparserx")
    set_homepage("http://beltoforion.de/en/muparserx")
    set_description("A C++ Library for Parsing Expressions with Strings, Complex Numbers, Vectors, Matrices and more.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/beltoforion/muparserx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/beltoforion/muparserx.git")

    add_versions("v4.0.12", "941c79f9b8b924f2f22406af8587177b4b185da3c968dbe8dc371b9dbe117f6e")

    add_configs("widestring", {description = "Use widestring characters", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_install(function (package)
        io.replace("parser/mpTypes.h", [[#include "mpMatrix.h"]], "#include \"mpMatrix.h\"\n#include <cstdint>", {plain = true})
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_WIDE_STRING=" .. (package:config("widestring") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                mup::ParserX  parser(mup::pckALL_NON_COMPLEX);
                mup::Value ans;
	            parser.DefineVar(_T("ans"), mup::Variable(&ans));
            }
        ]]}, {configs = {languages = "c++17"}, includes = "muparserx/mpParser.h"}))
    end)
