package("inih")
    set_homepage("https://github.com/benhoyt/inih")
    set_description("Simple .INI file parser in C, good for embedded systems")

    add_urls("https://github.com/benhoyt/inih/archive/refs/tags/$(version).tar.gz",
             "https://github.com/benhoyt/inih.git")

    add_versions("r58", "e79216260d5dffe809bda840be48ab0eec7737b2bb9f02d2275c1b46344ea7b7")

    add_deps("meson", "ninja")

    add_configs("with_ini-parser", {description = "compile and (if selected) install INIReader", default = true, type = "boolean"})
    add_configs("use_heap", {description = "allocate memory on the heap using malloc instead using a fixed-sized line buffer on the stack", default = false, type = "boolean"})
    add_configs("max_line_length", {description = "maximum line length in bytes", default = "200", type = "string"})
    add_configs("allow_realloc", {description = "allow initial malloc size to grow to max line length (when using the heap)", default = false, type = "boolean"})

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dwith_INIReader=" .. (package:config("with_ini-parser") and "true" or "false"))
        table.insert(configs, "-Duse_heap=" .. (package:config("use_heap") and "true" or "false"))
        table.insert(configs, "-Dmax_line_length=" .. package:config("max_line_length"))
        table.insert(configs, "-Dallow_realloc=" .. (package:config("allow_realloc") and "true" or "false"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <stdio.h>
            #include <stdlib.h>
            #include <string.h>
            #include "ini.h"

            typedef struct
            {
                int version;
                const char* name;
                const char* email;
            } configuration;

            static int handler(void* user, const char* section, const char* name, const char* value)
            {
                configuration* pconfig = (configuration*)user;
                #define MATCH(s, n) strcmp(section, s) == 0 && strcmp(name, n) == 0
                if (MATCH("protocol", "version")) {
                    pconfig->version = atoi(value);
                } else if (MATCH("user", "name")) {
                    pconfig->name = strdup(value);
                } else if (MATCH("user", "email")) {
                    pconfig->email = strdup(value);
                } else {
                    return 0;
                }
                return 1;
            }

            int main(int argc, char* argv[])
            {
                configuration config;
                config.version = 0;
                config.name = NULL;
                config.email = NULL;
                if (ini_parse("test.ini", handler, &config) < 0) {
                    printf("Can't load 'test.ini'\n");
                    return 1;
                }
                int version = config.version;
                const char* name = config.name;
                const char* email = config.email;
                return 0;
            }
        ]]}, {configs = {languages = "cxx11"}}))

        if package:config("with_ini-parser") then
            assert(package:check_cxxsnippets({test = [[
                #include <iostream>
                #include "INIReader.h"

                int main()
                {
                    INIReader reader("test.ini");
                    if (reader.ParseError() < 0) {
                        std::cout << "Can't load 'test.ini'\n";
                        return 1;
                    }
                    int version = reader.GetInteger("protocol", "version", -1);
                    std::string name = reader.Get("user", "name", "UNKNOWN");
                    std::string email = reader.Get("user", "email", "UNKNOWN");
                    return 0;
                }
            ]]}, {configs = {languages = "cxx11"}}))
        end
    end)
