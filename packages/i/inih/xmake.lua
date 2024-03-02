package("inih")
    set_homepage("https://github.com/benhoyt/inih")
    set_description("Simple .INI file parser in C, good for embedded systems")

    add_urls("https://github.com/benhoyt/inih/archive/refs/tags/$(version).tar.gz", {version = function (version) return "r" .. version end})
    add_urls("https://github.com/benhoyt/inih.git")

    add_versions("58", "e79216260d5dffe809bda840be48ab0eec7737b2bb9f02d2275c1b46344ea7b7")

    add_configs("ini_parser", {description = "compile and (if selected) install INIReader", default = true, type = "boolean"})
    add_configs("multi_line_entries", {description = "support for multi-line entries in the style of Python's ConfigParser", default = true, type = "boolean"})
    add_configs("utf_8_bom", {description = "allow a UTF-8 BOM sequence (0xEF 0xBB 0xBF) at the start of INI files", default = true, type = "boolean"})
    add_configs("inline_comments", {description = "allow inline comments with the comment prefix character", default = true, type = "boolean"})
    add_configs("inline_comment_prefix", {description = "allow inline comments with the comment prefix character", default = ";", type = "string"})
    add_configs("start_of_line_comment_prefix", {description = "character(s) to start a comment at the beginning of a line", default = ";#'", type = "string"})
    add_configs("allow_no_value", {description = "allow name with no value", default = false, type = "boolean"})
    add_configs("stop_on_first_error", {description = "stop parsing after an error", default = false, type = "boolean"})
    add_configs("report_line_numbers", {description = "report line number on ini_handler callback", default = false, type = "boolean"})
    add_configs("call_handler_on_new_section", {description = "call the handler each time a new section is encountered", default = false, type = "boolean"})
    add_configs("heap", {description = "allocate memory on the heap using malloc instead using a fixed-sized line buffer on the stack", default = false, type = "boolean"})
    add_configs("max_line_length", {description = "maximum line length in bytes", default = "200", type = "string"})
    add_configs("initial_malloc_size", {description = "initial malloc size in bytes (when using the heap)", default = "200", type = "string"})
    add_configs("allow_realloc", {description = "allow initial malloc size to grow to max line length (when using the heap)", default = false, type = "boolean"})

    on_install(function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        for name, config_value in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                configs[name] = config_value
            end
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "ini.h"

            typedef struct { } configuration;

            static int handler(void* user, const char* section, const char* name, const char* value) { return 1; }

            int test(int argc, char* argv[])
            {
                configuration config;
                if (ini_parse("test.ini", handler, &config) < 0) {
                    return 1;
                }
                return 0;
            }
        ]]}, {configs = {languages = "cxx11"}}))

        if package:config("ini_parser") then
            assert(package:check_cxxsnippets({test = [[
                #include <iostream>
                #include "INIReader.h"

                int test()
                {
                    INIReader reader("test.ini");
                    return 0;
                }
            ]]}, {configs = {languages = "cxx11"}}))
        end
    end)
