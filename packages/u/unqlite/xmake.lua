package("unqlite")

    set_homepage("https://unqlite.org")
    set_description("An Embedded NoSQL, Transactional Database Engine.")

    set_urls("https://github.com/symisc/unqlite/archive/v$(version).tar.gz",
             "https://github.com/symisc/unqlite.git")
    add_versions("1.1.9", "33d5b5e7b2ca223942e77d31112d2e20512bc507808414451c8a98a7be5e15c0")

    on_install("macosx", "linux", "windows", function (package)
        io.writefile("xmake.lua", [[
            target("unqlite")
                set_kind("static")
                add_files("*.c")
                add_headerfiles("unqlite.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("unqlite_open", {includes = "unqlite.h"}))
    end)
