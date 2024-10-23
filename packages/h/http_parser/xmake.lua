package("http_parser")
    set_homepage("https://github.com/nodejs/http-parser")
    set_description("Parser for HTTP messages written in C.")
    set_license("MIT")

    add_urls("https://github.com/nodejs/http-parser/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nodejs/http-parser.git")

    add_versions("v2.9.4", "467b9e30fd0979ee301065e70f637d525c28193449e1b13fbcb1b1fab3ad224f")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("http_parser")
                set_kind("$(kind)")
                if is_kind("shared") and is_plat("windows") then
                    local funcs = {"http_body_is_final",
                                   "http_errno_description",
                                   "http_errno_name",
                                   "http_method_str",
                                   "http_parser_execute",
                                   "http_parser_init",
                                   "http_parser_parse_url",
                                   "http_parser_pause",
                                   "http_parser_set_max_header_size",
                                   "http_parser_settings_init",
                                   "http_parser_url_init",
                                   "http_parser_version",
                                   "http_should_keep_alive",
                                   "http_status_str"}
                    for _, func in ipairs(funcs) do
                        add_shflags("/export:" .. func)
                    end
                end
                add_files("http_parser.c")
                add_headerfiles("http_parser.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("http_parser_version", {includes = "http_parser.h"}))
    end)
