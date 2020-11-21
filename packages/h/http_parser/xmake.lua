package("http_parser")

    set_homepage("https://github.com/nodejs/http-parser")
    set_description("Parser for HTTP messages written in C.")

    add_urls("https://github.com/nodejs/http-parser/archive/$(version).tar.gz",
             "https://github.com/nodejs/http-parser.git")
    add_versions("v2.9.4", "467b9e30fd0979ee301065e70f637d525c28193449e1b13fbcb1b1fab3ad224f")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("http_parser")
                set_kind("static")
                add_files("http_parser.c")
                add_headerfiles("http_parser.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("http_parser_version", {includes = "http_parser.h"}))
    end)