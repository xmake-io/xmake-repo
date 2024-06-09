add_rules("mode.debug", "mode.release")

option("ini_parser", {description = "compile and (if selected) install INIReader", default = true, type = "boolean"})
option("multi_line_entries", {description = "support for multi-line entries in the style of Python's ConfigParser", default = true, type = "boolean"})
option("utf_8_bom", {description = "allow a UTF-8 BOM sequence (0xEF 0xBB 0xBF) at the start of INI files", default = true, type = "boolean"})
option("inline_comments", {description = "allow inline comments with the comment prefix character", default = true, type = "boolean"})
option("inline_comment_prefix", {description = "allow inline comments with the comment prefix character", default = ";", type = "string"})
option("start_of_line_comment_prefix", {description = "character(s) to start a comment at the beginning of a line", default = ";#", type = "string"})
option("allow_no_value", {description = "allow name with no value", default = false, type = "boolean"})
option("stop_on_first_error", {description = "stop parsing after an error", default = false, type = "boolean"})
option("report_line_numbers", {description = "report line number on ini_handler callback", default = false, type = "boolean"})
option("call_handler_on_new_section", {description = "call the handler each time a new section is encountered", default = false, type = "boolean"})
option("heap", {description = "allocate memory on the heap using malloc instead using a fixed-sized line buffer on the stack", default = false, type = "boolean"})
option("max_line_length", {description = "maximum line length in bytes", default = "200", type = "string"})
option("initial_malloc_size", {description = "initial malloc size in bytes (when using the heap)", default = "200", type = "string"})
option("allow_realloc", {description = "allow initial malloc size to grow to max line length (when using the heap)", default = false, type = "boolean"})

target("inih")
    set_kind("$(kind)")
    set_languages("c++11")
    
    add_files("ini.c")
    add_headerfiles("(ini.h)")

    if is_kind("shared") then
        add_defines("INI_SHARED_LIB")
        add_defines("INI_SHARED_LIB_BUILDING")
    end

    if has_config("ini_parser") then
        add_files("cpp/INIReader.cpp")
        add_headerfiles("cpp/(INIReader.h)")
    end

    if not has_config("utf_8_bom") then add_defines("INI_ALLOW_BOM=0") end
    if not has_config("inline_comments") then add_defines("INI_ALLOW_INLINE_COMMENTS=0") end
    if has_config("inline_comment_prefix") then add_defines([[INI_INLINE_COMMENT_PREFIXES="]] .. get_config("inline_comment_prefix") .. [["]]) end
    if has_config("start_of_line_comment_prefix") then add_defines([[INI_START_COMMENT_PREFIXES="]] .. get_config("start_of_line_comment_prefix") .. [["]]) end
    if has_config("allow_no_value") then add_defines("INI_ALLOW_NO_VALUE=1") end
    if has_config("stop_on_first_error") then add_defines("INI_STOP_ON_FIRST_ERROR=1") end
    if has_config("report_line_numbers") then add_defines("INI_HANDLER_LINENO=1") end
    if has_config("call_handler_on_new_section") then add_defines("INI_CALL_HANDLER_ON_NEW_SECTION=1") end
    if has_config("heap") then add_defines("INI_USE_STACK=0") end
    if has_config("max_line_length") then add_defines("INI_MAX_LINE=" .. get_config("max_line_length")) end
    if has_config("initial_malloc_size") then add_defines("INI_INITIAL_ALLOC=" .. get_config("initial_malloc_size")) end
    if has_config("allow_realloc") then add_defines("INI_ALLOW_REALLOC=1") end
    if is_plat("windows") then add_defines("_WIN32") end
    
    on_config(function (target)
        if target:has_tool("gcc", "gxx") then
            target:add("defines", "__GNUC__")
        end
    end)
