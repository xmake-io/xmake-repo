package("dlib")

    set_kind("library", {headeronly = true})
    set_homepage("https://dlib.net")
    set_description("A toolkit for making real world machine learning and data analysis applications in C++")
    set_license("Boost")

    add_urls("https://github.com/davisking/dlib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/davisking/dlib.git")
    add_versions("v19.24.4", "d881911d68972d11563bb9db692b8fcea0ac1b3fd2e3f03fa0b94fde6c739e43")
    add_versions("v19.22", "5f44b67f762691b92f3e41dcf9c95dd0f4525b59cacb478094e511fdacb5c096")

    add_deps("cmake")
    on_install("windows", "linux", "macosx", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("dlib::command_line_parser", {
            includes = "dlib/cmd_line_parser.h", configs = {languages = "c++11"}}))
    end)
