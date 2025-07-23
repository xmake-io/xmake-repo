package("cpp-peglib")

    set_kind("library", {headeronly = true})
    set_homepage("https://yhirose.github.io/cpp-peglib")
    set_description("A single file C++ header-only PEG (Parsing Expression Grammars) library")
    set_license("MIT")

    set_urls("https://github.com/yhirose/cpp-peglib/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/yhirose/cpp-peglib.git")

    add_versions("1.9.1", "f57aa0f14372cbb772af29e3a4549a8033ea07eb25c39949cba6178e0e2ba9cc")
    add_versions("1.9.0", "6f4f0956ea2f44fd1c5882f8adc5782451ba9d227c467d214196390ddedb024c")
    add_versions("1.8.8", "3019d8084a146562fe2fd4c71e3226ac6e3994e8cee21cab27b3cd5a86bcef34")
    add_versions("1.8.3", "3de8aeb44a262f9c2478e2a7e7bc2bb9426a2bdd176cf0654ff5a3d291c77b73")

    on_install(function (package)
        if package:is_plat("windows") then
            package:add("cxxflags", "/Zc:__cplusplus")
        end
        os.cp("peglib.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <peglib.h>
            #include <assert.h>
            using namespace peg;

            void test() {
                parser parser(R"(
                    # Grammar for Calculator...
                    Additive    <- Multitive '+' Additive / Multitive
                    Multitive   <- Primary '*' Multitive / Primary
                    Primary     <- '(' Additive ')' / Number
                    Number      <- < [0-9]+ >
                    %whitespace <- [ \t]*
                  )");
                
                assert(static_cast<bool>(parser) == true);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
