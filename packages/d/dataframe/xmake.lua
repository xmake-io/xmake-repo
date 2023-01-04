package("dataframe")
    set_homepage("https://github.com/hosseinmoein/DataFrame")
    set_description("This is a C++ analytical library that provides interface and functionality similar to packages/libraries in Python and R.")
    set_license("MIT")

    add_urls("https://github.com/hosseinmoein/DataFrame/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hosseinmoein/DataFrame.git")

    add_versions("1.21.0", "a6b07eaaf628225a34e4402c1a6e311430e8431455669ac03691d92f44081172")
    add_versions("1.22.0", "4b244241cd56893fccb22f7c874588f0d86b444912382ed6e9a4cf95e55ffda2")

    add_deps("cmake")
    
    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
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
        ]]}, {configs = {languages = "c++17"}}))
    end)
