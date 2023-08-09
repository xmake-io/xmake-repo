package("scnlib")

    set_homepage("https://scnlib.readthedocs.io/")
    set_description("scnlib is a modern C++ library for replacing scanf and std::istream")

    set_urls("https://github.com/eliaskosunen/scnlib/archive/refs/tags/v$(version).zip")
    add_versions("1.1.2", "72bf304662b03e00de5b438b9d4697a081e786d589e067817c356174fb2cb06c")
    add_versions("0.4", "49a84f1439e52666532fbd5da3fa1d652622fc7ac376070e330e15c528d38190")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("header_only") then
            package:add("defines", "SCN_HEADER_ONLY=1")
        else
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("header_only") then
            os.cp("include/scn", package:installdir("include"))
            return
        end
        local configs = {"-DSCN_TESTS=OFF", "-DSCN_DOCS=OFF", "-DSCN_EXAMPLES=OFF", "-DSCN_BENCHMARKS=OFF", "-DSCN_PENDANTIC=OFF", "-DSCN_BUILD_FUZZING=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <scn/scn.h>
            #include <cstdio>

            static void test() {
                int i;
                scn::prompt("What's your favorite number? ", "{}", i);
                printf("Oh, cool, %d!", i);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "scn/scn.h"}))
    end)
