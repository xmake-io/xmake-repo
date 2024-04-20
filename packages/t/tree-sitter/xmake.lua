package("tree-sitter")

    set_homepage("https://tree-sitter.github.io/")
    set_description("An incremental parsing system for programming tools")

    add_urls("https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v$(version).zip")

    add_versions("0.22.2", "df0cd4aacc53b6feb9519dd4b74a7a6c8b7f3f7381fcf7793250db3e5e63fb80")
    add_versions("0.21.0", "874794e6b3b985f7f9e87dfe29e4bfdbe5c0339e67740f35dfc4fa85804ba708")

    on_install(function(package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")

        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_csnippets({
            test = [[
            #include <string.h>
            #include <tree_sitter/api.h>
            void test() {
                TSParser *parser = ts_parser_new();
                const char *source_code = "[1, null]";
                TSTree *tree = ts_parser_parse_string(
                    parser,
                    NULL,
                    source_code,
                    strlen(source_code)
                );
            }
        ]]
        }))
    end)
