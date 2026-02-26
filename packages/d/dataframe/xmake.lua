package("dataframe")
    set_homepage("https://github.com/hosseinmoein/DataFrame")
    set_description("This is a C++ analytical library that provides interface and functionality similar to packages/libraries in Python and R.")
    set_license("MIT")

    add_urls("https://github.com/hosseinmoein/DataFrame/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hosseinmoein/DataFrame.git")

    add_versions("3.7.0", "bd3bb9f45bb0ac092e4ff9052d565d8d6eed8f8029a1a7de7424b4190b797345")
    add_versions("3.6.0", "23366522d8e0f0d4f8405bfda435be0d408782b3309a46be522b060b7393ef4f")
    add_versions("3.4.0", "84aafa6bd1bf2000232e380f12eea0de01b2d0da88930aa4416aee524a8736aa")
    add_versions("3.3.0", "57a722592a29ee8fca902983411c78e7f4179c402a8b0b905f96916c9694672a")
    add_versions("3.2.0", "44c513ef7956976738c2ca37384a220c5383e95fc363ad933541c6f3eef9d294")
    add_versions("3.1.0", "09280a81f17d87d171062210c904c1acd94b1cdcf4c040eaa16cc9d224d526d4")
    add_versions("3.0.0", "9266fb85c518a251a5440e490c81615601791f2de2fad8755aa09f13a0c541f9")
    add_versions("1.21.0", "a6b07eaaf628225a34e4402c1a6e311430e8431455669ac03691d92f44081172")
    add_versions("1.22.0", "4b244241cd56893fccb22f7c874588f0d86b444912382ed6e9a4cf95e55ffda2")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "rt")
    end

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            local version = package:version()
            if version:lt("3.0.0") then
                return
            end
            if version:eq("3.1.0") then
                assert(package:has_tool("cxx", "cl", "clang", "clang_cl"), "package(dataframe/3.1.0) Only msvc/clang support")
            end

            if package:is_plat("windows") then
                local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
                if vs_toolset then
                    local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                    local minor = vs_toolset_ver:minor()
                    assert(minor and minor >= 30, "package(dataframe) require vs_toolset >= 14.3")
                end
            end
            assert(package:check_cxxsnippets({test = [[
                #include <algorithm>
                #include <ranges>
                #include <vector>
                void test() {
                    std::vector<int> x, y;
                    std::ranges::fill(x, 10);
                    for (auto&& [a, b] : std::views::zip(x, y)) {}
                    bool _ = std::ranges::contains(x, 10);
                }
            ]]}, {configs = {languages = "c++23"}}), "package(dataframe) require fully support for c++23")
        end)
    end

    on_install(function (package)
        if package:config("shared") then
            package:add("defines", "HMDF_SHARED")
        end
        if package:has_tool("cxx", "cl") then
            package:add("defines", "_USE_MATH_DEFINES")
        end

        local configs = {"-DCMAKE_CXX_STANDARD=23"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <DataFrame/DataFrame.h>
            #include <DataFrame/DataFrameFinancialVisitors.h>
            #include <DataFrame/DataFrameMLVisitors.h>
            #include <DataFrame/DataFrameStatsVisitors.h>
            #include <DataFrame/Utils/DateTime.h>
            #include <iostream>
            using namespace hmdf;
            using ULDataFrame = StdDataFrame<unsigned long>;
            void test() {
                std::vector<unsigned long> idx_col1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
                ULDataFrame ul_df1;
                ul_df1.load_index(std::move(idx_col1));
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
