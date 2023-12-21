package("exprtk")

    set_kind("library", {headeronly = true})
    set_homepage("https://www.partow.net/programming/exprtk/index.html")
    set_description("C++ Mathematical Expression Parsing And Evaluation Library")
    set_license("MIT")

    add_urls("https://github.com/ArashPartow/exprtk.git")
    add_versions("2022.01.01", "f46bffcd6966d38a09023fb37ba9335214c9b959")

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
