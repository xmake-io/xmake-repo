package("exprtk")

    set_kind("library", {headeronly = true})
    set_homepage("https://www.partow.net/programming/exprtk/index.html")
    set_description("C++ Mathematical Expression Parsing And Evaluation Library")
    set_license("MIT")

    add_urls("https://github.com/ArashPartow/exprtk.git")
    add_versions("0.0.1", "806c519c91fd08ba4fa19380dbf3f6e42de9e2d1")
    add_versions("0.0.2", "f46bffcd6966d38a09023fb37ba9335214c9b959")
    add_versions("0.0.3", "a4b17d543f072d2e3ba564e4bc5c3a0d2b05c338")

    if is_plat("windows") then
        add_cxxflags("/bigobj")
    elseif is_plat("mingw") then
        add_cxxflags("-Wa,-mbig-obj")
    end
    
    on_install("windows", "linux", "macosx", "bsd", "iphoneos", "android", "wasm", "cross", function (package)
        os.cp("exprtk.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                double x;
                const std::string expression_string =
                    "clamp(-1.0,sin(2 * pi * x) + cos(x / 2 * pi),+1.0)";
                exprtk::symbol_table<double> symbol_table;
                exprtk::expression<double> expression;
                exprtk::parser<double> parser;

                symbol_table.add_variable("x",x);
                symbol_table.add_constants();
                expression.register_symbol_table(symbol_table);
                parser.compile(expression_string,expression);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "exprtk.hpp"}))
    end)
