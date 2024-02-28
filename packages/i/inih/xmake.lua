package("inih")
    set_homepage("https://github.com/benhoyt/inih")
    set_description("Simple .INI file parser in C, good for embedded systems")

    add_urls("https://github.com/benhoyt/inih/archive/refs/tags/r$(version).tar.gz",
             "https://github.com/benhoyt/inih.git")

    add_versions("58", "e79216260d5dffe809bda840be48ab0eec7737b2bb9f02d2275c1b46344ea7b7")

    add_configs("ini_parser", {description = "compile and (if selected) install INIReader", default = true, type = "boolean"})
    add_configs("heap", {description = "allocate memory on the heap using malloc instead using a fixed-sized line buffer on the stack", default = false, type = "boolean"})
    add_configs("max_line_length", {description = "maximum line length in bytes", default = "200", type = "string"})
    add_configs("allow_realloc", {description = "allow initial malloc size to grow to max line length (when using the heap)", default = false, type = "boolean"})

    on_install(function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        configs.ini_parser = package:config("ini_parser")
        configs.heap = package:config("heap")
        configs.max_line_length = package:config("max_line_length")
        configs.allow_realloc = package:config("allow_realloc")
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
