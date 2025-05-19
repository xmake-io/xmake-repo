package("xgrammar")
    set_homepage("https://xgrammar.mlc.ai/")
    set_description("Fast, Flexible and Portable Structured Generation")
    set_license("Apache-2.0")

    add_urls("https://github.com/mlc-ai/xgrammar/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mlc-ai/xgrammar.git")
    add_versions("v0.1.19", "f05f8d05b12b29523a2f299535a42180e665ce80109360a6afafc300d82f1b78")

    add_configs("XGRAMMAR_BUILD_PYTHON_BINDINGS", {description = "Build Python bindings", default = false, type = "boolean"})
    add_deps("dlpack 1.1")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_requires("dlpack 1.1")

            if ]] ..tostring(package:config("XGRAMMAR_BUILD_PYTHON_BINDINGS")).. [[ then
                add_requires("nanobind v2.5.0")
            end

            set_languages("c++17")
            target("xgrammar")
                set_kind("static")
                add_includedirs("3rdparty/picojson")
                add_includedirs("include", {public = true})
                add_headerfiles("include/(**.h)")
                add_files("cpp/*.cc")
                add_files("cpp/support/*.cc")
                add_packages("dlpack")
                if ]] ..tostring(package:config("XGRAMMAR_BUILD_PYTHON_BINDINGS")).. [[ then
                    add_files("cpp/nanobind/*.cc")
                    add_packages("nanobind")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
#include <string>
#include <vector>

static auto test() -> void {
  auto compiler = xgrammar::GrammarCompiler{
      xgrammar::TokenizerInfo{std::vector<std::string>{}},
  };
  constexpr auto rule =
      R"(
root ::= rule1 rule2 | "abc"
rule1 ::= "abc" | ""
rule2 ::= "def" rule3 | ""
rule3 ::= "ghi""
)";

  compiler.CompileJSONSchema(rule);
}
        ]]}, {configs = {languages = "c++17"}, includes = "xgrammar/xgrammar.h"}))
    end)
