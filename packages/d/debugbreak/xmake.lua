package("debugbreak")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/scottt/debugbreak")
    set_description("break into the debugger programmatically")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/scottt/debugbreak/archive/refs/tags/$(version).tar.gz",
             "https://github.com/scottt/debugbreak.git")
    add_versions("v1.0", "62089680cc1cd0857519e2865b274ed7534bfa7ddfce19d72ffee41d4921ae2f")

    on_install(function (package)
        os.cp("debugbreak.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("debug_break()", {includes = "debugbreak.h"}))
    end)
