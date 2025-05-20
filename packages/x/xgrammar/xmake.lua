package("xgrammar")
    set_homepage("https://xgrammar.mlc.ai/")
    set_description("Fast, Flexible and Portable Structured Generation")
    set_license("Apache-2.0")

    add_urls("https://github.com/mlc-ai/xgrammar/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mlc-ai/xgrammar.git")
    add_versions("v0.1.19", "f05f8d05b12b29523a2f299535a42180e665ce80109360a6afafc300d82f1b78")

    add_configs("XGRAMMAR_BUILD_PYTHON_BINDINGS", {description = "Build Python bindings", default = false, type = "boolean"})
    add_deps("dlpack 1.1")

    on_check("windows", function (package)
        import("core.tool.toolchain")
        local msvc = toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
        local vs = msvc:config("vs")
        if vs and tonumber(vs) < 2022 and package:is_arch("arm64") then
            if package:config("shared") then
                raise("MSVC 2019 and earlier do not support ARM64 shared library builds.")
            end
        end
    end)

    on_install(function (package)
        local configs = {}
        configs.XGRAMMAR_BUILD_PYTHON_BINDINGS = package:config("XGRAMMAR_BUILD_PYTHON_BINDINGS")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
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
