add_rules("mode.debug", "mode.release")

option("ini_parser", {description = "compile and (if selected) install INIReader", default = true, type = "boolean"})
option("heap", {description = "allocate memory on the heap using malloc instead using a fixed-sized line buffer on the stack", default = false, type = "boolean"})
option("max_line_length", {description = "maximum line length in bytes", default = "200", type = "string"})
option("allow_realloc", {description = "allow initial malloc size to grow to max line length (when using the heap)", default = false, type = "boolean"})

target("inih")
    set_kind("$(kind)")
    set_languages("c++11")
    
    add_files("ini.c")
    add_headerfiles("(ini.h)")

    if has_config("ini_parser") then
        add_files("cpp/INIReader.cpp")
        add_headerfiles("(cpp/INIReader.h)")
    end

    if has_config("heap") then
        add_defines("INI_USE_STACK=0")
    end

    if has_config("max_line_length") then
        add_defines("INI_MAX_LINE=" .. get_config("max_line_length"))
    end

    if has_config("allow_realloc") then
        add_defines("INI_ALLOW_REALLOC=1")
    end

    if is_plat("windows") then
        add_defines("_WIN32")
    end

    if is_kind("shared") then
        add_defines("INI_SHARED_LIB")
        add_defines("INI_SHARED_LIB_BUILDING")
    end
    
    on_config(function (target)
        if target:has_tool("gcc", "gxx") then
            target:add("defines", "__GNUC__")
        end
    end)
