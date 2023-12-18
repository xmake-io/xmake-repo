package("unistd_h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/heheda123123/unistd_h")
    set_description("Windows implementation of the <unistd.h> header")
    set_license("MIT")

    add_urls("https://github.com/heheda123123/unistd_h.git")
    add_versions("2023.12.18", "495931b73386d407273e53a13365eb2f24100533")

    on_install("windows", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("access", {includes = "unistd.h"}))
        assert(package:has_cfuncs("fork", {includes = "unistd.h"}))
    end)
