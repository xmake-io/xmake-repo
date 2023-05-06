package("cpp-peglib")

    set_kind("library", {headeronly = true})
    set_homepage("https://yhirose.github.io/cpp-peglib")
    set_description("A single file C++ header-only PEG (Parsing Expression Grammars) library")
    set_license("MIT")

    set_urls("https://github.com/yhirose/cpp-peglib/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/yhirose/cpp-peglib.git")

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
